#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
# No parameters for this script, all actions are performed on the system.

# ==============================================================================
#                               SYSTEM UPDATE
# ==============================================================================
# Update the system packages and synchronize package databases
sudo pacman -Syyu --noconfirm &> /dev/null

# ==============================================================================
#                           CHECK SYSTEM STATUS
# ==============================================================================
# Check for failed services
systemctl --failed

# Review system logs for critical errors
journalctl -p 3 -xb

# ==============================================================================
#                           INSTALL AND CONFIGURE UTILITIES
# ==============================================================================
# Install 'locate' command and update its database
sudo pacman -S --noconfirm mlocate &> /dev/null
sudo updatedb &> /dev/null

# Install 'pkgfile' for command-not-found support
sudo pacman -S --noconfirm pkgfile &> /dev/null
sudo pkgfile --update &> /dev/null

# Add command-not-found support to ~/.bashrc if not present
BASHRC="$HOME/.bashrc"
CONTENT='
# Command-not-found support for pkgfile
if [[ -f /usr/share/doc/pkgfile/command-not-found.bash ]]; then
    . /usr/share/doc/pkgfile/command-not-found.bash
fi
'

if ! grep -q "/usr/share/doc/pkgfile/command-not-found.bash" "$BASHRC"; then
    echo "$CONTENT" >> "$BASHRC"
fi