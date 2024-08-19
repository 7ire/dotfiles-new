#!/bin/bash

base-system() {
  # install base packages
  pacstrap /mnt base base-devel ${microcode} linux-firmware linux-zen linux-zen-headers btrfs-progs cryptsetup

  # generate fstab
  genfstab -U -p /mnt >> /mnt/etc/fstab
}

configure-system() {
  # chroot base system
  arch-chroot /mnt /bin/bash

  # timezone
  ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime
  hwclock --systohc

  # hostname
  echo $hostname > /etc/hostname

  cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${hostname}.localdomain ${hostname}
EOF
  
  # locale
  sed -i "s/^#\(${locale}\)/\1/" /etc/locale.gen
  echo "LANG=${locale}" > /etc/locale.conf
  locale-gen

  # font and keymap
  echo "KEYMAP=${keyboard}" > /etc/vconsole.conf
}

keyfile() {
  # create keyfile 'key.bin' and restrict access to 'root'
  dd bs=512 count=4 iflag=fullblock if=/dev/random of=/key.bin
  chmod 600 /key.bin

  # add keyfile to LUKS
  cryptsetup luksAddKey ${disk}p2 /key.bin
}

mkinitcpio() {
  # Percorso del file di configurazione
  MKINITCPIO_CONF="/etc/mkinitcpio.conf"

  # Aggiungi la chiave al FILES
  if ! grep -q '^FILES=(' "$MKINITCPIO_CONF"; then
    echo "FILES=(/crypto_keyfile.bin)" >> "$MKINITCPIO_CONF"
  else
    sed -i '/^FILES=/ s/)/ \/crypto_keyfile.bin)/' "$MKINITCPIO_CONF"
  fi

  # Aggiungi il modulo btrfs al MODULES
  if ! grep -q '^MODULES=(' "$MKINITCPIO_CONF"; then
    echo "MODULES=(btrfs)" >> "$MKINITCPIO_CONF"
  else
    sed -i '/^MODULES=/ s/)/ btrfs)/' "$MKINITCPIO_CONF"
  fi

  # Imposta gli hook
  if ! grep -q '^HOOKS=(' "$MKINITCPIO_CONF"; then
    echo "HOOKS=(base udev keyboard autodetect keymap consolefont modconf block encrypt filesystems fsck)" >> "$MKINITCPIO_CONF"
  else
    sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect keymap consolefont modconf block encrypt filesystems fsck)/' "$MKINITCPIO_CONF"
  fi

  # Aggiorna initramfs
  mkinitcpio -P
}

bootloader() {
  pacman -S --noconfirm grub efibootmgr sbctl ntfs-3g

  # Determina l'UUID della partizione crittografata
  uuid=$(blkid -s UUID -o value ${disk}p2)

  # Controlla se il comando blkid ha restituito un UUID
  if [ -z "$uuid" ]; then
    echo "Errore: impossibile trovare l'UUID della partizione crittografata."
    exit 1
  fi

  echo "UUID della partizione crittografata trovato: $uuid"

  # Modifica /etc/default/grub
  grub_file="/etc/default/grub"

  # Backup del file grub
  # cp $grub_file ${grub_file}.backup

  # Imposta GRUB_CMDLINE_LINUX_DEFAULT con il nuovo valore
  sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=$uuid:cryptdev\"/" $grub_file

  # Imposta GRUB_PRELOAD_MODULES con i moduli richiesti
  sed -i "s/^GRUB_PRELOAD_MODULES=.*/GRUB_PRELOAD_MODULES=\"part_gpt part_msdos luks\"/" $grub_file

  # Abilita GRUB_ENABLE_CRYPTODISK
  sed -i "s/^#GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/" $grub_file

  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
  grub-mkconfig -o /boot/grub/grub.cfg
  sbctl status
  sbctl create-keys && sbctl enroll-keys -m
  sbctl sign -s /boot/EFI/GRUB/grubx64.efi && sbctl sign -s /boot/grub/x86_64-efi/core.efi && sbctl sign -s /boot/grub/x86_64-efi/grub.efi && sbctl sign -s /boot/vmlinuz-linux-zen
}