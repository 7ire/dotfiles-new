#!/usr/bin/env bash

# ==============================================================================
#                                PARAMETERS
# ==============================================================================
# No parameters for this script

# ==============================================================================
#                       CONFIGURE SYSTEM IN CHROOT ENVIRONMENT
# ==============================================================================
arch-chroot /mnt /bin/bash << 'CHROOT_CMDS'

# ==============================================================================
#                         CONFIGURE PACMAN
# ==============================================================================
# Enable parallel downloads and color output
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i '/^Color/a ILoveCandy' /etc/pacman.conf

# Update package database
pacman -Syy &> /dev/null

# ==============================================================================
#                            INSTALL AND ENABLE SERVICES
# ==============================================================================
# Install and enable SSH service
pacman -S --noconfirm openssh &> /dev/null
systemctl enable sshd.service &> /dev/null

# Install and enable NetworkManager
pacman -S --noconfirm networkmanager &> /dev/null
systemctl enable NetworkManager.service &> /dev/null
systemctl enable NetworkManager-wait-online.service &> /dev/null

# Install and configure Reflector for mirrorlist updates
pacman -S --noconfirm reflector &> /dev/null
cat > /etc/xdg/reflector/reflector.conf <<EOF
--country 'Italy,France,Germany'
--protocol https
--age 6
--sort rate
--save /etc/pacman.d/mirrorlist
EOF
systemctl enable reflector.service &> /dev/null
systemctl enable reflector.timer &> /dev/null

# Install and enable paccache for cache maintenance
pacman -S --noconfirm pacman-contrib &> /dev/null
systemctl enable paccache.timer &> /dev/null

# ==============================================================================
#                        INSTALL ADDITIONAL PACKAGES
# ==============================================================================
pacman -S --noconfirm neovim sudo bash-completion man-db man-pages git curl rsync wget &> /dev/null

# ==============================================================================
#                         CONFIGURE ENVIRONMENT VARIABLES
# ==============================================================================
# Set default editor and visual editor
echo "EDITOR=nvim" > /etc/environment
echo "VISUAL=nvim" >> /etc/environment

# ==============================================================================
#                          CONFIGURE MULTILIB REPOSITORY
# ==============================================================================
# Enable multilib repository
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

# Exit chroot environment
exit
CHROOT_CMDS
