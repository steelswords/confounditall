#################################################
# Apt-based functions
#################################################
function confound_package_update_upgrade() {
    sudo apt-get update
    sudo apt-get upgrade -y
}

function confound_package_install() {
    # TODO: Translate through distro_packages array
    # Arguments: all are passed in as confound package names
    declare -a packages
    packages=( $(confound_print_converted_package_names "$*" ) )
    sudo apt-get install "${packages[@]}" -y
}
