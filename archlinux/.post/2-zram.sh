#!/usr/bin/env bash

# Parameters value
swapsize=$1

# =============================================================================

# create a script to start zram
sudo cat > /usr/local/bin/zram_start << EOF
#!/bin/bash

# Disable 'zswap'
echo 0 > /sys/module/zswap/parameters/enabled

# Disable any active swaps
swapoff --all

# Load module 'zram'
modprobe zram num_devices=1

# Set compression algorithm (example: 'zstd')
echo zstd > /sys/block/zram0/comp_algorithm

# Set disk size (example: 16G)
echo ${swapsize} > /sys/block/zram0/disksize

# Activate 'zram0' device with the highest priority setting of '32767'
mkswap --label zram0 /dev/zram0
swapon --priority 32767 /dev/zram0
EOF

# create a script to stop zram
sudo cat > /usr/local/bin/zram_stop << EOF
#!/bin/bash

# Deactivate 'zram0'
swapoff /dev/zram0

# Free all memory formerly allocated to device and reset 'disksize' to zero
echo 1 > /sys/block/zram0/reset

# Unload module 'zram'
modprobe -r zram
EOF

# make the scripts executable
sudo chmod +x /usr/local/bin/zram_start &> /dev/null
sudo chmod +x /usr/local/bin/zram_stop &> /dev/null


# create a systemd service file for zram
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
sudo systemctl enable zram-swap.service &> /dev/null

# kernel parameters
# show current values
cat /proc/sys/vm/vfs_cache_pressure
cat /proc/sys/vm/swappiness
cat /proc/sys/vm/dirty_background_ratio
sudo cat /proc/sys/vm/dirty_ratio

# set kernel parameters
sudo tee /etc/sysctl.d/99-zram.conf > /dev/null << 'EOF'
vm.vfs_cache_pressure=500
vm.swappiness=100
vm.dirty_background_ratio=1
vm.dirty_ratio=50
EOF