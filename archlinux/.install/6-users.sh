#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
rootpwd=$1    # Root password
username=$2   # Username for the new user
userpwd=$3    # Password for the new user

# ==============================================================================
#                        CONFIGURE USER IN CHROOT ENVIRONMENT
# ==============================================================================

# Change root into the new system
arch-chroot /mnt /bin/bash << 'CHROOT_CMDS'

# ==============================================================================
#                           CONFIGURE ROOT USER
# ==============================================================================
# Set the root password
echo "root:$rootpwd" | chpasswd &> /dev/null

# ==============================================================================
#                            CONFIGURE NEW USER
# ==============================================================================
# Add a new user and assign to 'wheel' group with bash shell
useradd -m -G wheel -s /bin/bash "$username" &> /dev/null

# Set password for the new user
echo "$username:$userpwd" | chpasswd &> /dev/null

# ==============================================================================
#                          CONFIGURE SUDO ACCESS
# ==============================================================================
# Enable 'wheel' group users to use sudo
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers &> /dev/null

# Exit the chroot environment
exit
CHROOT_CMDS
