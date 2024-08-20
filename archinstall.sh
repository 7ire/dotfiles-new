#!/usr/bin/env bash

# -----------------------------------------------------------------------------
#                  Arch Linux installer parameters
# -----------------------------------------------------------------------------
# Keyboard layout. For example, "it" for Italian layout.
# - it: Italian
# - us: American
# - us-acentos: American with european accents
# To list all available layouts, run 'localectl list-keymaps'
keyboard="it" 
# Disk target for the Arch Linux installation.
# Identify the disk with 'lsblk -f'
disk="/dev/nvme0n1"
# Microcode package to load updates and security fixes from processor vendors.
# View cpuinfo: 'grep vendor_id /proc/cpuinfo'
# - AMD: "amd-ucode"
# - Intel: "intel-ucode"
microcode="intel-ucode"
# Timezone. For example, "Europe/Rome".
# List all available timezones with 'timedatectl list-timezones'
timezone="Europe/Rome"
# Locale. For example, "it_IT.UTF-8".
# List all available locales with 'locale -a'
locale="it_IT.UTF-8"
# Hostname.
hostname="archlinux"
# Username.
username="foo"
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
#                  Export paramenters
# -----------------------------------------------------------------------------
export keyboard disk microcode timezone locale hostname username



# -----------------------------------------------------------------------------
#                  Output debug messages
# -----------------------------------------------------------------------------

# Output debug message with color
print_debug() {
  local color="$1"
  local message="$2"
  echo -e "\e[${color}m${message}\e[0m"
}

print_success() {
  print_debug "32" "$1"
}

print_error() {
  print_debug "31" "$1"
}

print_info() {
  print_debug "36" "$1"
}

print_warning() {
  print_debug "33" "$1"
}

# -----------------------------------------------------------------------------
#                  Arch Linux installation
# -----------------------------------------------------------------------------
print_info "Starting Arch Linux installation..."

print_info "[0] - Installation preparation ..."
./install/0-preinstall.sh
print_success "[0] - Installation is ready!"

print_info "[1] - Clearing and formatting target disk of installation ..."
./install/1-disk.sh
print_success "[1] - Disk is ready to host the system!"

print_info "[2] - Installing base system ..."
./install/2-base.sh
print_success "[2] - Base system is installed!"

print_info "[3] - Creating new user ..."
./install/3-user.sh
print_success "[3] - User is created!"