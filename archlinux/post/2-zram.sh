#!/bin/bash

zramstart() {
  # Disable 'zswap'
  sudo bash -c "echo 0 > /sys/module/zswap/parameters/enabled"
  # Disable any active swaps
  sudo swapoff --all
  # Load the 'zram' module
  sudo modprobe zram num_devices=1
  # Set comprassion algorithm (example: 'zstd')
  sudo bash -c "echo zstd > /sys/block/zram0/comp_algorithm"
  # Set disk size - 'swapsize'
  sudo bash -c "echo ${swapsize} > /sys/block/zram0/disksize"
  # Activate 'zram0' device with the highest priority setting of '32767'
  sudo mkswap --label zram0 /dev/zram0
  sudo swapon --priority 32767 /dev/zram0
}

zramstop() {
  # Disable 'zram0' device
  sudo swapoff /dev/zram0
  # Free all memory formerly allocated to device and reset disksize to zero
  sudo bash -c "echo 1 > /sys/block/zram0/reset"
  # Unload the 'zram' module
  sudo modprobe -r zram
}

zramboot() {
  # Scrivi i comandi di zram_start in un file
  sudo tee /usr/local/bin/zram_start > /dev/null << 'EOF'
#!/bin/bash

# Disabilita 'zswap'
echo 0 > /sys/module/zswap/parameters/enabled

# Disabilita tutti gli swap attivi
swapoff --all

# Carica il modulo 'zram'
modprobe zram num_devices=1

# Imposta l'algoritmo di compressione (esempio: 'zstd')
echo zstd > /sys/block/zram0/comp_algorithm

# Imposta la dimensione del disco (modifica 'swapsize' con la dimensione desiderata)
swapsize=1024M  # Modifica questo valore con la dimensione desiderata
echo ${swapsize} > /sys/block/zram0/disksize

# Attiva il dispositivo 'zram0' con priorità massima '32767'
mkswap --label zram0 /dev/zram0
swapon --priority 32767 /dev/zram0
EOF

  # Rendi eseguibile lo script zram_start
  sudo chmod +x /usr/local/bin/zram_start

  # Scrivi i comandi di zram_stop in un file
  sudo tee /usr/local/bin/zram_stop > /dev/null << 'EOF'
#!/bin/bash

# Disabilita il dispositivo 'zram0'
swapoff /dev/zram0

# Libera tutta la memoria allocata al dispositivo e resetta la dimensione del disco a zero
echo 1 > /sys/block/zram0/reset

# Scarica il modulo 'zram'
modprobe -r zram
EOF

  # Rendi eseguibile lo script zram_stop
  sudo chmod +x /usr/local/bin/zram_stop

  # Crea il file di servizio systemd per gestire zram
  sudo tee /etc/systemd/system/zram-swap.service > /dev/null << 'EOF'
[Unit]
Description=Configure zram swap device
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/zram_start
ExecStop=/usr/local/bin/zram_stop
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

  # Abilita il servizio systemd per zram
  sudo systemctl enable zram-swap.service
}

zramkernel() {
  cat /proc/sys/vm/vfs_cache_pressure
  cat /proc/sys/vm/swappiness
  cat /proc/sys/vm/dirty_background_ratio
  sudo cat /proc/sys/vm/dirty_ratio

  sudo tee /etc/sysctl.d/99-zram.conf > /dev/null << 'EOF'
vm.vfs_cache_pressure=500
vm.swappiness=100
vm.dirty_background_ratio=1
vm.dirty_ratio=50
EOF
}