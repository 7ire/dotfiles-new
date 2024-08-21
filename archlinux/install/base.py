from utils import run_command, run_command_chroot

def install_system(cryptdev, microcodde, filesystem):
    command = f"pacstrap /mnt base base-devel {microcode} linux-firmware linux-zen linux-zen-headers"

    if filesystem == "btrfs":
        command += " btrfs-progs"

    if cryptdev:
        command += " cryptsetup"

    run_command(command)
    run_command("genfstab -U /mnt >> /mnt/etc/fstab")


def _locale(timezone, lang, keymap):
    run_command_chroot(f"ln -sf /usr/share/zoneinfo/{timezone} /etc/localtime")
    run_command_chroot("hwclock --systohc")

    hosts = """
    cat > /etc/hosts <<EOF
    127.0.0.1   localhost
    ::1         localhost
    127.0.1.1   {hostname}.localdomain {hostname}
    EOF
    """
    

def configure_system(cryptdev, filesystem):
