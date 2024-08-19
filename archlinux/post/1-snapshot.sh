#!/bin/bash

snapper() {
  # Install 'snapper' and 'snap-pac'
  sudo pacman -S --noconfirm snapper snap-pac
  # Unmount the subvolume and remove the mountpoint
  sudo umount /.snapshots
  sudo rm -rf /.snapshots
  # Create a new 'root' config
  sudo snapper -c root create-config /
  # Delete the snapper-generated subvolume
  sudo btrfs subvolume delete .snapshots
  # Re-create and re-mount /.snapshots mountpoint
  sudo mkdir /.snapshots
  sudo mount -a
  # Set permissions. Owner must be 'root', and I allow members of 'wheel' to browse through snapshots
  sudo chmod 750 /.snapshots
  sudo chown :wheel /.snapshots
}

auto-snapshot() {
  # Snapper configuration file
  local SNAPPER_CONF="/etc/snapper/configs/root"
  
  # Time parameters
  TIMELINE_MIN_AGE="1800"        # Minimum age of a snapshot in seconds
  TIMELINE_LIMIT_HOURLY="5"      # Limit of hourly snapshots
  TIMELINE_LIMIT_DAILY="7"       # Limit of daily snapshots
  TIMELINE_LIMIT_WEEKLY="0"      # Limit of weekly snapshots
  TIMELINE_LIMIT_MONTHLY="0"     # Limit of monthly snapshots
  TIMELINE_LIMIT_YEARLY="0"      # Limit of yearly snapshots

  # Modify the configuration file
  sudo sed -i "s/^ALLOW_USERS=.*/ALLOW_USERS=\"$USER\"/" $CONFIG_FILE
  sudo sed -i "s/^TIMELINE_MIN_AGE=.*/TIMELINE_MIN_AGE=\"$TIMELINE_MIN_AGE\"/" $CONFIG_FILE
  sudo sed -i "s/^TIMELINE_LIMIT_HOURLY=.*/TIMELINE_LIMIT_HOURLY=\"$TIMELINE_LIMIT_HOURLY\"/" $CONFIG_FILE
  sudo sed -i "s/^TIMELINE_LIMIT_DAILY=.*/TIMELINE_LIMIT_DAILY=\"$TIMELINE_LIMIT_DAILY\"/" $CONFIG_FILE
  sudo sed -i "s/^TIMELINE_LIMIT_WEEKLY=.*/TIMELINE_LIMIT_WEEKLY=\"$TIMELINE_LIMIT_WEEKLY\"/" $CONFIG_FILE
  sudo sed -i "s/^TIMELINE_LIMIT_MONTHLY=.*/TIMELINE_LIMIT_MONTHLY=\"$TIMELINE_LIMIT_MONTHLY\"/" $CONFIG_FILE
  sudo sed -i "s/^TIMELINE_LIMIT_YEARLY=.*/TIMELINE_LIMIT_YEARLY=\"$TIMELINE_LIMIT_YEARLY\"/" $CONFIG_FILE

  # Start and enable 'snapper-timeline.timer' to launch the automatic snapshot timeline
  sudo systemctl enable --now snapper-timeline.timer
  # Start and enable 'snapper-cleanup.timer' to periodically clean up older snapshots
  sudo systemctl enable --now snapper-cleanup.timer
}

updatedb() {
  # Updatedb configuration file
  local UPDATEDB_CONF="/etc/updatedb.conf"

  # Directory to exclude from updatedb
  local PRUNE_DIR=".snapshots"

  # Check if 'locate' is installed
  if ! command -v updatedb &> /dev/null; then
    # TODO: Error
    exit 1
  fi

  # Add the directory to PRUNENAMES if it doesn't already exist
  if grep -q "^PRUNENAMES.*$PRUNE_DIR" $UPDATEDB_CONF; then
    # TODO: Error
  else
    sudo sed -i "/^PRUNENAMES/s/\"$/ $PRUNE_DIR\"/" $UPDATEDB_CONF
    # TODO: Success
  fi
}

grub-btrfs() {
  # Install 'grub-btrfs' package
  sudo pacman -S grub-btrfs

  # grub-btrfs configuration file
  local GRUB_BTRFS_CONFIG="/etc/default/grub-btrfs/config"
  # Path of grub.cfg file
  local GRUB_DIR="/esp/grub"

  # Modify grub-btrfs configuration file to set the GRUB configuration directory
  if grep -q "^GRUB_BTRFS_GRUB_DIRNAME=" $GRUB_BTRFS_CONFIG; then
    # Se la variabile esiste già, sostituiscila con il nuovo percorso
    sudo sed -i "s|^GRUB_BTRFS_GRUB_DIRNAME=.*|GRUB_BTRFS_GRUB_DIRNAME=\"$GRUB_DIR\"|" $GRUB_BTRFS_CONFIG
  else
    # Se la variabile non esiste, aggiungila alla fine del file
    echo "GRUB_BTRFS_GRUB_DIRNAME=\"$GRUB_DIR\"" | sudo tee -a $GRUB_BTRFS_CONFIG > /dev/null
  fi

  echo "Configurazione completata. GRUB_BTRFS_GRUB_DIRNAME è stato impostato su $GRUB_DIR."

  # Enable grub-btrfs.path to auto-regenerate grub-btrfs.cfg 
  # whenever a modification appears in /.snapshots
  sudo systemctl enable --now grub-btrfs.path
}

overlayfs() {
  # Percorso del file di configurazione di mkinitcpio
  MKINITCPIO_CONF="/etc/mkinitcpio.conf"

  # Hook da aggiungere
  HOOK="grub-btrfs-overlayfs"

  # Controlla se l'hook è già presente in HOOKS
  if grep -q "$HOOK" $MKINITCPIO_CONF; then
    echo "L'hook $HOOK è già presente in HOOKS."
  else
    # Aggiungi l'hook alla fine della variabile HOOKS
    sudo sed -i "/^HOOKS=/ s/)/ $HOOK)/" $MKINITCPIO_CONF
    echo "L'hook $HOOK è stato aggiunto a HOOKS in $MKINITCPIO_CONF."
  fi

  # Rigenera l'initramfs
  sudo mkinitcpio -P

  echo "Configurazione completata. initramfs rigenerato con l'hook $HOOK."
}

