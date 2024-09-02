import re
import subprocess

def is_valid_disk_target(disk):
    try:
        subprocess.check_output(['lsblk', disk], stderr=subprocess.STDOUT)
        return True
    except subprocess.CalledProcessError:
        return False

def is_valid_size(size):
    return re.match(r'^\d+(MiB|GiB|G|M|%)$', size) is not None

def parse_arch_conf(file_path):
    config = {
        'disk': {
            'target': '/dev/nvme0n1',
            'is_ssd': True,
            'encryption': {
                'enable': False,
                'type': 'luks2',
                'key': 'changeme'
            },
            'partition': {
                'boot': {
                    'mountpoint': 'esp',
                    'size': '512MiB',
                    'secureboot': False,
                    'bootloader': None
                },
                'root': {}, 
            },
            'swap': {
                'enable': False,
                'size': '8G'
            }
        }
    }

    inside_section = None
    inside_options = False
    inside_subvolumes = False

    with open(file_path, 'r') as file:
        lines = file.readlines()

    for line in lines:
        line = line.strip()

        if not line or line.startswith('#'):
            continue

        if line.startswith("disk.target"):
            target = re.search(r'\"(.*?)\"', line).group(1)
            if is_valid_disk_target(target):
                config['disk']['target'] = target
        elif line.startswith("disk.is_ssd"):
            config['disk']['is_ssd'] = "true" in line.lower()
        elif line.startswith("disk.encryption"):
            inside_section = 'encryption'
        elif line.startswith("disk.partition.boot"):
            inside_section = 'partition.boot'
        elif line.startswith("disk.partition.root.ext4"):
            inside_section = 'partition.root.ext4'
            config['disk']['partition']['root'] = {'ext4': {}}
        elif line.startswith("disk.partition.root.btrfs"):
            inside_section = 'partition.root.btrfs'
            config['disk']['partition']['root'] = {'btrfs': {'options': [], 'subvolumes': {}}}
        elif line.startswith("disk.swap"):
            inside_section = 'swap'

        elif inside_section:
            if line.startswith('}'):
                inside_section = None
                inside_options = False
                inside_subvolumes = False
            else:
                if inside_section == 'encryption':
                    if 'enable' in line:
                        config['disk']['encryption']['enable'] = "true" in line.lower()
                    elif 'type' in line:
                        config['disk']['encryption']['type'] = re.search(r'\"(.*?)\"', line).group(1)
                    elif 'key' in line:
                        config['disk']['encryption']['key'] = re.search(r'\"(.*?)\"', line).group(1)
                elif inside_section == 'partition.boot':
                    if 'mountpoint' in line:
                        config['disk']['partition']['boot']['mountpoint'] = re.search(r'\"(.*?)\"', line).group(1)
                    elif 'size' in line:
                        size = re.search(r'\"(.*?)\"', line).group(1)
                        if is_valid_size(size):
                            config['disk']['partition']['boot']['size'] = size
                    elif 'secureboot' in line:
                        config['disk']['partition']['boot']['secureboot'] = "true" in line.lower()
                    elif 'bootloader' in line:
                        if "systemd-bootl" in line:
                            if "true" in line.lower():
                                config['disk']['partition']['boot']['bootloader'] = 'systemd-boot'
                        elif "refind" in line:
                            if "true" in line.lower():
                                config['disk']['partition']['boot']['bootloader'] = 'refind'
                        elif "grub" in line:
                            if "true" in line.lower():
                                config['disk']['partition']['boot']['bootloader'] = 'grub'
                elif inside_section == 'partition.root.ext4':
                    if 'label' in line:
                        config['disk']['partition']['root']['ext4']['label'] = re.search(r'\"(.*?)\"', line).group(1)
                    elif 'size' in line:
                        size = re.search(r'\"(.*?)\"', line).group(1)
                        if is_valid_size(size):
                            config['disk']['partition']['root']['ext4']['size'] = size
                elif inside_section == 'partition.root.btrfs':
                    if 'label' in line:
                        config['disk']['partition']['root']['btrfs']['label'] = re.search(r'\"(.*?)\"', line).group(1)
                    elif 'size' in line:
                        size = re.search(r'\"(.*?)\"', line).group(1)
                        if is_valid_size(size):
                            config['disk']['partition']['root']['btrfs']['size'] = size
                    elif 'options' in line:
                        inside_options = True
                        if line.startswith('options = ['):
                            config['disk']['partition']['root']['btrfs']['options'] = []
                    elif 'subvolumes' in line:
                        inside_subvolumes = True
                        if line.startswith('subvolumes = {'):
                            config['disk']['partition']['root']['btrfs']['subvolumes'] = {}
                    elif inside_options:
                        if line == ']':
                            inside_options = False
                        else:
                            option = line.strip().strip('"').strip(',')
                            config['disk']['partition']['root']['btrfs']['options'].append(option)
                    elif inside_subvolumes:
                        if line == '}':
                            inside_subvolumes = False
                        else:
                            key, value = line.split('=')
                            key = key.strip()
                            value = value.strip().strip('"')
                            config['disk']['partition']['root']['btrfs']['subvolumes'][key] = value
                elif inside_section == 'swap':
                    if 'enable' in line:
                        config['disk']['swap']['enable'] = "true" in line.lower()
                    elif 'size' in line:
                        size = re.search(r'\"(.*?)\"', line).group(1)
                        if is_valid_size(size):
                            config['disk']['swap']['size'] = size

    return config

# Esempio di utilizzo
file_path = './../arch.conf'
config_dict = parse_arch_conf(file_path)
print(config_dict)
