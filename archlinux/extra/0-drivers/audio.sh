#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
# No parameters required for this script

# ==============================================================================
#                            INSTALL AUDIO DRIVERS
# ==============================================================================

# Install PipeWire and related packages
sudo pacman -S --noconfirm pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack wireplumber alsa-utils
