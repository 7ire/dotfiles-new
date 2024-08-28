#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
gpu=$1  # GPU type: 'intel' or 'nvidia'

# ==============================================================================
#                           INSTALL GPU DRIVERS
# ==============================================================================

case "$gpu" in
    intel)
        # Intel GPU drivers
        sudo pacman -S --noconfirm mesa lib32-mesa vulkan-intel lib32-vulkan-intel &> /dev/null
        ;;

    nvidia)
        # NVIDIA GPU drivers
        sudo pacman -S --noconfirm lib32-nvidia-utils nvidia-open-dkms nvidia-settings nvidia-utils opencl-nvidia &> /dev/null
        
        # Add necessary modules to mkinitcpio.conf
        sudo sed -i '/^MODULES=/ s/(\(.*\))/(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
        
        # Update GRUB configuration
        sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.modeset=1"/' /etc/default/grub
        
        # Create udev rule for NVIDIA
        sudo bash -c 'echo "ACTION==\"add\", DEVPATH==\"/bus/pci/drivers/nvidia\", RUN+=\"/usr/bin/nvidia-modprobe -c 0 -u\"" > /etc/udev/rules.d/70-nvidia.rules'
        
        # Add NVIDIA power management option
        sudo bash -c 'echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" > /etc/modprobe.d/nvidia-power-mgmt.conf'
        
        # Regenerate initramfs and update GRUB configuration
        sudo mkinitcpio -P &> /dev/null
        sudo grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null
        
        ;;

    *)
        exit 1
        ;;
esac