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

BASE_PKG=(
  gnome-control-center                # GNOME's main interface to configure various aspects of the desktop
  gnome-tweaks                        # Graphical interface for advanced GNOME 3 settings (Tweak Tool)
  mission-center                      # Monitor your CPU, Memory, Disk, Network and GPU usage
  extension-manager                   # A native tool for browsing, installing, and managing GNOME Shell Extensions
  dconf-editor                        # GSettings editor for GNOME
)

APP_PKG=(
  kitty                               # A modern, hackable, featureful, OpenGL-based terminal emulator
  firefox                             # Fast, Private & Safe Web Browser
  thunderbird                         # Standalone mail and news reader from mozilla.org
  gnome-calculator                    # GNOME Scientific calculator
  gnome-calendar                      # Simple and beautiful calendar application designed to perfectly fit the GNOME desktop
  gnome-text-editor                   # A simple text editor for the GNOME desktop
  gnome-disk-utility                  # Disk Management Utility for GNOME
  papers                              # Document viewer (PDF, PostScript, XPS, djvu, tiff, cbr, cbz, cb7, cbt)
  loupe                               # A simple image viewer for GNOME
  clapper                             # Modern and user-friendly media player
  fragments                           # BitTorrent client for GNOME
  amberol                             # Plays music, and nothing else
)

FILE_PKG=(
  nautilus                            # Default file manager for GNOME
  sushi                               # A quick previewer for Nautilus
  libnautilus-extension               # Extension interface for Nautilus
)

FILE_ADDON_PKG=(
  nautilus-image-converter            # Nautilus extension to rotate/resize image files
  nautilus-share                      # Nautilus extension to share folder using Samba
  seahorse-nautilus                   # PGP encryption and signing for Nautilus
  turtle                              # Manage your git repositories with easy-to-use dialogs in Nautilus
  nautilus-open-any-terminal          # Context-menu entry for opening other terminal in nautilus
  nautilus-open-in-code               # Open current directory in VSCode from Nautilus context menu
  folder-color-nautilus               # Change your folder color in Nautilus
  ffmpeg-audio-thumbnailer            # A minimal audio file thumbnailer for file managers, such as nautilus, dolphin, thunar, and nemo
)

OFFICE_PKG=(
  planify                             # Task manager with Todoist and Nextcloud support
  libreoffice-fresh                   # LibreOffice branch which contains new features and program enhancements
  libreoffice-extension-texmaths      # LaTeX equation editor for LibreOffice
  libreoffice-extension-writer2latex  # LibreOffice extensions for converting to and working with LaTeX in LibreOffice
  xmind                               # Brainstorming and Mind Mapping Software
)

# Install packages
${aur} -S --noconfirm "${BASE_PKG[@]}" &> /dev/null
${aur} -S --noconfirm "${APP_PKG[@]}" &> /dev/null
${aur} -S --noconfirm "${FILE_PKG[@]}" &> /dev/null
${aur} -S --noconfirm "${FILE_ADDON_PKG[@]}" &> /dev/null
${aur} -S --noconfirm "${OFFICE_PKG[@]}" &> /dev/null

# Add kitty as "Open in terminal ..."
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty


# GNOME Extensions
EXT_PKG=(
  gnome-shell-extension-paperwm-git                    # A gnome shell extension providing scrollable tiling of windows and per monitor workspaces
  gnome-shell-extension-blur-my-shell                  # Extension that adds a blur look to different parts of the GNOME Shell
  gnome-shell-extension-dash-to-dock                   # Move the dash out of the overview transforming it in a dock
  gnome-shell-extension-just-perfection-desktop        # Just Perfection GNOME Shell Desktop
  gnome-shell-extension-unite                          # Unite makes GNOME Shell look like Ubuntu Unity Shell
  gnome-shell-extension-rounded-window-corners-reborn  # A GNOME Shell extension that adds rounded corners for all windows
  gnome-shell-extension-alphabetical-grid-extension    # Restore the alphabetical ordering of the app grid, removed in GNOME 3.38
  gnome-shell-extensions                               # Extensions for GNOME shell, including classic mode
  gnome-shell-extension-arc-menu                       # Application menu extension for GNOME Shell
  gnome-shell-extension-appindicator                   # AppIndicator/KStatusNotifierItem support for GNOME Shell
  gnome-shell-extension-arch-update                    # Convenient indicator for Arch Linux updates in GNOME Shell
)

${aur} -S --noconfirm "${EXT_PKG[@]}" &> /dev/null

# Wallpaper


# ULauncher
${aur} -S --noconfirm ulauncher &> /dev/null

# Bluetooth
${aur} -S --noconfirm gnome-bluetooth-3.0 &> /dev/null

# Enable GDM service
sudo systemctl enable gdm.service