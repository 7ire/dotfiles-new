# 1 - System hardening

## Firewall

Install and Configure nftables.

**1. Install nftables**

   - **Install the nftables Package**:  
     This script begins by installing the `nftables` package using `pacman`, the package manager for Arch Linux. The `--noconfirm` flag ensures that the installation proceeds without prompting for user confirmation.

     ```bash
     sudo pacman -S --noconfirm nftables &> /dev/null
     ```

**2. Configure nftables**

   - **Define the Path to the nftables Configuration File**:  
     The configuration file for nftables is specified with the path `/etc/nftables.conf`. This file will be created or overwritten with the specified rules.

     ```bash
     NFTABLES_CONF="/etc/nftables.conf"
     ```

   - **Create or Overwrite the nftables Configuration File**:  
     The script uses a `here` document to write a set of nftables rules into the configuration file. These rules define a basic firewall setup:
     
     - **Table Definition**:  
       Creates or deletes a table named `filter` in the `inet` family.
     
     - **Input Chain**:  
       - Drops invalid packets.
       - Accepts established and related connections.
       - Accepts traffic from the loopback interface.
       - Allows ICMP and ICMPv6 packets.
       - Limits incoming packets to 5 per second, rejecting excessive requests with an administrative prohibited message.
     
     - **Forward Chain**:  
       - Drops all forwarded packets (default policy is `drop`).

     ```bash
     sudo bash -c "cat << EOF > $NFTABLES_CONF
     #!/usr/sbin/nft -f

     table inet filter
     delete table inet filter
     table inet filter {
       chain input {
         type filter hook input priority filter
         policy drop

         ct state invalid drop comment 'early drop of invalid connections'
         ct state {established, related} accept comment 'allow tracked connections'
         iifname lo accept comment 'allow from loopback'
         ip protocol icmp accept comment 'allow icmp'
         meta l4proto ipv6-icmp accept comment 'allow icmp v6'
         pkttype host limit rate 5/second counter reject with icmpx type admin-prohibited
         counter
       }

       chain forward {
         type filter hook forward priority filter
         policy drop
       }
     }
     EOF"
     ```

**3. Enable and Start Service**

   - **Enable and Start the nftables Service**:  
     Finally, the script enables and starts the `nftables` service using `systemctl`. This ensures that nftables is active and will start automatically on boot.

     ```bash
     sudo systemctl enable --now nftables &> /dev/null
     ```

## Kernel parameters

Configure Network Settings with Sysctl.

**1. Configure Sysctl Parameters**

   - **Define the Path to the Sysctl Configuration File**:  
     The script starts by defining the path to the sysctl configuration file where network settings will be applied. The file is named `90-network.conf` and is located in `/etc/sysctl.d/`.

     ```bash
     SYSCTL_CONF="/etc/sysctl.d/90-network.conf"
     ```

   - **Create or Overwrite the Sysctl Configuration File**:  
     The script then creates or overwrites the specified sysctl configuration file with a set of network-related parameters. These parameters are used to adjust kernel network settings:

     - **Disable IP Forwarding**:  
       Prevents the system from acting as a router by disabling IP forwarding for both IPv4 and IPv6.
       ```bash
       net.ipv4.ip_forward = 0
       net.ipv6.conf.all.forwarding = 0
       ```

     - **SYN Flood Protection**:  
       Enables SYN cookies to protect against SYN flood attacks, a type of denial-of-service (DoS) attack.
       ```bash
       net.ipv4.tcp_syncookies = 1
       ```

     - **Disable ICMP Redirects**:  
       Prevents the system from accepting or sending ICMP redirects, which can be used in certain network attacks.
       ```bash
       net.ipv4.conf.all.accept_redirects = 0
       net.ipv4.conf.default.accept_redirects = 0
       net.ipv4.conf.all.secure_redirects = 0
       net.ipv4.conf.default.secure_redirects = 0
       net.ipv6.conf.all.accept_redirects = 0
       net.ipv6.conf.default.accept_redirects = 0
       ```

     - **Disable Sending ICMP Redirects**:  
       Ensures the system does not send ICMP redirects.
       ```bash
       net.ipv4.conf.all.send_redirects = 0
       net.ipv4.conf.default.send_redirects = 0
       ```

     ```bash
     sudo bash -c "cat << EOF > $SYSCTL_CONF
     # Do not act as a router
     net.ipv4.ip_forward = 0
     net.ipv6.conf.all.forwarding = 0

     # SYN flood protection
     net.ipv4.tcp_syncookies = 1

     # Disable ICMP redirect
     net.ipv4.conf.all.accept_redirects = 0
     net.ipv4.conf.default.accept_redirects = 0
     net.ipv4.conf.all.secure_redirects = 0
     net.ipv4.conf.default.secure_redirects = 0
     net.ipv6.conf.all.accept_redirects = 0
     net.ipv6.conf.default.accept_redirects = 0

     # Do not send ICMP redirects
     net.ipv4.conf.all.send_redirects = 0
     net.ipv4.conf.default.send_redirects = 0
     EOF"
     ```

**2. Apply Sysctl Settings**

   - **Load the New Sysctl Settings**:  
     Finally, the script applies the new sysctl settings by reloading the configuration. This command makes the changes take effect immediately without requiring a system reboot.

     ```bash
     sudo sysctl --system &> /dev/null
     ```
