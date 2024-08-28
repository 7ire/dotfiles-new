import subprocess
import json
import sys
from rich.console import Console


# =============================================================================
#                            Constants
# =============================================================================


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
#                           Extra Installer Script
# =============================================================================

def main():
    # Read JSON configuration
    arch_params = read_cfg()

    # Load configuration parameters

    # Verify parameters

    # Start extra-installation tasks
    # =============================================================================

    # ======================= STEP 0 - AUDIO DRIVER ===============================

    # ======================= STEP 1 - VIDEO DRIVER ===============================

    # ======================= STEP 2 - DESKTOP ENVIRONMENT ========================

    # ======================= STEP 3 - WINDOWS MANAGER ============================

    # ======================= STEP 4 - ADDITIONAL STEPS ===========================