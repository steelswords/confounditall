#!/usr/bin/env bash

declare -A distro_packages=(
    [zsh]=zsh
    [tmux]=tmux
    [git]=git
    [cmake]=cmake
    [bat]=bat
    [pipx]=pipx
    [go]=golang-go
)

echo "distro_packages=${distro_packages[@]}"
