#!/usr/bin/env bash

# Parameters value

# =============================================================================

# clone yay
git clone https://aur.archlinux.org/yay.git /tmp/yay &> /dev/null
cd /tmp/yay
makepkg -si &> /dev/null
cd -
rm -rf /tmp/yay

# sync package database
sudo pacman -Syyu &> /dev/null
yay -Syyu &> /dev/null