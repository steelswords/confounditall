#!/usr/bin/env bash

declare -A distro_packages=(
    [age]=age
    [zsh]=zsh
    [tmux]=tmux
    [git]=git
    [cmake]=cmake
    [bat]=bat
    [g++]=gcc
    [ninja-build]=ninja
    [python3-neovim]=python-pynvim
    [python3-pip]=python-pip
    [pipx]=python-pipx
    [fonts-powerline]=powerline-fonts
)

>&2 echo "arch/packages.sh: distro_packages=${distro_packages[@]}"
