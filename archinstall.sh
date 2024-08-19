#!/bin/bash

# Define keyboard layout of the host, to list avaible layouts 'localectl list-keymaps'
keyboard="it"
# Define the disk to install the system, identify the disk with 'lsblk -f'
disk="/dev/nvme0n1"
# Microcode package to load updates and security fixes from processor vendors.
# View cpuinfo: 'grep vendor_id /proc/cpuinfo'
#
# - AMD: "amd-ucode"
# - Intel: "intel-ucode"
microcode="intel-ucode"

timezone="Europe/Rome"

hostname="archlinux"

locale="it_IT.UTF-8"

username="foo"