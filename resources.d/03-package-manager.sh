# This is the list of supported OSes. The ids come from /etc/os-release in the
# ID field.
# Each ID here needs to correspond to a file in $PACKAGES_DIR/$ID, which defines
# details on how to install packages, as well as the distro-specific names for
# packages.
#
# This file depends on 02-os-type.sh being sourced before it

################################################################################
# Check that distro is supported
################################################################################

export confound_distro_packages_file="${PACKAGES_DIR}/${confound_os_id}/packages.sh"
export confound_distro_support_file="${PACKAGES_DIR}/${confound_os_id}/distrosupport.sh"

# We have to source this one first, since we reference the distro_packages array
# in our functions here.
source "$confound_distro_packages_file"

# Make sure the distro is supported. To count as "supported", these files need
# to exist:
#   - ${PACKAGES_DIR}/${confound_os_id}/distrosupport.sh
#   - ${PACKAGES_DIR}/${confound_os_id}/packages.sh
# The distrosupport.sh file defines two functions: `confound_apt_package_install()`
# and `confound_package_update_upgrade()`.
# The ${confound_os_id}/packages.sh file defines an associative array called
# distro_packages=( [confound_package_one]="foo" [confound_package_two]="bar" )
function ensure_distro_package_manager_supported() {
    echo "PACKAGES_DIR = $PACKAGES_DIR"
    if [[ -d "${PACKAGES_DIR}/${confound_os_id}" ]] && \
        [[ -a "$confound_distro_support_file" ]] && \
        [[ -a "$confound_distro_packages_file" ]];
    then
        echo "${confound_os_id} is supported. Hooray!"
    else
        echo "ERROR: Distro ${confound_os_id} lacks proper distro support files. Quitting!"
        exit 5
    fi

    # TODO: Ensure that distro_packages exists and is not empty
}
ensure_distro_package_manager_supported

# confound_package_name_to_distro_specific_package_name()
# Converts a given "confound name" of a package to the distro-specific one, and
# prints that distro-specific name
function confound_package_name_to_distro_specific_package_name() {
    package_name="${1:-}"
    #>&2 printf "===== package_name = %s\n" "$package_name"
    #>&2 printf "===== distro_packages= %s\n" "${distro_packages[@]}"

    # Have to unset the nounset option here so we don't get errors
    set +u
    if [[ -v distro_packages[$package_name] ]] ; then
        >&2 log_info "Using distro-defined package. Subbing ${distro_packages["${package_name}"]} for $package_name"
        echo "${distro_packages["${package_name}"]}"
    else
        >&2 log_warning "$package_name is not defined for distro $confound_os_id. Assuming it is the same name."
        echo "$package_name "
    fi
    set -u
}

# Takes the arguments given it and prints the distro-specific version of each.
# Typical usage might look like this:
# new_package_list=( $(confound_print_converted_package_names "packagea" vim git cmake tmux ) )
#
# or
#
# new_package_list=( $(confound_print_converted_package_names "${confound_packages_to_install[@]}" ) )
function confound_print_converted_package_names() {
    declare -a result_list
    for package_name in $@; do
        >&2 echo "----> Checking $package_name"
        result_list+="$(confound_package_name_to_distro_specific_package_name "$package_name")"
    done
    echo "${result_list[@]}"
}

# The distro support files can depend on confound_print_converted_package_names and
# confound_package_name_to_distro_specific_package_name so we have to source these
# after those functions are defined.
source "$confound_distro_support_file"

#################################################
# Top-Level Confound Package API
#################################################
# These functions are defined by the distrosupport.sh file for each distro

# Installs a given "confound" package. These are mapped to distro-specific packages
# in $PACKAGES_DIR/<distro>.sh.
# Arguments: 1-inf: names of confound packages to install
#function confound_package_install() {
#}

# Updates packages on the system
# function confound_package_update_upgrade()
