#!/usr/bin/env bash



# -----------------------------------------------------------------------------
#                  Configure Arch Linux installer prerequisites
# -----------------------------------------------------------------------------
# keyboard layout
loadkeys $keyboard

# verify boot mode
ls /sys/firmware/efi/efivars

# system clock - Network Time Protocol
timedatectl set-ntp true
timedatectl status

# package manager configuration
pacman -S --noconfirm archlinux-keyring  # update keyrings to latest to prevent packages failing to install
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# setup ISO mirrors for faster downloads
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector --country 'Italy,France,Germany' --protocol https --age 6 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy

# install extra prerequisite packages
pacman -S --noconfirm --needed gptfdisk btrfs-progs glibc