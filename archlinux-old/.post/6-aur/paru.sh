#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
# No parameters required for this script

# ==============================================================================
#                            INSTALL PARU AUR HELPER
# ==============================================================================
git clone https://aur.archlinux.org/paru.git /tmp/paru &> /dev/null

cd /tmp/paru
makepkg -si --noconfirm &> /dev/null
cd -

# Clean up temporary files
rm -rf /tmp/paru &> /dev/null

# ==============================================================================
#                            SYNC PACKAGE DATABASE
# ==============================================================================
sudo pacman -Syyu --noconfirm &> /dev/null
paru -Syyu --noconfirm &> /dev/null