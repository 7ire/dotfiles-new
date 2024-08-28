# Step 0 - Preliminary phase

1. **Check UEFI Mode**  
   The command checks if the system is booted in UEFI mode by verifying the existence of the `/sys/firmware/efi/efivars` directory. If the directory is not found, it prints an error message and exits, assuming the system is in BIOS mode.

   ```bash
   if [ ! -d /sys/firmware/efi/efivars ]; then
     echo "BIOS mode detected! UEFI is required for this script."
     exit 1
   fi
   ```

2. **Set Keyboard Layout**  
   Loads the specified keyboard layout using the `loadkeys` command, redirecting any output to `/dev/null` to suppress it.

   ```bash
   loadkeys $keyboard &> /dev/null
   ```

3. **Enable NTP**  
   Enables Network Time Protocol (NTP) to automatically synchronize the system clock.

   ```bash
   timedatectl set-ntp true &> /dev/null
   ```

4. **Update Arch Linux Keyring**  
   Installs the latest Arch Linux keyring package to ensure that package installations will not fail due to outdated keys.

   ```bash
   pacman -S --noconfirm archlinux-keyring &> /dev/null
   ```

5. **Initialize Pacman Keyring**  
   Initializes the `pacman` keyring, which is essential for verifying the authenticity of packages.

   ```bash
   pacman-key --init &> /dev/null
   ```

6. **Enable Parallel Downloads in Pacman**  
   Modifies the `pacman` configuration file to enable parallel downloads, which speeds up the package installation process.

   ```bash
   sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf &> /dev/null
   ```

7. **Refresh Pacman Package Database**  
   Updates the package database with the latest information from the configured mirrors.

   ```bash
   pacman -Syy &> /dev/null
   ```

8. **Install Essential Packages**  
   Installs essential packages like GPT fdisk, Btrfs utilities, and the GNU C library if they are not already installed.

   ```bash
   pacman -S --noconfirm --needed gptfdisk btrfs-progs glibc &> /dev/null
   ```

9. **Backup Current Mirror List**  
   Creates a backup of the existing `pacman` mirror list to preserve the current configuration before making changes.

   ```bash
   cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup &> /dev/null
   ```

10. **Update Mirror List**  
    Uses the `reflector` tool to find the fastest `https` mirrors from Italy, France, and Germany that have been updated in the last six hours. The updated list is saved to the `pacman` mirror list file.

    ```bash
    reflector --country 'Italy,France,Germany' --protocol https --age 6 --sort rate --save /etc/pacman.d/mirrorlist &> /dev/null
    ```

11. **Refresh Pacman Database Again**  
    Refreshes the package database again after updating the mirror list to ensure that the latest mirror information is used.

    ```bash
    pacman -Syy &> /dev/null
    ```