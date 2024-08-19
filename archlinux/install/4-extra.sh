#!/bin/bash

services() {
  pacman -S --noconfirm openssh
  systemctl enable sshd.service

  pacman -S --noconfirm networkmanager
  systemctl enable NetworkManager.service
}

extrapkgs() {

}

envars() {}