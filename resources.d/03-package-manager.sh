#!/usr/bin/env bash
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
echo "Sourcing $confound_distro_packages_file"
source "$confound_distro_packages_file"

>&2 echo "Sourced $confound_distro_packages_file."
>&2 echo "03-package-manager.sh: distro_packages = \"${distro_packages[@]}\""

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

    # Implies that $PACKAGES_DIR/$confound_os_id exists.
    if [[ -a "$(realpath $confound_distro_support_file)" ]] && \
        [[ -a "$(realpath $confound_distro_packages_file)" ]];
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
    >&2 echo "Looking for package \"$package_name\" in distro_packages \"${distro_packages[@]}\""
    if [[ -v distro_packages[$package_name] ]] ; then
        >&2 log_info "Using distro-defined package. Subbing ${distro_packages["${package_name}"]} for $package_name"
        echo "${distro_packages["${package_name}"]} "
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
    if ! >&2 declare -p distro_packages; then
        echo "ALERTALERTALERT~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        exit 4
    fi
    for package_name in $@; do
        >&2 echo "--> confound_print_converted_package_names: Transmuting $package_name"
        >&2 echo "--> confound_print_converted_package_names: distro_packages = ${distro_packages[@]}"

        result_list+="$(confound_package_name_to_distro_specific_package_name "$package_name")"
    done
    echo "${result_list[@]}"
}


function confound_is_version_at_least() {
    if [[ $# -ne 2 ]]
    then
        echo "!! confound_is_version_at_least called with wrong number of arguments: expected 2, got $#"
        exit 5
    fi
    ref_version="${1:-}"
    test_version="${2:-}"

    if [[ "$test_version" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
        for segment in 1..3; do
            ref_segment=$(echo "$ref_version" | cut -d'.' --fields $i)
            test_segment=$(echo "$test_version" | cut -d'.' --fields $i)
            if (( ref_segment > test_segement )); then
                echo "Version \"$test_version\" is NOT at least \"$ref_version\""
                return 1
            fi
        done
        echo "Version \"$test_version\" is at least \"$ref_version\""
        return 0
    else
        echo "!! Could not verify version $test_version is at least $ref_version: Unrecognized format"
        exit 6
    fi
}



echo "---> DEBUG: Converting g++ to package name:"
echo "-----> DEBUG: g++ converted is $(confound_print_converted_package_names 'g++')"

source "$confound_distro_support_file"



function confound_package_install() {
    source "$confound_distro_packages_file"
    declare -a packages
    packages=( $(confound_print_converted_package_names "$*" ) )
    "confound_${confound_os_id}_package_install" ${packages[@]}
}


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
