# Step 3 - Bootloader

## GRUB

1. **Install GRUB Bootloader and Tools**  
   The `pacman` command installs the GRUB bootloader, EFI boot manager (`efibootmgr`), secure boot tools (`sbctl`), and support for NTFS filesystems (`ntfs-3g`).

   ```bash
   pacman -S --noconfirm grub efibootmgr sbctl ntfs-3g
   ```

2. **Backup GRUB Configuration**  
   The current GRUB configuration file (`/etc/default/grub`) is backed up to `/etc/default/grub.backup`, allowing you to restore the original settings if needed.

   ```bash
   cp /etc/default/grub /etc/default/grub.backup
   ```

3. **Modify GRUB Default Settings**  
   The `sed` commands modify the default GRUB configuration:
   - `GRUB_TIMEOUT=30`: Sets the timeout for the GRUB menu to 30 seconds.
   - `GRUB_DEFAULT=saved`: Ensures GRUB remembers the last booted entry.
   - `GRUB_SAVEDEFAULT=y`: Enables saving the last booted entry as the default.
   - `GRUB_DISABLE_SUBMENU=y`: Disables submenus in the GRUB menu.
   - `GRUB_DISABLE_OS_PROBER=false`: Enables OS Prober to detect other installed operating systems.

   ```bash
   sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=30/" /etc/default/grub
   sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub
   sed -i "s/^#GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=y/" /etc/default/grub
   sed -i "s/^#GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=y/" /etc/default/grub
   sed -i "s/^#GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
   ```

4. **Configure GRUB for Encrypted Disk (If Encryption is Enabled)**  
   If encryption is enabled (`is_enc=True`):
   - The script retrieves the UUID of the encrypted partition using `blkid`.
   - It then modifies the GRUB configuration to include the `cryptdevice` option, which specifies the encrypted partition to be unlocked at boot.
   - The necessary GRUB modules for encryption (`part_gpt`, `part_msdos`, `luks`) are preloaded, and cryptodisk support is enabled (`GRUB_ENABLE_CRYPTODISK=y`).

   ```bash
   uuid=$(blkid -s UUID -o value ${disk}p2)
   sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=$uuid:cryptdev\"/" /etc/default/grub
   sed -i "s/^GRUB_PRELOAD_MODULES=.*/GRUB_PRELOAD_MODULES=\"part_gpt part_msdos luks\"/" /etc/default/grub
   sed -i "s/^#GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/" /etc/default/grub
   ```

5. **Install GRUB to EFI System Partition**  
   The `grub-install` command installs the GRUB bootloader to the EFI system partition. It targets the `x86_64-efi` architecture, specifies the EFI directory as `/esp`, sets the bootloader ID to `GRUB`, includes the `tpm` module, and disables Shim Lock to avoid issues with Secure Boot.

   ```bash
   grub-install --target=x86_64-efi --efi-directory=/esp --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
   ```

6. **Generate GRUB Configuration File**  
   The `grub-mkconfig` command generates a new GRUB configuration file (`/boot/grub/grub.cfg`) based on the modified settings.

   ```bash
   grub-mkconfig -o /boot/grub/grub.cfg
   ```

7. **Configure Secure Boot**  
   If Secure Boot is enabled:
   - The `sbctl status` command displays the current status of Secure Boot.
   - The `sbctl create-keys` command generates Secure Boot signing keys, and `sbctl enroll-keys -m` enrolls them into the firmware.
   - The `sbctl sign` command signs the necessary boot files (`grubx64.efi`, `core.efi`, `grub.efi`, and the Linux kernel) with the enrolled keys to allow them to be loaded under Secure Boot.

   ```bash
   sbctl status
   sbctl create-keys && sbctl enroll-keys -m
   sbctl sign -s /boot/EFI/GRUB/grubx64.efi \
              -s /boot/grub/x86_64-efi/core.efi \
              -s /boot/grub/x86_64-efi/grub.efi \
              -s /boot/vmlinuz-linux-zen
   ```

## rEFInd

## systemd-bootloader
