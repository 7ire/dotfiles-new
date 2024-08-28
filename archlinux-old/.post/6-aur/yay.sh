#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
# No parameters required for this script

# ==============================================================================
#                            INSTALL YAY AUR HELPER
# ==============================================================================
git clone https://aur.archlinux.org/yay.git /tmp/yay &> /dev/null

cd /tmp/yay
makepkg -si --noconfirm &> /dev/null
cd -

# Clean up temporary files
rm -rf /tmp/yay &> /dev/null

# ==============================================================================
#                            SYNC PACKAGE DATABASE
# ==============================================================================
sudo pacman -Syyu --noconfirm &> /dev/null
yay -Syyu --noconfirm &> /dev/null
