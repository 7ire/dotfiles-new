# 4 - Setup and Manage ZRAM Swap Device

**1. Create ZRAM Start Script**

   - **Create the ZRAM Start Script**:  
     This script creates a `zram_start` script located at `/usr/local/bin/zram_start`. This script is used to initialize and activate a ZRAM swap device with specified parameters.

     - **Disable zswap**:  
       If the `zswap` compression cache is active, it is disabled to avoid conflicts.

       ```bash
       echo 0 > /sys/module/zswap/parameters/enabled
       ```

     - **Turn Off All Active Swaps**:  
       The script turns off any existing swap devices to prepare for setting up ZRAM.

       ```bash
       swapoff --all
       ```

     - **Load ZRAM Module**:  
       Loads the `zram` module with one device.

       ```bash
       modprobe zram num_devices=1
       ```

     - **Set Compression Algorithm**:  
       Configures the compression algorithm for ZRAM (e.g., `zstd`).

       ```bash
       echo zstd > /sys/block/zram0/comp_algorithm
       ```

     - **Set ZRAM Disk Size**:  
       Sets the size of the ZRAM disk based on the input parameter `${swapsize}`.

       ```bash
       echo ${swapsize} > /sys/block/zram0/disksize
       ```

     - **Create and Activate ZRAM Swap Device**:  
       Initializes and activates the ZRAM swap device with high priority.

       ```bash
       mkswap --label zram0 /dev/zram0
       swapon --priority 32767 /dev/zram0
       ```

**2. Create ZRAM Stop Script**

   - **Create the ZRAM Stop Script**:  
     This script creates a `zram_stop` script located at `/usr/local/bin/zram_stop`. This script is used to deactivate and remove the ZRAM swap device.

     - **Deactivate and Reset ZRAM Device**:  
       Turns off the ZRAM swap device and resets it.

       ```bash
       swapoff /dev/zram0
       echo 1 > /sys/block/zram0/reset
       ```

     - **Unload ZRAM Module**:  
       Unloads the ZRAM module from the system.

       ```bash
       modprobe -r zram
       ```

**3. Make Scripts Executable**

   - **Set Executable Permissions**:  
     The script sets the executable permissions for both `zram_start` and `zram_stop` scripts.

     ```bash
     sudo chmod +x /usr/local/bin/zram_start &> /dev/null
     sudo chmod +x /usr/local/bin/zram_stop &> /dev/null
     ```

**4. Create and Enable Systemd Service**

   - **Create Systemd Service**:  
     This step creates a `zram-swap.service` file in `/etc/systemd/system/`. This service will automatically run the `zram_start` script on boot and allows the `zram_stop` script to be used to stop the service.

     ```bash
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
     ```

   - **Enable Systemd Service**:  
     Enables and starts the `zram-swap` service to ensure that it is active and set to start at boot.

     ```bash
     sudo systemctl enable zram-swap.service &> /dev/null
     ```

**5. Configure Kernel Parameters**

   - **View Current Kernel Parameters**:  
     Displays current values for various kernel parameters related to memory management and swap behavior.

     ```bash
     cat /proc/sys/vm/vfs_cache_pressure
     cat /proc/sys/vm/swappiness
     cat /proc/sys/vm/dirty_background_ratio
     sudo cat /proc/sys/vm/dirty_ratio
     ```

   - **Set New Kernel Parameters**:  
     Updates kernel parameters to optimize performance for using ZRAM. The parameters are configured in `/etc/sysctl.d/99-zram.conf`.

     ```bash
     sudo tee /etc/sysctl.d/99-zram.conf > /dev/null << 'EOF'
     vm.vfs_cache_pressure=500
     vm.swappiness=100
     vm.dirty_background_ratio=1
     vm.dirty_ratio=50
     EOF
     ```

   - **Apply New Kernel Parameters**:  
     Applies the new kernel parameters without requiring a reboot.

     ```bash
     sudo sysctl --system &> /dev/null
     ```
