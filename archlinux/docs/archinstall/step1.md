# Step 1 - Disk formatting

1. **Wipe Existing Filesystem Signatures**  
   The `wipefs` command removes all existing filesystem signatures from the specified disk, effectively wiping the disk to ensure no remnants of previous data remain.

   ```bash
   wipefs -af $disk &> /dev/null
   ```

2. **Clear Partition Table and Reset Disk**  
   The `sgdisk --zap-all --clear` command erases the partition table on the disk, resetting it to a fresh state. This removes all existing partitions and prepares the disk for new partitioning.

   ```bash
   sgdisk --zap-all --clear $disk &> /dev/null
   ```

3. **Inform OS of Disk Layout Changes**  
   The `partprobe` command informs the operating system of changes made to the disk layout. This is necessary to ensure that the OS recognizes the new partitioning scheme.

   ```bash
   partprobe $disk &> /dev/null
   ```

4. **Create Temporary Encrypted Device**  
   The `cryptsetup open --type plain -d /dev/urandom $disk target` command creates a temporary encrypted device using randomness from `/dev/urandom`. This encrypted device will later be filled with random data for added security.

   ```bash
   cryptsetup open --type plain -d /dev/urandom $disk target &> /dev/null
   ```

5. **Set Exit Trap for Closing Crypt Device**  
   The `trap` command ensures that the encrypted device is automatically closed if the script exits, either successfully or due to an error. This prevents the device from being left open unintentionally.

   ```bash
   trap 'cryptsetup close target' EXIT
   ```

6. **Fill Encrypted Device with Zeros**  
   The `dd` command fills the entire encrypted device with zeros, effectively overwriting any existing data on the disk.

   ```bash
   dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct &> /dev/null
   ```

7. **Close Encrypted Device**  
   The `cryptsetup close target` command closes the encrypted device, removing the temporary mapping.

   ```bash
   cryptsetup close target &> /dev/null
   ```

8. **Remove Exit Trap**  
   The `trap - EXIT` command removes the previously set exit trap since the encrypted device has already been closed.

   ```bash
   trap - EXIT
   ```

## File System - ext4

## File System - BTRFS

1. **Create EFI System and Root Partitions**  
   The `sgdisk` commands create two partitions: the EFI System Partition (ESP) and the root partition. The ESP is formatted as FAT32 and is used by the UEFI firmware to store boot files, while the root partition holds the operating system files.

   ```bash
   sgdisk -n 0:0:+${espsize} -t 0:ef00 -c 0:ESP $disk &> /dev/null  # ESP
   sgdisk -n 0:0:0 -t 0:8300 -c 0:rootfs $disk &> /dev/null         # Root
   ```

2. **Change Partition Type for Encryption (If Enabled)**  
    If encryption is enabled, the `sgdisk -t 2:8309` command changes the type of the second partition to LUKS, preparing it for encryption.

    ```bash
    if [ "$is_enc" = "True" ]; then
        sgdisk -t 2:8309 $disk &> /dev/null
    fi
    ```

3. **Encrypt Root Partition (If Enabled)**  
    If encryption is enabled, the `cryptsetup luksFormat` command encrypts the root partition using the provided key. The partition is then opened and mapped to `/dev/mapper/cryptdev`.

    ```bash
    if [ "$is_enc" = "True" ]; then
        echo -n "$key" | cryptsetup --type luks2 -v -y luksFormat ${disk}p2 --key-file=- &> /dev/null
        echo -n "$key" | cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent ${disk}p2 cryptdev --key-file=- &> /dev/null
    fi
    ```

4. **Format EFI System Partition as FAT32**  
    The `mkfs.vfat` command formats the EFI System Partition (ESP) as FAT32, which is the required format for EFI partitions.

    ```bash
    mkfs.vfat -F32 -n ESP ${disk}p1 &> /dev/null
    ```

5. **Format Root Partition as Btrfs**  
    The `mkfs.btrfs` command formats the root partition (whether encrypted or not) as Btrfs, a modern filesystem that supports advanced features like subvolumes and snapshots.

    ```bash
    mkfs.btrfs -L archlinux $root_device &> /dev/null
    ```

6. **Mount Root Device**  
    The `mount` command mounts the root partition to `/mnt` to prepare it for the creation of subvolumes.

    ```bash
    mount $root_device /mnt &> /dev/null
    ```

7. **Create Btrfs Subvolumes**  
    The `btrfs subvolume create` commands create various subvolumes on the root partition. Subvolumes help segregate system data and user data, making it easier to manage and back up.

    ```bash
    btrfs subvolume create /mnt/@ &> /dev/null           # Main system subvolume
    btrfs subvolume create /mnt/@home &> /dev/null       # Home directory subvolume
    btrfs subvolume create /mnt/@snapshots &> /dev/null  # Snapshots subvolume
    btrfs subvolume create /mnt/@cache &> /dev/null      # Cache subvolume
    btrfs subvolume create /mnt/@libvirt &> /dev/null    # Libvirt subvolume
    btrfs subvolume create /mnt/@log &> /dev/null        # Log files subvolume
    btrfs subvolume create /mnt/@tmp &> /dev/null        # Temporary files subvolume
    ```

8. **Unmount Root Device**  
    The `umount` command unmounts the root partition after subvolumes have been created, preparing it for remounting with specific options.

    ```bash
    umount /mnt &> /dev/null
    ```

9. **Create Mount Points for Additional Subvolumes**  
    The `mkdir -p` command creates the necessary directories for mounting additional subvolumes such as `home`, `snapshots`, `cache`, etc.

    ```bash
    mkdir -p /mnt/{home,.snapshots,var/cache,var/lib/libvirt,var/log,var/tmp} &> /dev/null
    ```

10. **Remount with Subvolumes and Options**  
    The `mount` commands remount the root partition and its subvolumes with specific options for performance and reliability. For example, `compress-force=zstd:1` enables transparent compression.

    ```bash
    mount -o ${sv_opts},subvol=@ $root_device /mnt &> /dev/null
    mount -o ${sv_opts},subvol=@home $root_device /mnt/home &> /dev/null
    mount -o ${sv_opts},subvol=@snapshots $root_device /mnt/.snapshots &> /dev/null
    mount -o ${sv_opts},subvol=@cache $root_device /mnt/var/cache &> /dev/null
    mount -o ${sv_opts},subvol=@libvirt $root_device /mnt/var/lib/libvirt &> /dev/null
    mount -o ${sv_opts},subvol=@log $root_device /mnt/var/log &> /dev/null
    mount -o ${sv_opts},subvol=@tmp $root_device /mnt/var/tmp &> /dev/null
    ```
