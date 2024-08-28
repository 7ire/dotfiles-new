# 0 - Preliminary phase

### 1. **After installation and check system status**

   - **Update Packages and Sync Databases**:  
     The script updates all installed packages on the system and synchronizes the package databases to ensure everything is up to date. The `--noconfirm` flag automatically answers 'yes' to any prompts, making the update process unattended.

     ```bash
     sudo pacman -Syyu --noconfirm &> /dev/null
     ```

   - **Check for Failed Services**:  
     The script uses `systemctl --failed` to list any services that have failed to start or have encountered errors. This command is useful for diagnosing issues with system services.

     ```bash
     systemctl --failed
     ```

   - **Review System Logs for Critical Errors**:  
     The script reviews the system logs for any critical errors using `journalctl -p 3 -xb`, where `-p 3` filters for priority 3 (errors) and `-xb` restricts the output to the current boot. This helps in identifying any significant issues that might require attention.

     ```bash
     journalctl -p 3 -xb
     ```

### 2. **Install and Configure Utilities**

   - **Install `mlocate` and Update its Database**:  
     The script installs `mlocate`, which provides the `locate` command to quickly find files by name. After installation, it updates the database with `updatedb` to ensure that `locate` has the latest file information.

     ```bash
     sudo pacman -S --noconfirm mlocate &> /dev/null
     sudo updatedb &> /dev/null
     ```

   - **Install `pkgfile` and Update its Database**:  
     `pkgfile` is a utility that provides information about which package a specific file belongs to. It's particularly useful for enabling command-not-found functionality, which suggests installing packages that provide missing commands. After installing `pkgfile`, the script updates its database.

     ```bash
     sudo pacman -S --noconfirm pkgfile &> /dev/null
     sudo pkgfile --update &> /dev/null
     ```

   - **Add Command-Not-Found Support to Bash**:  
     The script checks if the `command-not-found` feature (enabled by `pkgfile`) is already present in the user's `.bashrc` file. If not, it appends the necessary code to `.bashrc` to enable this feature. This feature will suggest the installation of missing commands the next time the user types a command that is not found.

     ```bash
     BASHRC="$HOME/.bashrc"
     CONTENT='
     # Command-not-found support for pkgfile
     if [[ -f /usr/share/doc/pkgfile/command-not-found.bash ]]; then
         . /usr/share/doc/pkgfile/command-not-found.bash
     fi
     '

     if ! grep -q "/usr/share/doc/pkgfile/command-not-found.bash" "$BASHRC"; then
         echo "$CONTENT" >> "$BASHRC"
     fi
     ```
