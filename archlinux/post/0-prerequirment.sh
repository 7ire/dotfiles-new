#!/usr/bin/env bash



# -----------------------------------------------------------------------------
#                  Pre-requirment steps
# -----------------------------------------------------------------------------
# update system
sudo pacman -Syyu

# check for failed services
systemctl --failed
journalctl -p 3 -xb