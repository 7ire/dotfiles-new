# Step 4 - Users configuration

1. **Set Root Password**  
   The script sets the root user's password to the value provided in the `rootpwd` parameter using the `chpasswd` command.

   ```bash
   echo "root:$rootpwd" | chpasswd &> /dev/null
   ```

2. **Create a New User**  
   The script adds a new user with the username provided in the `username` parameter. The user is added to the `wheel` group, which typically allows users to execute commands as root via `sudo`. The user's shell is set to Bash (`/bin/bash`). It then sets the password for this new user using the `userpwd` parameter.

   ```bash
   useradd -m -G wheel -s /bin/bash "$username" &> /dev/null
   echo "$username:$userpwd" | chpasswd &> /dev/null
   ```

3. **Configure Sudo Access**  
   The script modifies the `/etc/sudoers` file to enable members of the `wheel` group to use `sudo` for executing commands as root. This is done by uncommenting the line `%wheel ALL=(ALL:ALL) ALL`, which grants `sudo` privileges to all users in the `wheel` group.

   ```bash
   sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers &> /dev/null
   ```
