#!/usr/bin/env bash
# File:        setup.sh
# Author:      Tristan Andrus
# Description: Call this function when you set up a new 
################################################################################

set -o errexit   # Abort on nonzero exitstatus
set -o nounset   # Abort on unbound variable
set -o pipefail  # Don't hide errors within pipes

trap "echo 'An error occurred! Quitting mid-script!'" ERR

# Uncomment to debug
# set -x

################################################################################

# Logging system
# TODO: log_info, log_debug, log_error, log_warning functions

# get_repo_dir()
# Given the arguments to the script, return (print) the directory of this repo.
# Arguments:
#   - 1: The $0 of the script
function get_repo_dir() {
    script_name="${1:-}"
    realpath "$(dirname "$script_name")"
}

CONFOUND_DIR=$(get_repo_dir "$0")
STEPS_DIR="${CONFOUND_DIR}/confound.d"
RESOURCE_DIR="${CONFOUND_DIR}/resources.d"
CONFOUND_CONFIG_FILE="${CONFOUND_DIR}/confound.conf"

function print_dirs() {
    echo "This project lives at $CONFOUND_DIR"
    echo "Steps are at $STEPS_DIR"
    echo "Resource functions are at $RESOURCE_DIR"
}

function load_config() {
    source "$CONFOUND_CONFIG_FILE"
}

function source_resource_files() {

    # The globstar shopt makes `**` expand to all files in all subdirectories.
    # TODO: Only set things for this function, put it back the way it was when
    # we're done.
    for resource_file in "$RESOURCE_DIR"/* ; do
        if [[ -f "$resource_file" ]]; then
            echo "Sourcing resource file $resource_file"
            source "$resource_file"
        fi
    done
}

function source_step_files() {
    for step_file in "$STEPS_DIR"/* ; do
        if [[ -f "$step_file" ]]; then
            echo "Sourcing resource file $step_file"
            source "$step_file"
        fi
    done
}

load_config

print_dirs

source_resource_files
source_step_files
