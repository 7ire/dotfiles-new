#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
aur=$1

# Install GNOME
sudo pacman -S --noconfirm gdm gnome-shell gnome-keybindings power-profiles-daemon &> /dev/null
# Install XDG packages
sudo pacman -S --noconfirm xdg-user-dirs xdg-desktop-portal xdg-user-dirs-gtk xdg-desktop-portal-gnome &> /dev/null
# Install authentications packages
sudo pacman -S --noconfirm polkit polkit-gnome gnome-keyring &> /dev/null


# Configure GDM and GNOME Shell
# Disable GDM rule
sudo ln -sf /dev/null /etc/udev/rules.d/61-gdm.rules
# Enable Wayland in GDM
sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=true/' /etc/gdm/custom.conf

# GNOME Keybinds
KEYS_GNOME_WM=/org/gnome/desktop/wm/keybindings
KEYS_GNOME_SHELL=/org/gnome/shell/keybindings
KEYS_MUTTER=/org/gnome/mutter/keybindings
KEYS_MEDIA=/org/gnome/settings-daemon/plugins/media-keys
KEYS_MUTTER_WAYLAND_RESTORE=/org/gnome/mutter/wayland/keybindings/restore-shortcuts

# Reset conflict shortcut
dconf write ${KEYS_GNOME_SHELL}/switch-to-application-1 "@as []" &> /dev/null
dconf write ${KEYS_GNOME_SHELL}/switch-to-application-2 "@as []" &> /dev/null
dconf write ${KEYS_GNOME_SHELL}/switch-to-application-3 "@as []" &> /dev/null
dconf write ${KEYS_GNOME_SHELL}/switch-to-application-4 "@as []" &> /dev/null
dconf write ${KEYS_GNOME_SHELL}/switch-to-application-5 "@as []" &> /dev/null
dconf write ${KEYS_GNOME_SHELL}/switch-to-application-6 "@as []" &> /dev/null
dconf write ${KEYS_GNOME_SHELL}/switch-to-application-7 "@as []" &> /dev/null
dconf write ${KEYS_GNOME_SHELL}/switch-to-application-8 "@as []" &> /dev/null
dconf write ${KEYS_GNOME_SHELL}/switch-to-application-9 "@as []" &> /dev/null

# Motion
dconf write ${KEYS_GNOME_WM}/close "['<Super>q', '<Alt>F4']"  # Close Window

# Application
dconf write ${KEYS_MEDIA}/terminal "['<Super>t']"  # Launch terminal
dconf write ${KEYS_MEDIA}/www "['<Super>f']"       # Launch web browser
dconf write ${KEYS_MEDIA}/email "['<Super>m']"     # Launch email client
dconf write ${KEYS_MEDIA}/home "['<Super>e']"      # Home folder

dconf write ${KEYS_MEDIA}/screensaver "['<Super>Escape']"  # Lock screen

# Workspaces - move to N workspace
dconf write ${KEYS_GNOME_WM}/switch-to-workspace-1 "['<Super>1']" &> /dev/null  # Workspace 1
dconf write ${KEYS_GNOME_WM}/switch-to-workspace-2 "['<Super>2']" &> /dev/null  # Workspace 2
dconf write ${KEYS_GNOME_WM}/switch-to-workspace-3 "['<Super>3']" &> /dev/null  # Workspace 3
dconf write ${KEYS_GNOME_WM}/switch-to-workspace-4 "['<Super>4']" &> /dev/null  # Workspace 4
dconf write ${KEYS_GNOME_WM}/switch-to-workspace-5 "['<Super>5']" &> /dev/null  # Workspace 5
dconf write ${KEYS_GNOME_WM}/switch-to-workspace-6 "['<Super>6']" &> /dev/null  # Workspace 6
dconf write ${KEYS_GNOME_WM}/switch-to-workspace-7 "['<Super>7']" &> /dev/null  # Workspace 7
dconf write ${KEYS_GNOME_WM}/switch-to-workspace-8 "['<Super>8']" &> /dev/null  # Workspace 8
dconf write ${KEYS_GNOME_WM}/switch-to-workspace-9 "['<Super>9']" &> /dev/null  # Workspace 9

# Workspaces - move current application to N workspace
dconf write ${KEYS_GNOME_WM}/move-to-workspace-1 "['<Shift><Super>1']" &> /dev/null  # Move workspace 1
dconf write ${KEYS_GNOME_WM}/move-to-workspace-2 "['<Shift><Super>2']" &> /dev/null  # Move workspace 2
dconf write ${KEYS_GNOME_WM}/move-to-workspace-3 "['<Shift><Super>3']" &> /dev/null  # Move workspace 3
dconf write ${KEYS_GNOME_WM}/move-to-workspace-4 "['<Shift><Super>4']" &> /dev/null  # Move workspace 4
dconf write ${KEYS_GNOME_WM}/move-to-workspace-5 "['<Shift><Super>5']" &> /dev/null  # Move workspace 5
dconf write ${KEYS_GNOME_WM}/move-to-workspace-6 "['<Shift><Super>6']" &> /dev/null  # Move workspace 6
dconf write ${KEYS_GNOME_WM}/move-to-workspace-7 "['<Shift><Super>7']" &> /dev/null  # Move workspace 7
dconf write ${KEYS_GNOME_WM}/move-to-workspace-8 "['<Shift><Super>8']" &> /dev/null  # Move workspace 8
dconf write ${KEYS_GNOME_WM}/move-to-workspace-9 "['<Shift><Super>9']" &> /dev/null  # Move workspace 9

