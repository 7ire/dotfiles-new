import re
import subprocess

def is_valid_keyboard(layout):
    try:
        output = subprocess.check_output(['localectl', 'list-keymaps'], universal_newlines=True)
        return layout in output.splitlines()
    except subprocess.CalledProcessError:
        return False

def is_valid_locale(locale):
    try:
        output = subprocess.check_output(['locale', '-a'], universal_newlines=True)
        return locale in output.splitlines()
    except subprocess.CalledProcessError:
        return False

def is_valid_timezone(timezone):
    try:
        output = subprocess.check_output(['timedatectl', 'list-timezones'], universal_newlines=True)
        return timezone in output.splitlines()
    except subprocess.CalledProcessError:
        return False

def parse_arch_conf(file_path):
    # Valori di default
    config = {
        'hostname': 'archlinux',
        'keyboard': 'us',
        'locale': {
            'lang': 'en_US.UTF-8',
            'timezone': 'America/New_York'
        }
    }
    
    inside_locale = False

    with open(file_path, 'r') as file:
        lines = file.readlines()

    for line in lines:
        line = line.strip()

        # Ignora le righe vuote o i commenti
        if not line or line.startswith('#'):
            continue

        if line.startswith("system.hostname"):
            config['hostname'] = re.search(r'\"(.*?)\"', line).group(1)
        elif line.startswith("system.keyboard"):
            keyboard = re.search(r'\"(.*?)\"', line).group(1)
            if is_valid_keyboard(keyboard):
                config['keyboard'] = keyboard
        elif line.startswith("system.locale"):
            inside_locale = True
        elif inside_locale:
            if line.startswith('}'):
                inside_locale = False
            elif 'lang' in line:
                lang = re.search(r'\"(.*?)\"', line).group(1)
                if is_valid_locale(lang):
                    config['locale']['lang'] = lang
            elif 'timezone' in line:
                timezone = re.search(r'\"(.*?)\"', line).group(1)
                if is_valid_timezone(timezone):
                    config['locale']['timezone'] = timezone

    return config

# Esempio di utilizzo
file_path = './../arch.conf'
config_dict = parse_arch_conf(file_path)
print(config_dict)
