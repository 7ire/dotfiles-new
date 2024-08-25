#!/usr/bin/env bash

# ==============================================================================
#                                 PARAMETERS
# ==============================================================================
disk=$1  # Target disk to be filled with random data

# ==============================================================================
#                        FILL DISK WITH RANDOM DATA
# ==============================================================================
# Create a temporary encrypted device using /dev/urandom for randomness
cryptsetup open --type plain -d /dev/urandom $disk target &> /dev/null

# Ensure the crypt device is closed when the script exits (successfully or due to an error)
trap 'cryptsetup close target' EXIT

# Fill the temporary crypt device with zeros using 'dd'
dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct &> /dev/null

# Close the crypt device mapping
cryptsetup close target &> /dev/null

# Remove the exit trap as the crypt device is already closed
trap - EXIT
