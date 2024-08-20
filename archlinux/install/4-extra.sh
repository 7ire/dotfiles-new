#!/usr/bin/env bash



# -----------------------------------------------------------------------------
#                  Package manager basic configuration
# -----------------------------------------------------------------------------
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf



# -----------------------------------------------------------------------------
#                  Services
# -----------------------------------------------------------------------------
# install pkgs and enable services
# SSH
pacman -S --noconfirm openssh
systemctl enable sshd.service

# NetworkManager
pacman -S --noconfirm networkmanager
systemctl enable NetworkManager.service
systemctl enable NetworkManager-wait-online.service

# Reflector
pacman -S --noconfirm reflector
cat > /etc/xdg/reflector/reflector.conf <<EOF
--country 'Italy,France,Germany'
--protocol https
--age 6
--sort rate
--save /etc/pacman.d/mirrorlist
EOF
# TODO: check if reflector.service needs to be edited
systemctl enable reflector.service
systemctl enable reflector.timer

# paccache
pacman -S --noconfirm pacman-contrib



# -----------------------------------------------------------------------------
#                  Extra packages
# -----------------------------------------------------------------------------
pacman -S --noconfirm neovim sudo bash-completion mlocate man-db man-pages pkgfile util-linux





envars() {}