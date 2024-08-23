import subprocess
import json
import sys

from rich.console import Console


# =============================================================================
#                  Support parameters values
# =============================================================================
FS = ["ext4", "btrfs"]
AUR = ["yay", "paru"]


# =============================================================================
#                  Utilities functions
# =============================================================================
# Read the Arch Linux configuration file
def read_cfg():
    # path of the configuration file
    arch_cfg = 'archlinux.json'
    
    # open the file in readonly mode
    with open(arch_cfg, 'r') as file:
        # load the values in a structure
        data = json.load(file)
    
    # return back the structure filled with value
    return data

# Output animation while the script is working
def printer(task_target, msg1, mgs2):
    console = Console()

    with console.status(f"[bold green]{msg1}...") as status:
        result = task_target()  # Exec function
        console.log(f"[bold green]{mgs2}, Completed!")
    return result
# =============================================================================


# =============================================================================
#                  P O S T   I N S T A L L E R   S C R I P T
# =============================================================================

# Read JSON configuration
# =============================================================================
# Get the configuration params values
arch_paramas = read_cfg()

# Load each paramaters with its value
# =============================================================================
is_ssd = arch_paramas["disk"]["is_ssd"]       # Is SSD the disk
disk_fs = arch_paramas["disk"]["filesystem"]  # Disk filesystem type

is_swap = arch_paramas["swap"]["enable"]  # Is swap enable
swap_size = arch_paramas["swap"]["size"]  # Size of swap

aur = arch_paramas["aur"]  # AUR Helper

# Verify parameteres
# Assert if is_ssd is boolean value
assert isinstance(is_ssd, bool), "is_ssd must be a boolean"
# Assert if is_swap is boolean value
assert isinstance(is_swap, bool), "is_swap must be a boolean"
# Assert if the value of disk_fs is present in FS
assert disk_fs in FS, f"Filesystem must be one of {FS}"
# Assert if the value of aur is present in AUR
assert aur in AUR, f"AUR helper must be one of {AUR}"

# preliminary setup
printer(lambda: subprocess.call(['./.post/0-prereuirment.sh']), "Preliminary phase", "Preliminary phase")

# btrfs snapshot
if disk_fs == "btrfs":
    printer(lambda: subprocess.call(['./.post/1-snapshot.sh']), "Generating snapshot for /", "Generation of snapshot for /")

# ssd improvements
if is_ssd:
    printer(lambda: subprocess.call(['./.post/3-ssd.sh']), "Improving SSD performance", "SSD improving")

# zram
if is_swap:
    printer(lambda: subprocess.call(['./.post/2-zram.sh', swap_size]), f"Configuring swap with ZRam = {swap_size}", "Configuring swap")

# aur
if aur == "yay":
    printer(lambda: subprocess.call(['./.post/4-aur/yay.sh']), "Installing AUR helper", "AUR helper installation")
elif aur == "paru":
    printer(lambda: subprocess.call(['./.post/4-aur/paru.sh']), "Installing AUR helper", "AUR helper installation")
