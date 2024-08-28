#!/usr/bin/env bash

# ==============================================================================
#                                PARAMETERS
# ==============================================================================
disk=$1  # Target disk to be wiped and reset (e.g., /dev/sda)

# ==============================================================================
#                          WIPE AND RESET DISK
# ==============================================================================
# Wipe the existing filesystem signatures from the disk
wipefs -af $disk &> /dev/null

# Clear the partition table and reset the disk to a fresh state
sgdisk --zap-all --clear $disk &> /dev/null

# Inform the operating system of the changes to the disk layout
partprobe $disk &> /dev/null
