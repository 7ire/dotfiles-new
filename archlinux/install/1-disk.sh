#!/usr/bin/env bash

umount -A --recursive /mnt # make sure everything is unmounted before we start



# -----------------------------------------------------------------------------
#                  Formating target disk
# -----------------------------------------------------------------------------
# delete old partition layout
wipefs -af $disk
sgdisk --zap-all --clear $disk
partprobe $disk

# fill the disk with random data
cryptsetup open --type plain -d /dev/urandom $disk target                 # create a temporary crypt device (example: target)
dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct  # fill the container with a stream of zeros using dd
cryptsetup close target                                                   # remove the mapping

# partition the disk
sgdisk -n 0:0:+1024MiB -t 0:ef00 -c 0:esp $disk  # partition 1: EFI partition
sgdisk -n 0:0:0 -t 0:8309 -c 0:luks $disk        # partition 2: Encrypted partition
partprobe $disk

# print the partition table
sgdisk -p $disk

# encrypt partition 2
cryptsetup --type luks2 -v -y luksFormat ${disk}p2

# format partitions
cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent ${disk}p2 cryptdev
mkfs.vfat -F32 -n ESP ${disk}p1
mkfs.btrfs -L archlinux /dev/mapper/cryptdev



# -----------------------------------------------------------------------------
#                  Create Filesystems
# -----------------------------------------------------------------------------
# mount root device
mount /dev/mapper/cryptdev /mnt

# create BTRFS subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@libvirt
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@tmp

# unmount root device
umount /mnt



# -----------------------------------------------------------------------------
#                  Subvolumes setup
# -----------------------------------------------------------------------------
# set mount options for the subvolumes
sv_opts="rw,noatime,compress-force=zstd:1,space_cache=v2"

# mount the new BTRFS root subvolume with subvol=@
mount -o ${sv_opts},subvol=@ /dev/mapper/cryptdev /mnt

# create mountpoints for the additional subvolumes
mkdir -p /mnt/{home,.snapshots,var/cache,var/lib/libvirt,var/log,var/tmp}
mount -o ${sv_opts},subvol=@home /dev/mapper/cryptdev /mnt/home
mount -o ${sv_opts},subvol=@snapshots /dev/mapper/cryptdev /mnt/.snapshots
mount -o ${sv_opts},subvol=@cache /dev/mapper/cryptdev /mnt/var/cache
mount -o ${sv_opts},subvol=@libvirt /dev/mapper/cryptdev /mnt/var/lib/libvirt
mount -o ${sv_opts},subvol=@log /dev/mapper/cryptdev /mnt/var/log
mount -o ${sv_opts},subvol=@tmp /dev/mapper/cryptdev /mnt/var/tmp

# mount ESP
mkdir -p /mnt/esp
mount ${disk}p1 /mnt/esp