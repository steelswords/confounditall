#################################################
# Pacman-based functions
#################################################
function confound_pacman_package_install() {
    # Arguments: all are passed in as confound package names.
    #
    declare -a packages
    packages=( $(confound_print_converted_package_names "$@" ) )

    # Use yay if it exists
    if ! type "yay" > /dev/null ; then
        sudo yay --sudoloop --noconfirm -S "${packages[@]}"
    else
        sudo pacman --noconfirm -S "${packages[@]}"
    fi
}

function confound_pacman_update_upgrade() {
    if ! type "yay" > /dev/null ; then
        sudo yay --sudoloop --noconfirm -Syu
    else
        sudo pacman --noconfirm -Syu
    fi
}


