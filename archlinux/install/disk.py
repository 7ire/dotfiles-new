from utils import run_command

def _wipe_data(target):
    run_command(f"wipefs -af {target}")
    run_command(f"sfdisk --zap-all --clear {target}")
    run_command(f"partprobe {target}")

def _rnd_data(target):
    run_command(f"cryptsetup open --type plain -d /dev/urandom {target} target")
    run_command("dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress")
    run_command("cryptsetup close target")

def ext4(target, espsize, fill_rnd_data, cryptdev):
    _wipe_data(target)

    if fill_rnd_data:
        _rnd_data(target)
    

def btrfs(target, espsize, fill_rnd_data, cryptdev):
    _wipe_data(target)

    if fill_rnd_data:
        _rnd_data(target)
    
    device = ""

    if cryptdev:
        run_command(f"sgdisk -n 0:0:+{espsize} -t 0:ef00 -c 0:esp {target}")
        run_command(f"sgdisk -n 0:0:0 -t 0:8309 -c 0:luks {target}")
        run_command(f"partprobe {target}")
        run_command(f"sgdisk -p {target}")
        run_command(f"cryptsetup --type luks2 -v -y luksFormat {target}p2")
        run_command(f"cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent {target}p2 cryptdev")
        run_command(f"mkfs.vfat -F32 -n ESP {target}p1")
        device = "/dev/mapper/cryptdev"
        run_command(f"mkfs.btrfs -L archlinux {device}")
    else:
        return 0
    
    run_command(f"mount {device} /mnt")

    run_command("btrfs subvolume create /mnt/@")
    run_command("btrfs subvolume create /mnt/@home")
    run_command("btrfs subvolume create /mnt/@snapshots")
    run_command("btrfs subvolume create /mnt/@cache")
    run_command("btrfs subvolume create /mnt/@libvirt")
    run_command("btrfs subvolume create /mnt/@log")
    run_command("btrfs subvolume create /mnt/@tmp")

    run_command("umount /mnt")

    sv_opts="rw,noatime,compress-force=zstd:1,space_cache=v2"

    run_command(f"mount -o {sv_opts},subvol=@ {device} /mnt")
    run_command("mkdir -p /mnt/{home,.snapshots,var/cache,var/lib/libvirt,var/log,var/tmp}")
    run_command(f"mount -o {sv_opts},subvol=@home {device} /mnt/home")
    run_command(f"mount -o {sv_opts},subvol=@snapshots {device} /mnt/.snapshots")
    run_command(f"mount -o {sv_opts},subvol=@cache {device} /mnt/var/cache")
    run_command(f"mount -o {sv_opts},subvol=@libvirt {device} /mnt/var/lib/libvirt")
    run_command(f"mount -o {sv_opts},subvol=@log {device} /mnt/var/log")
    run_command(f"mount -o {sv_opts},subvol=@tmp {device} /mnt/var/tmp")


def esp(target):
    run_command(f"mkdir -p /mnt/esp")
    run_command(f"mount {target}p1 /mnt/esp")


def disk(target, espsize, fill_rnd_data, cryptdev, fs):
    if fs == "ext4":
        ext4(target, espsize, fill_rnd_data, cryptdev)
    elif fs == "btrfs":
        btrfs(target, espsize, fill_rnd_data, cryptdev)
    else:
        return 1

    esp(f"{target}p1")
    return 0

