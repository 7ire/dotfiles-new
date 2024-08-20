#!/usr/bin/env bash



# -----------------------------------------------------------------------------
#                  Base system packages installation
# -----------------------------------------------------------------------------
# install base packages
pacstrap /mnt base base-devel ${microcode} linux-firmware linux-zen linux-zen-headers btrfs-progs cryptsetup

# generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab



# chroot base system
arch-chroot /mnt /bin/bash



# -----------------------------------------------------------------------------
#                  Configure base system
# -----------------------------------------------------------------------------
# timezone
ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime
hwclock --systohc

# hostname
echo $hostname > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${hostname}.localdomain ${hostname}
EOF

# locale
sed -i "s/^#\(${locale}\)/\1/" /etc/locale.gen
echo "LANG=${locale}" > /etc/locale.conf
locale-gen

# font and keymap
echo "KEYMAP=${keyboard}" > /etc/vconsole.conf



# -----------------------------------------------------------------------------
#                  Keyfile for encrypted partition
# -----------------------------------------------------------------------------
# create keyfile 'key.bin' and restrict access to 'root'
dd bs=512 count=4 iflag=fullblock if=/dev/random of=/key.bin
chmod 600 /key.bin

# add keyfile to LUKS
cryptsetup luksAddKey ${disk}p2 /key.bin



# -----------------------------------------------------------------------------
#                  Configure mkinitcpio
# -----------------------------------------------------------------------------
# add keyfile to mkinitcpio
sed -i '/^FILES=/ s/)/ \/key.bin)/' /etc/mkinitcpio.conf

# add btrfs module to mkinitcpio
sed -i '/^MODULES=/ s/)/ btrfs)/' /etc/mkinitcpio.conf

# set hooks
sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect keymap consolefont modconf block encrypt filesystems fsck)/' /etc/mkinitcpio.conf

# update initramfs
mkinitcpio -P



# -----------------------------------------------------------------------------
#                  Configure bootloader
# -----------------------------------------------------------------------------
# install bootloader
pacman -S --noconfirm grub efibootmgr sbctl ntfs-3g

# determine UUID of encrypted partition
uuid=$(blkid -s UUID -o value ${disk}p2)

# check if blkid command returned UUID
if [ -z "$uuid" ]; then
  echo "Error: unable to find UUID of encrypted partition."
  exit 1
fi

# backup grub file
cp /etc/default/grub /etc/default/grub.backup

# Modify grub configuration
# GRUB_TIMEOUT
sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=30/" /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT
sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=$uuid:cryptdev\"/" /etc/default/grub
# GRUB_PRELOAD_MODULES
sed -i "s/^GRUB_PRELOAD_MODULES=.*/GRUB_PRELOAD_MODULES=\"part_gpt part_msdos luks\"/" /etc/default/grub
# GRUB_ENABLE_CRYPTODISK
sed -i "s/^#GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/" /etc/default/grub
# GRUB_SUBMENU
sed -i "s/^#GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=y/" /etc/default/grub
# GRUB_SAVEDEFAULT
sed -i "s/^#GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/" /etc/default/grub
# TODO: add another option for grub save default
# GRUB_DISABLE_OS_PROBER
sed -i "s/^#GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub

# install grub
grub-install --target=x86_64-efi --efi-directory=/esp --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
grub-mkconfig -o /boot/grub/grub.cfg
sbctl status
sbctl create-keys && sbctl enroll-keys -m
sbctl sign -s /boot/EFI/GRUB/grubx64.efi && sbctl sign -s /boot/grub/x86_64-efi/core.efi && sbctl sign -s /boot/grub/x86_64-efi/grub.efi && sbctl sign -s /boot/vmlinuz-linux-zen