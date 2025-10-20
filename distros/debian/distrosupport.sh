#################################################
# Apt-based functions
#################################################
function confound_package_update_upgrade() {
    sudo apt-get update
    sudo apt-get upgrade -y
}

function confound_debian_package_install() {
    # TODO: Translate through distro_packages array
    # Arguments: all are passed in as confound package names
    declare -a packages
    packages=( $(confound_print_converted_package_names "$*" ) )
    sudo apt-get install "${packages[@]}" -y
}

# The easisest thing to do is just define and pass all the debian-derivatives
# to the debian package install function.
function confound_ubuntu_package_install() {
    confound_debian_package_install $@
}
function confound_pop_package_install() {
    confound_debian_package_install $@
}
function confound_mint_package_install() {
    confound_debian_package_install $@
}
