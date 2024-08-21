from utils import run_command

def preinstall(keyboard):
    run_command(f"loadkeys {keyboard}")
    run_command("ls /sys/firmware/efi/efivars")
    run_command("timedatectl set-ntp true")
    run_command("timedatectl status")
    run_command("pacman -S --noconfirm archlinux-keyring")
    run_command("pacman-key --init")
    run_command("sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf")
    run_command("pacman -Syy")
    run_command("pacman -S --noconfirm reflector")
    run_command("cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup")
    run_command("reflector --country 'Italy,France,Germany' --protocol https --age 6 --sort rate --save /etc/pacman.d/mirrorlist")
    run_command("pacman -Syy")
    run_command("pacman -S --noconfirm --needed gptfdisk btrfs-progs glibc")