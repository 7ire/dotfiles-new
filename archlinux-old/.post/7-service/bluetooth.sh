#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
# No parameters required for this script

# ==============================================================================
#                           INSTALL REQUIRED PACKAGES
# ==============================================================================
sudo pacman -S --noconfirm bluez bluez-utils bluez-tools bluez-cups &> /dev/null

# ==============================================================================
#                      CONFIGURE BLUETOOTH SETTINGS
# ==============================================================================

# Path to the Bluetooth configuration file
BLUETOOTH_CONF="/etc/bluetooth/main.conf"

# ==============================================================================
# Update ControllerMode to 'dual'
# ==============================================================================

# Check if ControllerMode is already set to 'dual' or commented out, and update it
if grep -q "^#*ControllerMode = dual" "$BLUETOOTH_CONF"; then
    sudo sed -i 's/^#*ControllerMode = dual/ControllerMode = dual/' "$BLUETOOTH_CONF"
else
    # If ControllerMode is not present, append it to the configuration file
    echo "ControllerMode = dual" | sudo tee -a "$BLUETOOTH_CONF" > /dev/null
fi

# ==============================================================================
# Enable Experimental Kernel Feature
# ==============================================================================

# Check if the [General] section exists
if grep -q "^\[General\]" "$BLUETOOTH_CONF"; then
    # Check if Experimental is set to false or commented out, and update it
    if grep -q "^#*Experimental = false" "$BLUETOOTH_CONF"; then
        sudo sed -i 's/^#*Experimental = false/Experimental = true/' "$BLUETOOTH_CONF"
    elif ! grep -q "^Experimental = true" "$BLUETOOTH_CONF"; then
        # If Experimental is not present, add it under the [General] section
        sudo sed -i '/^\[General\]/a Experimental = true' "$BLUETOOTH_CONF"
    fi
else
    # If the [General] section does not exist, append it with the Experimental setting
    echo -e "\n[General]\nExperimental = true" | sudo tee -a "$BLUETOOTH_CONF" > /dev/null
fi