# Workspace - motion
dconf write ${KEYS_GNOME_WM}/switch-to-workspace-right "['<Alt><Super>Right']" &> /dev/null  # Move right
dconf write ${KEYS_GNOME_WM}/switch-to-workspace-left "['<Alt><Super>Left']" &> /dev/null    # Move left
dconf write ${KEYS_GNOME_WM}/switch-to-workspace-last "['<Super>0']" &> /dev/null            # Move last

# Application
# Base application
${aur} -S --noconfirm gnome-control-center gnome-tweaks mission-center extension-manager &> /dev/null
# Default application
${aur} -S kitty firefox thunderbird gnome-calculator gnome-calendar

# File explorer
${aur} -S --noconfirm nautilus sushi libnautilus-extension &> /dev/null
# File explorer - addons
${aur} -S --noconfirm nautilus-image-converter nautilus-share seahorse-nautilus &> /dev/null
${aur} -S --noconfirm turtle-git caja-open-any-terminal nautilus-open-in-code folder-color-nautilus ffmpeg-audio-thumbnailer nautilus-send-to-bluetooth &> /dev/null

# Add kitty as "Open in terminal ..."
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty
















# base gnome packages (minimal)
sudo pacman -S --noconfirm gdm gnome-shell gnome-keybindings power-profiles-daemon &> /dev/null
# Disable GDM rule
sudo ln -sf /dev/null /etc/udev/rules.d/61-gdm.rules
# Enable Wayland in GDM
sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=true/' /etc/gdm/custom.conf
# Enable GDM service
sudo systemctl enable gdm.service

# XDG packages
sudo pacman -S --noconfirm xdg-user-dirs xdg-desktop-portal xdg-user-dirs-gtk xdg-desktop-portal-gnome &> /dev/null

# Authentication pakcages
sudo pacman -S --noconfirm polkit polkit-gnome gnome-keyring &> /dev/null

# GNOME Keybinds
dconf write /org/gnome/desktop/wm/keybindings/close "['<Super>q', '<Alt>F4']" &> /dev/null

# Reset useless keybinds
dconf write /org/gnome/shell/keybindings/switch-to-application-1 "@as []" &> /dev/null
dconf write /org/gnome/shell/keybindings/switch-to-application-2 "@as []" &> /dev/null
dconf write /org/gnome/shell/keybindings/switch-to-application-3 "@as []" &> /dev/null
dconf write /org/gnome/shell/keybindings/switch-to-application-4 "@as []" &> /dev/null
dconf write /org/gnome/shell/keybindings/switch-to-application-5 "@as []" &> /dev/null
dconf write /org/gnome/shell/keybindings/switch-to-application-6 "@as []" &> /dev/null
dconf write /org/gnome/shell/keybindings/switch-to-application-7 "@as []" &> /dev/null
dconf write /org/gnome/shell/keybindings/switch-to-application-8 "@as []" &> /dev/null
dconf write /org/gnome/shell/keybindings/switch-to-application-9 "@as []" &> /dev/null

# Swith to N workspace
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-1 "['<Super>1']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-2 "['<Super>2']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-3 "['<Super>3']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-4 "['<Super>4']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-5 "['<Super>5']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-6 "['<Super>6']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-7 "['<Super>7']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-8 "['<Super>8']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-9 "['<Super>9']" &> /dev/null

# Switch current application to the N workspace
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-1 "['<Shift><Super>1']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-2 "['<Shift><Super>2']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-3 "['<Shift><Super>3']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-4 "['<Shift><Super>4']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-5 "['<Shift><Super>5']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-6 "['<Shift><Super>6']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-7 "['<Shift><Super>7']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-8 "['<Shift><Super>8']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-9 "['<Shift><Super>9']" &> /dev/null

dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-right "['<Alt><Super>Right']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-left "['<Alt><Super>Left']" &> /dev/null
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-last "['<Super>0']" &> /dev/null



# Applications
sudo pacman -S --noconfirm gnome-control-center gnome-tweaks mission-center extension-manager \
    kitty firefox thunderbird 

# GNOME Extensions
sudo pacman -S --noconfirm gnome-shell-extension-paperwm-git \ 
    gnome-shell-extension-blur-my-shell gnome-shell-extension-dash-to-dock \ 
    gnome-shell-extension-arc-menu gnome-shell-extension-appindicator gnome-shell-extension-just-perfection-desktop gnome-shell-extension-unite


# Bluetooth
sudo pacman -S --noconfirm bluez bluez-utils gnome-bluetooth-3.0