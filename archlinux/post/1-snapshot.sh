#!/usr/bin/env bash



# -----------------------------------------------------------------------------
#                  System snapshot
# -----------------------------------------------------------------------------
# install 'snapper' and 'snap-pac'
sudo pacman -S --noconfirm snapper snap-pac

# unmount the subvolume and remove the mountpoint
sudo umount /.snapshots
sudo rm -rf /.snapshots

# create a new 'root' config
sudo snapper -c root create-config /

# delete the snapper-generated subvolume
sudo btrfs subvolume delete .snapshots

# re-create and re-mount /.snapshots mountpoint
sudo mkdir /.snapshots
sudo mount -a

# set permissions. Owner must be 'root', and I allow members of 'wheel' to browse through snapshots
sudo chmod 750 /.snapshots
sudo chown :wheel /.snapshots

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
sudo systemctl enable --now snapper-timeline.timer  # automatic snapshot timeline
sudo systemctl enable --now snapper-cleanup.timer   # periodically clean up older snapshots

# check if 'locate' is installed
if ! command -v updatedb &> /dev/null; then
  # install 'mlocate' package
  sudo pacman -S --noconfirm mlocate
fi

# add .snapshots to PRUNENAMES in updatedb configuration file
sudo sed -i "/^PRUNENAMES/s/\"$/ .snapshots\"/" /etc/updatedb.conf

# update the database
sudo updatedb


# -----------------------------------------------------------------------------
#                  grub-btrfs
# -----------------------------------------------------------------------------
# install 'grub-btrfs' package
sudo pacman -S --noconfirm grub-btrfs inotify-tools

# set the GRUB configuration directory
sudo sed -i "s|^GRUB_BTRFS_GRUB_DIRNAME=.*|GRUB_BTRFS_GRUB_DIRNAME=\"/esp/grub\"|" /etc/default/grub-btrfs/config

# enable grub-btrfs.path to auto-regenerate grub-btrfs.cfg whenever a modification appears in /.snapshots
sudo systemctl enable --now grub-btrfs.path

# read only snapshots and overlayfs
sudo sed -i "/^HOOKS=/ s/)/ grub-btrfs-overlayfs)/" /etc/mkinitcpio.conf
sudo mkinitcpio -P

