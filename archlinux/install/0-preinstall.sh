#!/bin/bash

loadkeys $keyboard
timedatectl set-ntp true
reflector --country 'Italy,France,Germany' --protocol https --age 6 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syy
pacman -S --noconfirm archlinux-keyring