#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
is_enc=$1      # Indicates if encryption is enabled ('True' or 'False')
fs_type=$2     # Filesystem type (e.g., 'btrfs' or 'ext4')

# ==============================================================================
#                        CONFIGURE mkinitcpio IN CHROOT ENVIRONMENT
# ==============================================================================

# Change root into the new system
arch-chroot /mnt /bin/bash << 'CHROOT_CMDS'

# ==============================================================================
#                                FILESYSTEM CONFIGURATION
# ==============================================================================
# Add btrfs module if the filesystem is btrfs
if [ "$fs_type" = "btrfs" ]; then
    # Modify mkinitcpio.conf to include btrfs module
    sed -i '/^MODULES=/ s/)/ btrfs)/' /etc/mkinitcpio.conf &> /dev/null
fi

# ==============================================================================
#                             HOOKS CONFIGURATION
# ==============================================================================
# Configure hooks based on encryption and filesystem type
if [ "$is_enc" = "True" ]; then
    # Add keyfile for encryption
    sed -i '/^FILES=/ s/)/ \/key.bin)/' /etc/mkinitcpio.conf &> /dev/null
    
    # Set hooks for encryption
    sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect keymap consolefont modconf block encrypt filesystems fsck)/' /etc/mkinitcpio.conf &> /dev/null
else
    # Set hooks without encryption
    sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect keymap consolefont modconf block filesystems fsck)/' /etc/mkinitcpio.conf &> /dev/null
fi

# ==============================================================================
#                                UPDATE INITRAMFS
# ==============================================================================
# Generate the initial ramdisk environment
mkinitcpio -P &> /dev/null

# Exit the chroot environment
exit
CHROOT_CMDS

