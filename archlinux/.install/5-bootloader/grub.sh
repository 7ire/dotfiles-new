#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
is_enc=$1  # Indicates if encryption is enabled ('True' or 'False')
disk=$2    # Target disk (e.g., /dev/sda)

# ==============================================================================
#                        CONFIGURE GRUB IN CHROOT ENVIRONMENT
# ==============================================================================

# Change root into the new system
arch-chroot /mnt /bin/bash << 'CHROOT_CMDS'

# ==============================================================================
#                             INSTALL BOOTLOADER
# ==============================================================================
# Install GRUB and related tools
pacman -S --noconfirm grub efibootmgr sbctl ntfs-3g

# Backup current GRUB configuration
cp /etc/default/grub /etc/default/grub.backup

# ==============================================================================
#                            CONFIGURE GRUB DEFAULTS
# ==============================================================================
# Modify GRUB default settings
sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=30/" /etc/default/grub
sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub
sed -i "s/^#GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=y/" /etc/default/grub
sed -i "s/^#GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=y/" /etc/default/grub
sed -i "s/^#GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub

# ==============================================================================
#                           CONFIGURE ENCRYPTED DISK (IF ENCRYPTED)
# ==============================================================================
if [ "$is_enc" = "True" ]; then
    # Determine UUID of the encrypted partition
    uuid=$(blkid -s UUID -o value ${disk}p2)

    # Check if UUID was successfully retrieved
    if [ -z "$uuid" ]; then
        echo "Error: unable to find UUID of encrypted partition."
        exit 1
    fi

    # Modify GRUB configuration for encrypted disk
    sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=$uuid:cryptdev\"/" /etc/default/grub
    sed -i "s/^GRUB_PRELOAD_MODULES=.*/GRUB_PRELOAD_MODULES=\"part_gpt part_msdos luks\"/" /etc/default/grub
    sed -i "s/^#GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/" /etc/default/grub
fi

# ==============================================================================
#                           INSTALL AND CONFIGURE GRUB
# ==============================================================================
# Install GRUB to the EFI system partition
grub-install --target=x86_64-efi --efi-directory=/esp --bootloader-id=GRUB --modules="tpm" --disable-shim-lock

# Generate GRUB configuration file
grub-mkconfig -o /boot/grub/grub.cfg

# ==============================================================================
#                            CONFIGURE SECURE BOOT
# ==============================================================================
# Display SBCTL status
sbctl status

# Create and enroll signing keys
sbctl create-keys && sbctl enroll-keys -m

# Sign the necessary files
sbctl sign -s /boot/EFI/GRUB/grubx64.efi \
           -s /boot/grub/x86_64-efi/core.efi \
           -s /boot/grub/x86_64-efi/grub.efi \
           -s /boot/vmlinuz-linux-zen

# Exit the chroot environment
exit
CHROOT_CMDS
