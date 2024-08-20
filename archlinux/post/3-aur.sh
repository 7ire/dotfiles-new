#!/usr/bin/env bash



# -----------------------------------------------------------------------------
#                  AUR helper installation
# -----------------------------------------------------------------------------
# clone paru
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru
makepkg -si 
cd -
rm -rf /tmp/paru

# sync package database
sudo pacman -Syyu && paru -Syyu