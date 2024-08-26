# Step 2 - System Installation and Base Configuration

1. **Install Base System**  
   The `pacstrap` command installs the base Arch Linux system, including essential packages such as development tools, the Linux kernel, firmware, and optional packages for CPU microcode, Btrfs, and disk encryption. This is done on the root partition mounted at `/mnt`.

   ```bash
   pacstrap /mnt base base-devel ${microcode} linux-firmware linux-zen linux-zen-headers ${is_btrfs} ${is_crypt} &> /dev/null
   ```

2. **Generate Filesystem Table (fstab)**  
   The `genfstab` command generates a filesystem table (`fstab`) for the newly installed system, using UUIDs for the partitions. The output is appended to the `/mnt/etc/fstab` file, which will be used to mount filesystems during boot.

   ```bash
   genfstab -U -p /mnt >> /mnt/etc/fstab &> /dev/null
   ```

3. **Set System Timezone**  
   The `ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime` command sets the system's timezone by creating a symbolic link from the specified timezone file to `/etc/localtime`.

   ```bash
   ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime &> /dev/null
   ```

4. **Synchronize Hardware Clock with System Clock**  
   The `hwclock --systohc` command synchronizes the hardware clock with the system clock, ensuring that the time is accurate across reboots.

   ```bash
   hwclock --systohc &> /dev/null
   ```

5. **Set System Hostname**  
   The `echo "$hostname" > /etc/hostname` command sets the system's hostname, which will identify the computer on a network.

   ```bash
   echo "$hostname" > /etc/hostname
   ```

6. **Configure Hosts File**  
   The `cat > /etc/hosts` block configures the `/etc/hosts` file to resolve the local hostname. This includes mapping `localhost` to both IPv4 and IPv6 addresses and setting up the hostname resolution for the local domain.

   ```bash
   cat > /etc/hosts << EOF
   127.0.0.1   localhost
   ::1         localhost
   127.0.1.1   ${hostname}.localdomain ${hostname}
   EOF
   ```

7. **Configure Locale**  
   The `sed` and `locale-gen` commands uncomment the specified locale in `/etc/locale.gen` and generate the locale configuration. The `locale.conf` file is also created to set the system language.

   ```bash
   sed -i "s/^#\(${lang}\)/\1/" /etc/locale.gen
   echo "LANG=${lang}" > /etc/locale.conf
   locale-gen &> /dev/null
   ```

8. **Set Console Keymap**  
   The `echo "KEYMAP=${keyboard}" > /etc/vconsole.conf` command sets the console keymap, which defines the keyboard layout for the console.

   ```bash
   echo "KEYMAP=${keyboard}" > /etc/vconsole.conf
   ```

9. **Create Keyfile for Disk Encryption (If Encryption is Enabled)**  
   The `dd` command generates a keyfile named `key.bin` containing 512 bytes of random data. This keyfile is used for disk encryption and is secured by setting restrictive permissions.

   ```bash
   dd bs=512 count=4 iflag=fullblock if=/dev/random of=/key.bin &> /dev/null
   chmod 600 /key.bin &> /dev/null
   ```

10. **Add Keyfile to LUKS (If Encryption is Enabled)**  
    The `cryptsetup luksAddKey` command adds the generated keyfile to the LUKS-encrypted partition, allowing the system to use this keyfile for unlocking the encrypted disk.

    ```bash
    cryptsetup luksAddKey "${disk}p2" /key.bin &> /dev/null
    ```

11. **Configure Filesystem in `mkinitcpio`**  
    If the filesystem is Btrfs, the `sed` command modifies the `mkinitcpio.conf` file to include the Btrfs module. This ensures the system can mount Btrfs filesystems during the boot process.

    ```bash
    if [ "$fs_type" = "btrfs" ]; then
        sed -i '/^MODULES=/ s/)/ btrfs)/' /etc/mkinitcpio.conf &> /dev/null
    fi
    ```

12. **Configure Initramfs Hooks**  
    Depending on whether encryption is enabled, the `sed` commands adjust the hooks in `mkinitcpio.conf`. Hooks like `encrypt`, `keymap`, and `filesystems` are included to ensure the initramfs (initial ramdisk) can handle encrypted filesystems and other essential tasks during boot.

    ```bash
    if [ "$is_enc" = "True" ]; then
        sed -i '/^FILES=/ s/)/ \/key.bin)/' /etc/mkinitcpio.conf &> /dev/null
        sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect keymap consolefont modconf block encrypt filesystems fsck)/' /etc/mkinitcpio.conf &> /dev/null
    else
        sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect keymap consolefont modconf block filesystems fsck)/' /etc/mkinitcpio.conf &> /dev/null
    fi
    ```

13. **Generate Initial Ramdisk Environment (`initramfs`)**  
    The `mkinitcpio -P` command regenerates the initial ramdisk environment, incorporating the specified modules and hooks. This step is crucial for the system to boot correctly with the configured settings.

    ```bash
    mkinitcpio -P &> /dev/null
    ```
