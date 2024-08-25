#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
microcode=$1  # CPU microcode package (e.g., intel-ucode, amd-ucode)
is_btrfs=$2   # Btrfs package (e.g., btrfs-progs) if Btrfs is used
is_crypt=$3   # Cryptsetup package (e.g., cryptsetup) if disk encryption is used

# ==============================================================================
#                            INSTALL BASE SYSTEM
# ==============================================================================

# Install the base system, development tools, microcode, Linux kernel, firmware, 
# and additional packages for Btrfs and/or disk encryption if specified.
pacstrap /mnt base base-devel ${microcode} linux-firmware linux-zen linux-zen-headers ${is_btrfs} ${is_crypt} &> /dev/null 

# ==============================================================================
#                          GENERATE FILESYSTEM TABLE (FSTAB)
# ==============================================================================

# Generate an fstab file with UUIDs and append it to the /mnt/etc/fstab file
genfstab -U -p /mnt >> /mnt/etc/fstab &> /dev/null
