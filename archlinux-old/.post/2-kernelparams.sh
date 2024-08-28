#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
# No parameters are used in this script; it applies system-wide network settings.

# ==============================================================================
#                        CONFIGURE SYSCTL PARAMETERS
# ==============================================================================
# Define the path to the sysctl configuration file
SYSCTL_CONF="/etc/sysctl.d/90-network.conf"

# Create or overwrite the sysctl configuration file with the specified parameters
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

# ==============================================================================
#                             APPLY SYSCTL SETTINGS
# ==============================================================================
# Load the new sysctl settings
sudo sysctl --system &> /dev/null
