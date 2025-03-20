#!/usr/bin/env bash

declare -A distro_packages=(
    [zsh]=zsh
    [tmux]=tmux
    [git]=git
    [cmake]=cmake
)

echo "distro_packages=${distro_packages[@]}"
