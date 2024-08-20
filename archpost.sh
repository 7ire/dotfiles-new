#!/bin/bash

user=""
swapsize="16G"

# Free sudo
# 
# Allow a user (example: foo) to execute superuser 
# commands using sudo without being prompted for a password.
free_sudo() {
  echo "${username} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudoer_${username}
}

# Configure pacman
#
# Bring some color and the spirit of Pacman to pacman with 
# 'Color' and 'ILoveCandy' options.
pkg-manager() {
  # Pacman configuration file
  local PACMAN_CONF="/etc/pacman.conf"

  # Enable 'Color' and 'ILoveCandy' options
  if ! sudo sed -i 's/^#Color/Color/' "$PACMAN_CONF" ||
     ! grep -q '^ILoveCandy' "$PACMAN_CONF" && ! sudo sed -i '/^Color/a ILoveCandy' "$PACMAN_CONF"; then
     # TODO: Error
  fi
}