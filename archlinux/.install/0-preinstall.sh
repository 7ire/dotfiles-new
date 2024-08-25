#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
keyboard=$1  # Keyboard layout to be loaded (e.g., us, uk, de)

# ==============================================================================
#                       SYSTEM PREPARATION CHECKS AND SETUP
# ==============================================================================

# Check if the system is in UEFI mode by verifying the existence of the EFI variables directory
if [ ! -d /sys/firmware/efi/efivars ]; then
  echo "BIOS mode detected! UEFI is required for this script."
  exit 1
fi

# ==============================================================================
#                          SYSTEM CONFIGURATION
# ==============================================================================

# Set the keyboard layout
loadkeys $keyboard &> /dev/null

# Enable NTP (Network Time Protocol) for automatic time synchronization
timedatectl set-ntp true &> /dev/null

# ==============================================================================
#                       PACKAGE MANAGER CONFIGURATION
# ==============================================================================

# Update the Arch Linux keyring to ensure that package installations succeed
pacman -S --noconfirm archlinux-keyring &> /dev/null

# Initialize the pacman keyring
pacman-key --init &> /dev/null

# Enable parallel downloads in pacman to speed up package installations
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf &> /dev/null

# Refresh the package database
pacman -Syy &> /dev/null

# ==============================================================================
#                        INSTALL REQUIRED PACKAGES
# ==============================================================================

# Install essential packages: GPT fdisk, Btrfs utilities, and the GNU C library
pacman -S --noconfirm --needed gptfdisk btrfs-progs glibc &> /dev/null

# ==============================================================================
#                         UPDATE MIRRORLIST FOR OPTIMAL SPEED
# ==============================================================================

# Backup the current mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup &> /dev/null

# Update the mirrorlist to use the fastest mirrors in specified countries
reflector --country 'Italy,France,Germany' --protocol https --age 6 --sort rate --save /etc/pacman.d/mirrorlist &> /dev/null

# Refresh the package database again after updating the mirrorlist
pacman -Syy &> /dev/null
