#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
# No parameters for this script, all actions are performed on the system.

# ==============================================================================
#                             INSTALL NFTABLES
# ==============================================================================
# Install the nftables package
sudo pacman -S --noconfirm nftables &> /dev/null

# ==============================================================================
#                       CONFIGURE NFTABLES
# ==============================================================================
# Define the path to the nftables configuration file
NFTABLES_CONF="/etc/nftables.conf"

# Create or overwrite the nftables configuration file with the specified rules
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

# ==============================================================================
#                          ENABLE AND START SERVICE
# ==============================================================================
# Enable and start the nftables service
sudo systemctl enable --now nftables &> /dev/null
