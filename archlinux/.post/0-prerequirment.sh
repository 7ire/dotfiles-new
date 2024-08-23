#!/usr/bin/env bash

# Parameters value

# =============================================================================

# update system
sudo pacman -Syyu --noconfirm &> /dev/null

# check for failed services
systemctl --failed
journalctl -p 3 -xb

# Command: 'locate'
sudo pacman -S --noconfirm mlocate &> /dev/null
sudo updatedb &> /dev/null

# Command-not-found
sudo pacman -S --noconfirm pkgfile &> /dev/null
sudo pkgfile --update &> /dev/null
BASHRC="$HOME/.bashrc"  # path of ~/.bashrc
CONTENT='
if [[ -f /usr/share/doc/pkgfile/command-not-found.bash ]]; then
    . /usr/share/doc/pkgfile/command-not-found.bash
fi
'
if ! grep -q "/usr/share/doc/pkgfile/command-not-found.bash" "$BASHRC"; then
    echo "$CONTENT" >> "$BASHRC"  # add to ~/.bashrc
fi