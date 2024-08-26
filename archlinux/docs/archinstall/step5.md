# Step 5 - Additional steps

### 1. **Configure `pacman`**

   - **Enable Parallel Downloads and Color Output**:  
     The script modifies `/etc/pacman.conf` to enable parallel downloads, which speeds up package installation, and color output for better readability. Additionally, it adds a fun setting called "ILoveCandy" which gives a candy-themed progress bar when using `pacman`.

     ```bash
     sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
     sed -i 's/^#Color/Color/' /etc/pacman.conf
     sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
     ```

   - **Update Package Database**:  
     The script updates the package database using `pacman -Syy` to ensure that the latest package information is available.

     ```bash
     pacman -Syy &> /dev/null
     ```

### 2. **Install and Enable Essential Services**

   - **SSH Service**:  
     Installs the OpenSSH package and enables the SSH daemon (`sshd.service`) to start at boot, allowing remote access to the system via SSH.

     ```bash
     pacman -S --noconfirm openssh &> /dev/null
     systemctl enable sshd.service &> /dev/null
     ```

   - **NetworkManager**:  
     Installs NetworkManager, a tool to manage network connections, and enables its service to start at boot. It also enables the `NetworkManager-wait-online.service`, which ensures that network connections are established before other services that require network access start.

     ```bash
     pacman -S --noconfirm networkmanager &> /dev/null
     systemctl enable NetworkManager.service &> /dev/null
     systemctl enable NetworkManager-wait-online.service &> /dev/null
     ```

   - **Reflector**:  
     Installs and configures `Reflector`, a tool for updating the pacman mirrorlist by selecting the fastest mirrors based on the given criteria (country, protocol, etc.). The service and its timer are enabled to run automatically.

     ```bash
     pacman -S --noconfirm reflector &> /dev/null
     cat > /etc/xdg/reflector/reflector.conf <<EOF
     --country 'Italy,France,Germany'
     --protocol https
     --age 6
     --sort rate
     --save /etc/pacman.d/mirrorlist
     EOF
     systemctl enable reflector.service &> /dev/null
     systemctl enable reflector.timer &> /dev/null
     ```

   - **Paccache**:  
     Installs the `pacman-contrib` package, which includes `paccache`, a tool to clean the package cache. The service timer is enabled to automate the cleanup process.

     ```bash
     pacman -S --noconfirm pacman-contrib &> /dev/null
     systemctl enable paccache.timer &> /dev/null
     ```

### 3. **Install Additional Packages**

   - **Basic Utilities**:  
     Installs essential utilities like Neovim, sudo, bash-completion, man pages, Git, and common networking tools such as `curl`, `rsync`, and `wget`.

     ```bash
     pacman -S --noconfirm neovim sudo bash-completion man-db man-pages git curl rsync wget &> /dev/null
     ```

### 4. **Configure Environment Variables**

   - **Default Editor**:  
     Sets Neovim (`nvim`) as the default editor (`EDITOR`) and visual editor (`VISUAL`) by adding these settings to `/etc/environment`.

     ```bash
     echo "EDITOR=nvim" > /etc/environment
     echo "VISUAL=nvim" >> /etc/environment
     ```

### 5. **Enable Multilib Repository**

   - **Enable `multilib`**:  
     The script enables the multilib repository, which allows the installation of 32-bit software on a 64-bit system, by uncommenting the relevant lines in `/etc/pacman.conf`.

     ```bash
     sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
     ```
