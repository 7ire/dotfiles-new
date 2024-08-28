#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
is_enc=$1   # Whether encryption is enabled (True/False)
disk=$2     # Target disk (e.g., /dev/sda)
espsize=$3  # Size of the EFI System Partition (ESP) in MiB
key=$4      # Encryption key (used only if is_enc=True)

# ==============================================================================
#                          DISK PARTITIONING
# ==============================================================================
# Create the EFI System Partition (ESP) and root partition
sgdisk -n 0:0:+${espsize} -t 0:ef00 -c 0:ESP $disk &> /dev/null  # Partition 1: EFI System Partition
sgdisk -n 0:0:0 -t 0:8300 -c 0:rootfs $disk &> /dev/null         # Partition 2: Root Partition (non-encrypted)

if [ "$is_enc" = "True" ]; then
    # Change partition 2 type to LUKS (for encryption)
    sgdisk -t 2:8309 $disk &> /dev/null
fi

# Inform the OS of partition table changes
partprobe $disk &> /dev/null

# ==============================================================================
#                        ENCRYPTION SETUP (IF ENABLED)
# ==============================================================================
if [ "$is_enc" = "True" ]; then
    # Encrypt partition 2 using the provided key
    echo -n "$key" | cryptsetup --type luks2 -v -y luksFormat ${disk}p2 --key-file=- &> /dev/null

    # Open the encrypted partition
    echo -n "$key" | cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent ${disk}p2 cryptdev --key-file=- &> /dev/null

    # Set the root device to the encrypted partition
    root_device="/dev/mapper/cryptdev"
else
    # Set the root device to the non-encrypted partition
    root_device="${disk}p2"
fi

# ==============================================================================
#                        FILESYSTEM SETUP
# ==============================================================================
# Format the EFI System Partition (ESP) as FAT32
mkfs.vfat -F32 -n ESP ${disk}p1 &> /dev/null

# Format the root partition as Btrfs
mkfs.btrfs -L archlinux $root_device &> /dev/null

# ==============================================================================
#                        MOUNTING AND SUBVOLUMES SETUP
# ==============================================================================
# Mount the root device
mount $root_device /mnt &> /dev/null

# Create Btrfs subvolumes for system and data segregation
btrfs subvolume create /mnt/@ &> /dev/null           # Main system subvolume
btrfs subvolume create /mnt/@home &> /dev/null       # Home directory subvolume
btrfs subvolume create /mnt/@snapshots &> /dev/null  # Snapshots subvolume
btrfs subvolume create /mnt/@cache &> /dev/null      # Cache subvolume
btrfs subvolume create /mnt/@libvirt &> /dev/null    # Libvirt subvolume
btrfs subvolume create /mnt/@log &> /dev/null        # Log files subvolume
btrfs subvolume create /mnt/@tmp &> /dev/null        # Temporary files subvolume

# Unmount the root device to remount with options
umount /mnt &> /dev/null

# ==============================================================================
#                        REMOUNT WITH SUBVOLUMES AND OPTIONS
# ==============================================================================
# Set mount options for Btrfs subvolumes
sv_opts="rw,noatime,compress-force=zstd:1,space_cache=v2"

# Remount the main system subvolume
mount -o ${sv_opts},subvol=@ $root_device /mnt &> /dev/null

# Create mount points for additional subvolumes
mkdir -p /mnt/{home,.snapshots,var/cache,var/lib/libvirt,var/log,var/tmp} &> /dev/null

# Mount additional subvolumes
mount -o ${sv_opts},subvol=@home $root_device /mnt/home &> /dev/null
mount -o ${sv_opts},subvol=@snapshots $root_device /mnt/.snapshots &> /dev/null
mount -o ${sv_opts},subvol=@cache $root_device /mnt/var/cache &> /dev/null
mount -o ${sv_opts},subvol=@libvirt $root_device /mnt/var/lib/libvirt &> /dev/null
mount -o ${sv_opts},subvol=@log $root_device /mnt/var/log &> /dev/null
mount -o ${sv_opts},subvol=@tmp $root_device /mnt/var/tmp &> /dev/null
