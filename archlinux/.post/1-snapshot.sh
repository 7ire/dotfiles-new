#!/usr/bin/env bash

# Parameters value

# =============================================================================

# install 'snapper' and 'snap-pac'
sudo pacman -S --noconfirm snapper snap-pac &> /dev/null

# unmount the subvolume and remove the mountpoint
sudo umount /.snapshots &> /dev/null
sudo rm -rf /.snapshots &> /dev/null

# create a new 'root' config
sudo snapper -c root create-config / &> /dev/null

# delete the snapper-generated subvolume
sudo btrfs subvolume delete .snapshots &> /dev/null

# re-create and re-mount /.snapshots mountpoint
sudo mkdir /.snapshots &> /dev/null
sudo mount -a &> /dev/null

# set permissions. Owner must be 'root', and I allow members of 'wheel' to browse through snapshots
sudo chmod 750 /.snapshots &> /dev/null
sudo chown :wheel /.snapshots &> /dev/null

# time parameters
TIMELINE_MIN_AGE="1800"        # Minimum age of a snapshot in seconds
TIMELINE_LIMIT_HOURLY="5"      # Limit of hourly snapshots
TIMELINE_LIMIT_DAILY="7"       # Limit of daily snapshots
TIMELINE_LIMIT_WEEKLY="0"      # Limit of weekly snapshots
TIMELINE_LIMIT_MONTHLY="0"     # Limit of monthly snapshots
TIMELINE_LIMIT_YEARLY="0"      # Limit of yearly snapshots

# modify the configuration file
sudo sed -i "s/^ALLOW_USERS=.*/ALLOW_USERS=\"$user\"/" /etc/snapper/configs/root
sudo sed -i "s/^TIMELINE_MIN_AGE=.*/TIMELINE_MIN_AGE=\"$TIMELINE_MIN_AGE\"/" /etc/snapper/configs/root
sudo sed -i "s/^TIMELINE_LIMIT_HOURLY=.*/TIMELINE_LIMIT_HOURLY=\"$TIMELINE_LIMIT_HOURLY\"/" /etc/snapper/configs/root
sudo sed -i "s/^TIMELINE_LIMIT_DAILY=.*/TIMELINE_LIMIT_DAILY=\"$TIMELINE_LIMIT_DAILY\"/" /etc/snapper/configs/root
sudo sed -i "s/^TIMELINE_LIMIT_WEEKLY=.*/TIMELINE_LIMIT_WEEKLY=\"$TIMELINE_LIMIT_WEEKLY\"/" /etc/snapper/configs/root
sudo sed -i "s/^TIMELINE_LIMIT_MONTHLY=.*/TIMELINE_LIMIT_MONTHLY=\"$TIMELINE_LIMIT_MONTHLY\"/" /etc/snapper/configs/root
sudo sed -i "s/^TIMELINE_LIMIT_YEARLY=.*/TIMELINE_LIMIT_YEARLY=\"$TIMELINE_LIMIT_YEARLY\"/" /etc/snapper/configs/root

# enable and start services
sudo systemctl enable --now snapper-timeline.timer &> /dev/null # automatic snapshot timeline
sudo systemctl enable --now snapper-cleanup.timer &> /dev/null  # periodically clean up older snapshots

# check if 'locate' is installed
if ! command -v updatedb &> /dev/null; then
  # install 'mlocate' package
  sudo pacman -S --noconfirm mlocate &> /dev/null
fi

# add .snapshots to PRUNENAMES in updatedb configuration file
sudo sed -i "/^PRUNENAMES/s/\"$/ .snapshots\"/" /etc/updatedb.conf

# update the database
sudo updatedb &> /dev/null


# grub-btrfs
# install 'grub-btrfs' package
sudo pacman -S --noconfirm grub-btrfs inotify-tools &> /dev/null

# set the GRUB configuration directory
sudo sed -i "s|^GRUB_BTRFS_GRUB_DIRNAME=.*|GRUB_BTRFS_GRUB_DIRNAME=\"/esp/grub\"|" /etc/default/grub-btrfs/config

# enable grub-btrfs.path to auto-regenerate grub-btrfs.cfg whenever a modification appears in /.snapshots
sudo systemctl enable --now grub-btrfs.path &> /dev/null

# read only snapshots and overlayfs
sudo sed -i "/^HOOKS=/ s/)/ grub-btrfs-overlayfs)/" /etc/mkinitcpio.conf
sudo mkinitcpio -P &> /dev/null

