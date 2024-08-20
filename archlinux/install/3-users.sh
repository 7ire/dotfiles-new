#!/usr/bin/env bash

# -----------------------------------------------------------------------------
#                  Users
# -----------------------------------------------------------------------------

# root password
passwd

# add user
useradd -m -G wheel -s /bin/bash $username
passwd $username

# active 'wheel' group for 'sudo'
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers