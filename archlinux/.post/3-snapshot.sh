#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
TIMELINE_MIN_AGE="1800"     # Minimum age of a snapshot in seconds
TIMELINE_LIMIT_HOURLY="5"   # Limit of hourly snapshots
TIMELINE_LIMIT_DAILY="7"    # Limit of daily snapshots
TIMELINE_LIMIT_WEEKLY="0"   # Limit of weekly snapshots
TIMELINE_LIMIT_MONTHLY="0"  # Limit of monthly snapshots
TIMELINE_LIMIT_YEARLY="0"   # Limit of yearly snapshots

# ==============================================================================
#                           INSTALL AND CONFIGURE SNAPSHOT TOOLS
# ==============================================================================
sudo pacman -S --noconfirm snapper snap-pac &> /dev/null

# Path to snapper configuration file
SNAPPER_CONF="/etc/snapper/configs/root"

# Unmount and remove the existing subvolume and mount point
sudo umount /.snapshots &> /dev/null
sudo rm -rf /.snapshots &> /dev/null

# Create a new snapper configuration for the root subvolume
sudo snapper -c root create-config / &> /dev/null

# Remove the snapper-generated subvolume
sudo btrfs subvolume delete .snapshots &> /dev/null

# Re-create and re-mount the /.snapshots mount point
sudo mkdir /.snapshots &> /dev/null
sudo mount -a &> /dev/null

# Set permissions for the /.snapshots directory
sudo chmod 750 /.snapshots &> /dev/null
sudo chown :wheel /.snapshots &> /dev/null

# ==============================================================================
#                           MODIFY SNAPSHOT CONFIGURATION
# ==============================================================================
sudo sed -i "s/^ALLOW_USERS=.*/ALLOW_USERS=\"$user\"/" $SNAPPER_CONF
sudo sed -i "s/^TIMELINE_MIN_AGE=.*/TIMELINE_MIN_AGE=\"$TIMELINE_MIN_AGE\"/" $SNAPPER_CONF
sudo sed -i "s/^TIMELINE_LIMIT_HOURLY=.*/TIMELINE_LIMIT_HOURLY=\"$TIMELINE_LIMIT_HOURLY\"/" $SNAPPER_CONF
sudo sed -i "s/^TIMELINE_LIMIT_DAILY=.*/TIMELINE_LIMIT_DAILY=\"$TIMELINE_LIMIT_DAILY\"/" $SNAPPER_CONF
sudo sed -i "s/^TIMELINE_LIMIT_WEEKLY=.*/TIMELINE_LIMIT_WEEKLY=\"$TIMELINE_LIMIT_WEEKLY\"/" $SNAPPER_CONF
sudo sed -i "s/^TIMELINE_LIMIT_MONTHLY=.*/TIMELINE_LIMIT_MONTHLY=\"$TIMELINE_LIMIT_MONTHLY\"/" $SNAPPER_CONF
sudo sed -i "s/^TIMELINE_LIMIT_YEARLY=.*/TIMELINE_LIMIT_YEARLY=\"$TIMELINE_LIMIT_YEARLY\"/" $SNAPPER_CONF

# ==============================================================================
#                          ENABLE AND START SERVICES
# ==============================================================================
sudo systemctl enable --now snapper-timeline.timer &> /dev/null
sudo systemctl enable --now snapper-cleanup.timer &> /dev/null

# ==============================================================================
#                               CHECK AND INSTALL LOCATE
# ==============================================================================
if ! command -v updatedb &> /dev/null; then
    sudo pacman -S --noconfirm mlocate &> /dev/null
fi

# Add .snapshots to PRUNENAMES in updatedb configuration
sudo sed -i "/^PRUNENAMES/s/\"$/ .snapshots\"/" /etc/updatedb.conf

# Update the locate database
sudo updatedb &> /dev/null

# ==============================================================================
#                               INSTALL AND CONFIGURE GRUB-BTRFS
# ==============================================================================
sudo pacman -S --noconfirm grub-btrfs inotify-tools &> /dev/null

# Set the GRUB configuration directory
sudo sed -i "s|^GRUB_BTRFS_GRUB_DIRNAME=.*|GRUB_BTRFS_GRUB_DIRNAME=\"/esp/grub\"|" /etc/default/grub-btrfs/config

# Enable grub-btrfs.path to auto-regenerate grub-btrfs.cfg
sudo systemctl enable --now grub-btrfs.path &> /dev/null

# Configure mkinitcpio for overlayfs
sudo sed -i "/^HOOKS=/ s/)/ grub-btrfs-overlayfs)/" /etc/mkinitcpio.conf
sudo mkinitcpio -P &> /dev/null
