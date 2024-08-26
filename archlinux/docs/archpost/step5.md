# 5 - Install and Configure Printing Services**

**1. Install Required Packages**

   - **Install Printing and Bluetooth Packages**:  
     This script installs several packages necessary for setting up printing services on the system. It uses `pacman`, the package manager for Arch Linux, with the `--noconfirm` flag to automatically proceed with installation without prompting the user.

     - **`cups`**: The Common Unix Printing System, which provides a printing system for Unix-like operating systems.
     - **`bluez-cups`**: Provides support for Bluetooth printing via CUPS.
     - **`cups-pdf`**: A virtual PDF printer for CUPS that allows printing to PDF files.

     ```bash
     sudo pacman -S --noconfirm cups bluez-cups cups-pdf &> /dev/null
     ```

**2. Activate and Enable Services**

   - **Enable and Start CUPS Service**:  
     The script enables the CUPS (Common Unix Printing System) service to start automatically on boot and starts it immediately. This ensures that the printing service is active and ready to handle print jobs.

     ```bash
     sudo systemctl enable --now cups.service &> /dev/null
     ```
