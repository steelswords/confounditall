#!/usr/bin/env bash

declare -A distro_packages=(
    [zsh]=zsh
    [tmux]=tmux
    [git]=git
    [cmake]=cmake
    [bat]=bat
    [pipx]=python3-pipx
)

echo "distro_packages=${distro_packages[@]}"
