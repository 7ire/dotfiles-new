#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
# Size of the zram swap device
swapsize=$1

# ==============================================================================
#                           CREATE ZRAM START SCRIPT
# ==============================================================================
sudo tee /usr/local/bin/zram_start > /dev/null << EOF
#!/bin/bash

# Disable zswap if active
echo 0 > /sys/module/zswap/parameters/enabled

# Turn off all active swaps
swapoff --all

# Load zram module with 1 device
modprobe zram num_devices=1

# Set compression algorithm (e.g., 'zstd')
echo zstd > /sys/block/zram0/comp_algorithm

# Set the size of the zram disk
echo ${swapsize} > /sys/block/zram0/disksize

# Create and activate the zram swap device with high priority
mkswap --label zram0 /dev/zram0
swapon --priority 32767 /dev/zram0
EOF

# ==============================================================================
#                           CREATE ZRAM STOP SCRIPT
# ==============================================================================
sudo tee /usr/local/bin/zram_stop > /dev/null << EOF
#!/bin/bash

# Deactivate and reset the zram device
swapoff /dev/zram0
echo 1 > /sys/block/zram0/reset

# Unload the zram module
modprobe -r zram
EOF

# ==============================================================================
#                          MAKE SCRIPTS EXECUTABLE
# ==============================================================================
sudo chmod +x /usr/local/bin/zram_start &> /dev/null
sudo chmod +x /usr/local/bin/zram_stop &> /dev/null

# ==============================================================================
#                       CREATE AND ENABLE SYSTEMD SERVICE
# ==============================================================================
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

# ==============================================================================
#                           CONFIGURE KERNEL PARAMETERS
# ==============================================================================
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

# Apply the new kernel parameters
sudo sysctl --system &> /dev/null