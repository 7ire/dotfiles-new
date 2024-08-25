import subprocess
import json
import sys
from rich.console import Console


# =============================================================================
#                            Constants
# =============================================================================
FS_TYPES = ["ext4", "btrfs"]
AUR_HELPERS = ["yay", "paru"]


# =============================================================================
#                            Utility Functions
# =============================================================================
def read_cfg(file_path='archlinux.json'):
    """
    Read the Arch Linux configuration file.

    :param file_path: Path to the configuration file.
    :return: Parsed JSON data as a dictionary.
    """
    with open(file_path, 'r') as file:
        data = json.load(file)
    return data


def printer(task_target, msg1, msg2):
    """
    Output animation while the script is working.

    :param task_target: Function to execute as the task.
    :param msg1: Message to display while working.
    :param msg2: Message to display upon completion.
    :return: Result of the task function.
    """
    console = Console()
    with console.status(f"[bold green]{msg1}...") as status:
        result = task_target()  # Execute function
        console.log(f"[bold green]{msg2}, Completed!")
    return result


# =============================================================================
#                           Post Installer Script
# =============================================================================
def main():
    # Read JSON configuration
    arch_params = read_cfg()

    # Load configuration parameters
    is_ssd = arch_params["disk"]["is_ssd"]  # Is SSD the disk
    disk_fs = arch_params["disk"]["filesystem"]  # Disk filesystem type
    is_swap = arch_params["swap"]["enable"]  # Is swap enabled
    swap_size = arch_params["swap"]["size"]  # Size of swap
    aur_helper = arch_params["aur"]  # AUR Helper

    # Verify parameters
    assert isinstance(is_ssd, bool), "is_ssd must be a boolean"
    assert isinstance(is_swap, bool), "is_swap must be a boolean"
    assert disk_fs in FS_TYPES, f"Filesystem must be one of {FS_TYPES}"
    assert aur_helper in AUR_HELPERS, f"AUR helper must be one of {AUR_HELPERS}"

    # Start post-installation tasks
    # =============================================================================

    # ======================= STEP 0 - PRELIMINARY PHASE ==========================
    printer(lambda: subprocess.call(['./.post/0-prerequirements.sh']), "Preliminary phase", "Preliminary phase")

    # ======================= STEP 1 - FIREWALL HARDENING =========================
    printer(lambda: subprocess.call(['./.post/1-firewall.sh']), "Hardening firewall", "Firewall hardening")

    # ======================= STEP 2 - KERNEL HARDENING ===========================
    printer(lambda: subprocess.call(['./.post/2-kernelparams.sh']), "Hardening kernel", "Kernel hardening")

    # ======================= STEP 3 - BTRFS SNAPSHOTS ============================
    if disk_fs == "btrfs":
        printer(lambda: subprocess.call(['./.post/3-snapshot.sh']), "Generating snapshot for /", "Generation of snapshot for /")

    # ======================= STEP 4 - SSD IMPROVEMENTS ===========================
    if is_ssd:
        printer(lambda: subprocess.call(['./.post/4-ssd.sh']), "Improving SSD performance", "SSD improving")

    # ======================= STEP 5 - ZRAM =======================================
    if is_swap:
        printer(lambda: subprocess.call(['./.post/5-zram.sh', swap_size]), f"Configuring swap with ZRam = {swap_size}", "Configuring swap")

    # ======================= STEP 6 - AUR HELPER =================================
    if aur_helper == "yay":
        printer(lambda: subprocess.call(['./.post/6-aur/yay.sh']), "Installing AUR helper", "AUR helper installation")
    elif aur_helper == "paru":
        printer(lambda: subprocess.call(['./.post/6-aur/paru.sh']), "Installing AUR helper", "AUR helper installation")

    # ======================= STEP 7 - PRINTING SERVICE ===========================
    printer(lambda: subprocess.call(['./.post/7-cups.sh']), "Configuring printer service", "Configuration of printer service")


if __name__ == "__main__":
    main()
