import subprocess

def run_command(command):
    try:
        subprocess.run(command, shell=True, check=True, text=True)
    except subprocess.CalledProcessError as e:
        print(f"Error occurred: {e}")

def run_command_chroot(command):
    try:
        subprocess.run(f"arch-chroot /mnt /bin/bash -c '{command}'", shell=True, check=True, text=True)
    except subprocess.CalledProcessError as e:
        print(f"Error occurred: {e}")