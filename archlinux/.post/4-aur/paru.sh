#!/usr/bin/env bash

# Parameters value

# =============================================================================

# clone paru
git clone https://aur.archlinux.org/paru.git /tmp/paru &> /dev/null
cd /tmp/paru
makepkg -si &> /dev/null
cd -
rm -rf /tmp/paru &> /dev/null

# sync package database
sudo pacman -Syyu &> /dev/null
paru -Syyu &> /dev/null