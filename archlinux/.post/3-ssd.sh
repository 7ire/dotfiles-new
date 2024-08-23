#!/usr/bin/env bash

# Parameters value

# =============================================================================

# fstrim - improves SSD performance
pacman -S --noconfirm util-linux &> /dev/null
systemctl enable fstrim.timer &> /dev/null