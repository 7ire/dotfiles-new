# 2 - BTRFS Snapshot

**1. Install and Configure Snapshot Tools**

   - **Install Snapper and Snap-pac**:  
     The script begins by installing `snapper` and `snap-pac` packages using `pacman`. These tools are used for managing and creating snapshots in Btrfs filesystems.

     ```bash
     sudo pacman -S --noconfirm snapper snap-pac &> /dev/null
     ```

   - **Define Path to Snapper Configuration File**:  
     Sets the path for the Snapper configuration file for the root subvolume.

     ```bash
     SNAPPER_CONF="/etc/snapper/configs/root"
     ```

   - **Unmount and Remove Existing Snapshots**:  
     Unmounts the existing snapshots directory and removes it, ensuring that old configurations do not interfere with the new setup.

     ```bash
     sudo umount /.snapshots &> /dev/null
     sudo rm -rf /.snapshots &> /dev/null
     ```

   - **Create New Snapper Configuration**:  
     Creates a new Snapper configuration for the root subvolume and removes any pre-existing snapshot subvolume.

     ```bash
     sudo snapper -c root create-config / &> /dev/null
     sudo btrfs subvolume delete .snapshots &> /dev/null
     ```

   - **Re-create and Mount the Snapshots Directory**:  
     Recreates the `.snapshots` directory and mounts it, then sets appropriate permissions.

     ```bash
     sudo mkdir /.snapshots &> /dev/null
     sudo mount -a &> /dev/null
     sudo chmod 750 /.snapshots &> /dev/null
     sudo chown :wheel /.snapshots &> /dev/null
     ```

**2. Modify Snapper Configuration**

   - **Update Snapper Configuration File**:  
     Adjusts Snapper settings in the configuration file to set the minimum age of snapshots and limits for hourly, daily, weekly, monthly, and yearly snapshots.

     ```bash
     sudo sed -i "s/^ALLOW_USERS=.*/ALLOW_USERS=\"$user\"/" $SNAPPER_CONF
     sudo sed -i "s/^TIMELINE_MIN_AGE=.*/TIMELINE_MIN_AGE=\"$TIMELINE_MIN_AGE\"/" $SNAPPER_CONF
     sudo sed -i "s/^TIMELINE_LIMIT_HOURLY=.*/TIMELINE_LIMIT_HOURLY=\"$TIMELINE_LIMIT_HOURLY\"/" $SNAPPER_CONF
     sudo sed -i "s/^TIMELINE_LIMIT_DAILY=.*/TIMELINE_LIMIT_DAILY=\"$TIMELINE_LIMIT_DAILY\"/" $SNAPPER_CONF
     sudo sed -i "s/^TIMELINE_LIMIT_WEEKLY=.*/TIMELINE_LIMIT_WEEKLY=\"$TIMELINE_LIMIT_WEEKLY\"/" $SNAPPER_CONF
     sudo sed -i "s/^TIMELINE_LIMIT_MONTHLY=.*/TIMELINE_LIMIT_MONTHLY=\"$TIMELINE_LIMIT_MONTHLY\"/" $SNAPPER_CONF
     sudo sed -i "s/^TIMELINE_LIMIT_YEARLY=.*/TIMELINE_LIMIT_YEARLY=\"$TIMELINE_LIMIT_YEARLY\"/" $SNAPPER_CONF
     ```

**3. Enable and Start Services**

   - **Enable and Start Snapper Services**:  
     Enables and starts systemd timers for Snapper’s timeline and cleanup tasks to automate snapshot management.

     ```bash
     sudo systemctl enable --now snapper-timeline.timer &> /dev/null
     sudo systemctl enable --now snapper-cleanup.timer &> /dev/null
     ```

**4. Check and Install Locate**

   - **Check and Install `mlocate`**:  
     If `updatedb` is not available, installs `mlocate`, which provides the `locate` command for fast file searches.

     ```bash
     if ! command -v updatedb &> /dev/null; then
         sudo pacman -S --noconfirm mlocate &> /dev/null
     fi
     ```

   - **Update `updatedb` Configuration**:  
     Adds `.snapshots` to the `PRUNENAMES` configuration in `updatedb` to exclude snapshots from being indexed.

     ```bash
     sudo sed -i "/^PRUNENAMES/s/\"$/ .snapshots\"/" /etc/updatedb.conf
     ```

   - **Update the Locate Database**:  
     Runs `updatedb` to refresh the file database with the new configuration.

     ```bash
     sudo updatedb &> /dev/null
     ```

**5. Install and Configure GRUB-Btrfs**

   - **Install `grub-btrfs` and `inotify-tools`**:  
     Installs `grub-btrfs`, which helps GRUB work with Btrfs snapshots, and `inotify-tools`, which monitors file system events.

     ```bash
     sudo pacman -S --noconfirm grub-btrfs inotify-tools &> /dev/null
     ```

   - **Configure GRUB-Btrfs**:  
     Sets the GRUB configuration directory for `grub-btrfs` and ensures it automatically regenerates the GRUB configuration file on changes.

     ```bash
     sudo sed -i "s|^GRUB_BTRFS_GRUB_DIRNAME=.*|GRUB_BTRFS_GRUB_DIRNAME=\"/esp/grub\"|" /etc/default/grub-btrfs/config
     sudo systemctl enable --now grub-btrfs.path &> /dev/null
     ```

   - **Configure mkinitcpio for OverlayFS**:  
     Modifies the `mkinitcpio` configuration to include the `grub-btrfs-overlayfs` hook and regenerates the initial RAM disk image.

     ```bash
     sudo sed -i "/^HOOKS=/ s/)/ grub-btrfs-overlayfs)/" /etc/mkinitcpio.conf
     sudo mkinitcpio -P &> /dev/null
     ```
