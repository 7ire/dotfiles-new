#!/usr/bin/env bash

# ==============================================================================
#                               PARAMETERS
# ==============================================================================
# No parameters required for this script

# ZSH
# Install base packages
sudo pacman -S zsh oh-my-zsh-git
# Install ZSH plugings
sudo pacman zsh-autosuggestions zsh-completions zsh-fast-syntax-highlighting zsh-theme-powerlevel10k find-the-command zsh-autocomplete
# Fuzzy Finder
sudo pacman -S fzf zsh-fzf-plugin-git 

# VSCodium

# Zellij

# dotfiles