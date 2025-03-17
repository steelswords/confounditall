# This is the list of supported OSes. The ids come from /etc/os-release in the
# ID field.
# Each ID here needs to correspond to a file in $PACKAGES_DIR/$ID, which defines
# details on how to install packages, as well as the distro-specific names for
# packages.
#
# This file depends on 02-os-type.sh being sourced before it
declare -a confound_supported_os_ids=(
    arch
    ubuntu
    pop
)

# Check if the current host's distro is supported
if [[ -v confound_supported_os_ids["$confound_os_id"] ]]; then
    echo "This host is running a distro that is supported ($confound_os_id)"
else
    echo "ERROR: This host is running distro $confound_os_id, but it is not supported by confound! Supported distros are ${confound_supported_os_ids[@]}"
    exit 1
fi

# Source the distro-specific package manifest
source "$PACKAGES_DIR/$confound_os_id.sh"

# confound_package_name_to_distro_specific_package_name()
# Converts a given "confound name" of a package to the distro-specific one, and
# prints that distro-specific name
function confound_package_name_to_distro_specific_package_name() {
    true
    # TODO
}

# Takes the arguments given it and prints the distro-specific version of each.
# Typical usage might look like this:
# new_package_list=( $(confound_print_converted_package_names "packagea" vim git cmake tmux ) )
#
# or
#
# new_package_list=( $(confound_print_converted_package_names "${confound_packages_to_install[@]}" ) )
function confound_print_converted_package_names() {
    true
    # TODO
}

#################################################
# Apt-based functions
#################################################
function confound_apt_package_install() {
    # Arguments: all are passed in as package names
    sudo apt-get install "$@" -y
}

function confound_apt_update_upgrade() {
    sudo apt-get update
    sudo apt-get upgrade -y
}

#################################################
# Pacman-based functions
#################################################
function confound_pacman_package_install() {
    # Arguments: all are passed in as package names.
    if ! type "yay" > /dev/null ; then
        sudo yay --sudoloop --noconfirm -S "$@"
    else
        sudo pacman --noconfirm -S "$@"
    fi
}

function confound_pacman_update_upgrade() {
    if ! type "yay" > /dev/null ; then
        sudo yay --sudoloop --noconfirm -Syu
    else
        sudo pacman --noconfirm -Syu
    fi
}


#################################################
# Top-Level Confound Package API
#################################################

# Installs a given "confound" package. These are mapped to distro-specific packages
# in $PACKAGES_DIR/<distro>.sh.
# Arguments: 1-inf: names of confound packages to install
function confound_package_install() {
    # TODO
}

# Installs a package using its "confound name". The confound name is declared in
# packages/<
if [[ "$confound_os_id" == arch ]]; then
    alias confound_package_install="confound_pacman_package_install"
    alias confound_package_update_upgrade="confound_pacman_update_upgrade"
elif [[ "$confound_os_id" == "ubuntu" ]] || [[ "$confound_os_id" == "pop" ]]; then
    alias confound_package_install="confound_apt_package_install"
    alias confound_package_update_upgrade="confound_apt_update_upgrade"
else
    echo "ERROR: Unrecognized OS id!"
    exit 2
fi
