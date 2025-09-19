#!/usr/bin/env bash
#################################################
# Pacman-based functions
#################################################

echo "arch/distrosupport.sh: distro_packages=\"${distro_packages[@]}\""
function confound_arch_package_install() {
    # Arguments: all are passed in as confound package names.

    declare -a packages
    packages=( $(confound_print_converted_package_names "$@" ) )

    # Use yay if it exists
    if ! type "yay" > /dev/null ; then
        declare -a YAY_OPTIONS=(
            --noremovemake
            --answerclean None
            --sudoloop
            --needed
        )
        sudo yay "${YAY_OPTIONS[@]}" -Syu "${packages[@]}"
    else
        sudo pacman --noconfirm --needed -S "${packages[@]}"
    fi
}

function confound_arch_update_upgrade() {
    if ! type "yay" > /dev/null ; then
        sudo yay --sudoloop --noconfirm -Syu
    else
        sudo pacman --noconfirm -Syu
    fi
}
