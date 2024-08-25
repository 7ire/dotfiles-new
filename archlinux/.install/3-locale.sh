#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
timezone=$1  # Timezone (e.g., Europe/Rome)
hostname=$2  # System hostname (e.g., myarch)
lang=$3      # System language/locale (e.g., en_US.UTF-8)
keyboard=$4  # Keyboard layout (e.g., us, uk, de)

# ==============================================================================
#                        CONFIGURATION IN CHROOT ENVIRONMENT
# ==============================================================================

# Change root into the new system
arch-chroot /mnt /bin/bash << 'CHROOT_CMDS'

# ==============================================================================
#                                TIMEZONE SETUP
# ==============================================================================
# Set the system timezone
ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime &> /dev/null
# Synchronize hardware clock with system clock
hwclock --systohc &> /dev/null

# ==============================================================================
#                               HOSTNAME SETUP
# ==============================================================================
# Set the system hostname
echo "$hostname" > /etc/hostname

# Configure the /etc/hosts file for local hostname resolution
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${hostname}.localdomain ${hostname}
EOF

# ==============================================================================
#                                LOCALE SETUP
# ==============================================================================
# Uncomment the desired locale in /etc/locale.gen
sed -i "s/^#\(${lang}\)/\1/" /etc/locale.gen

# Set the system language/locale
echo "LANG=${lang}" > /etc/locale.conf

# Generate the locale configuration
locale-gen &> /dev/null

# ==============================================================================
#                            KEYMAP AND FONT SETUP
# ==============================================================================
# Set the console keymap
echo "KEYMAP=${keyboard}" > /etc/vconsole.conf

# Exit the chroot environment
exit
CHROOT_CMDS

