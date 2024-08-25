#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
disk=$1  # Target disk (e.g., /dev/sda)

# ==============================================================================
#                        KEYFILE CREATION AND LUKS SETUP
# ==============================================================================

# Change root into the new system
arch-chroot /mnt /bin/bash << 'CHROOT_CMDS'

# ==============================================================================
#                            CREATE KEYFILE
# ==============================================================================
# Generate a keyfile named 'key.bin' with 512 bytes of random data
dd bs=512 count=4 iflag=fullblock if=/dev/random of=/key.bin &> /dev/null

# Restrict access to the keyfile so only 'root' can read it
chmod 600 /key.bin &> /dev/null

# ==============================================================================
#                            ADD KEYFILE TO LUKS
# ==============================================================================
# Add the keyfile to the LUKS-encrypted partition
cryptsetup luksAddKey "${disk}p2" /key.bin &> /dev/null

# Exit the chroot environment
exit
CHROOT_CMDS