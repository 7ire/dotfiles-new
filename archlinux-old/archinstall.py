import subprocess
import json
import sys
from rich.console import Console

# =============================================================================
#                            Constants
# =============================================================================
FILESYSTEMS = ["ext4", "btrfs"]
BOOTLOADERS = ["grub", "rEFInd", "systemd-boot"]

# =============================================================================
#                            Utility Functions
# =============================================================================
def read_cfg(file_path='archlinux.json'):
    """
    Reads the Arch Linux configuration from a JSON file.
    
    Args:
        file_path (str): Path to the configuration file.
    
    Returns:
        dict: Configuration data loaded from the JSON file.
    """
    with open(file_path, 'r') as file:
        data = json.load(file)
    return data

def printer(task_target, msg1, msg2):
    """
    Displays a loading animation and executes the given task.
    
    Args:
        task_target (function): Function to be executed.
        msg1 (str): Message to display while the task is running.
        msg2 (str): Message to display when the task is completed.
    
    Returns:
        The result of the task_target function.
    """
    console = Console()
    with console.status(f"[bold green]{msg1}..."):
        result = task_target()  # Execute the function
        console.log(f"[bold green]{msg2}, Completed!")
    return result

# =============================================================================
#                           Installer Script
# =============================================================================
def main():
    # Load Configuration
    arch_params = read_cfg()

    # Extract Parameters
    hostname = arch_params["hostname"]
    disk_params = arch_params["disk"]
    locale_params = arch_params["locale"]
    microcode = arch_params["microcode"]
    bootloader = arch_params["bootloader"]
    user_params = arch_params["user"]

    # Parameter Extraction
    disk_target = disk_params["target"]
    disk_fs = disk_params["filesystem"]
    disk_rnd_data = disk_params["fill_rnd_data"]
    disk_espsize = disk_params["espsize"]
    disk_cryptdev = disk_params["cryptdev"]
    disk_key = disk_params["cryptdev-pwd"]

    locale_lang = locale_params["lang"]
    locale_keyboard = locale_params["keymap"]
    locale_timezone = locale_params["timezone"]

    root_pwd = user_params["root-pwd"]
    username = user_params["username"]
    user_pwd = user_params["pass"]

    # Parameter Validation
    assert disk_fs in FILESYSTEMS, f"Filesystem must be one of {FILESYSTEMS}"
    assert isinstance(disk_cryptdev, bool), "disk_cryptdev must be a boolean"
    assert isinstance(disk_rnd_data, bool), "disk_rnd_data must be a boolean"
    assert bootloader in BOOTLOADERS, f"Bootloader must be one of {BOOTLOADERS}"

    # Display and Confirm Configuration
    console = Console()
    console.log(arch_params, log_locals=True)

    user_input = console.input("[bold yellow]Please review the configuration above. Do you want to continue with the installation? (y/n): [/bold yellow]")
    if user_input.lower() != 'y':
        sys.exit("Installation aborted by user.")

    # Start Installer Tasks
    # =============================================================================
    # ======================= STEP 0 - PREPARATION PHASE ==========================
    printer(
        lambda: subprocess.call(['./.install/0-preinstall.sh', locale_keyboard]), 
        "Preparing for installation", 
        "Installation preparation"
    )

    # ======================= STEP 1 - DISK PHASE =================================
    # Wipe data
    printer(
        lambda: subprocess.call(['./.install/1-disk/wipe.sh', disk_target]), 
        f"Wiping data from {disk_target}", 
        f"Data wiped from {disk_target}"
    )

    # Fill with random data (optional)
    if disk_rnd_data:
        printer(
            lambda: subprocess.call(['./.install/1-disk/rnd-data.sh', disk_target]), 
            f"Filling {disk_target} with random data", 
            f"Random data filled on {disk_target}"
        )

    # Disk Formatting
    if disk_fs == "btrfs":
        printer(
            lambda: subprocess.call(['./.install/1-disk/enc-btrfs.sh', disk_cryptdev, disk_target, disk_espsize, disk_key]), 
            f"Formatting {disk_target} as {disk_fs}", 
            f"{disk_target} formatted as {disk_fs}"
        )

    # ======================= STEP 2 - ARCH LINUX INSTALLATION ====================
    pacstrap_args = ['./.install/2-pacstrap.sh', microcode]
    if disk_fs == "btrfs":
        pacstrap_args.append('btrfs-progs')
        if disk_cryptdev:
            pacstrap_args.append('cryptsetup')

    printer(
        lambda: subprocess.call(pacstrap_args), 
        "Installing Arch Linux", 
        "Arch Linux installation"
    )

    # ======================= STEP 3 - CONFIGURE SYSTEM ===========================
    # Locale
    printer(
        lambda: subprocess.call(['./.install/3-locale.sh', locale_timezone, hostname, locale_lang, locale_keyboard]), 
        "Configuring base system", 
        "Base system configuration"
    )

    # Encrypted Disk Key File (optional)
    if disk_cryptdev:
        printer(
            lambda: subprocess.call(['./.install/4-mkinitcpio/key.sh', disk_fs]), 
            "Generating key file for encrypted disk", 
            "Key file generation"
        )

    # Generate Kernel (mkinitcpio)
    printer(
        lambda: subprocess.call(['./.install/4-mkinitcpio/mkinitcpio.sh', disk_cryptdev, disk_fs]), 
        "Generating kernel", 
        "Kernel generation"
    )

    # Bootloader Installation
    if bootloader == "grub":
        printer(
            lambda: subprocess.call(['./.install/5-bootloader/enc-grub.sh', disk_cryptdev, disk_target]), 
            "Installing GRUB bootloader", 
            "GRUB bootloader installation"
        )
    # Additional bootloaders can be added here as needed

    # ======================= STEP 4 - USER DECLARATION ===========================
    printer(
        lambda: subprocess.call(['./.install/6-user.sh', root_pwd, username, user_pwd]), 
        f"Setting up root and {username} users", 
        f"Root and {username} setup completed"
    )

    # ======================= STEP 5 - EXTRA TASKS ================================
    printer(
        lambda: subprocess.call(['./.install/7-extra.sh']), 
        "Installing extra base packages", 
        "Extra base packages installation"
    )

if __name__ == "__main__":
    main()
