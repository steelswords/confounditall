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

# get_repo_dir()
# Given the arguments to the script, return (print) the directory of this repo.
# Arguments:
#   - 1: The $0 of the script
function get_repo_dir() {
    script_name="${1:-}"
    realpath "$(dirname "$script_name")"
}


# Default config values
CONFOUND_DIR=$(get_repo_dir "$0")
RESOURCE_DIR="${CONFOUND_DIR}/resources.d"
CONFOUND_CONFIG_FILE="${CONFOUND_DIR}/confound.conf"
PACKAGES_DIR="${CONFOUND_DIR}/distros"
USER_STEPS_DIR="${CONFOUND_DIR}/user-steps.d"
USER_CONFIG_REPO_DIR="${USER_CONFIG_REPO_DIR:-/tmp/you-cded-somewhere-and-did-not-cd-back-in-one-of-your-steps}"

mkdir -p "$USER_CONFIG_REPO_DIR"

# Arg 1 [optional] CONFOUND_CONFIG_FILE
function load_config() {
    config_file="$1"
    source "$config_file"
}

# Check for config being passed in as first argument
if [[ $# -eq 1 ]]; then
    # Cover the --help text case
    if [[ "$1" == "--help" ]] || [[ "$1" == '-h' ]]; then
        print_usage
        exit 0
    # Use the first argument as the CONFOUND_CONFIG_FILE
    else
        export CONFOUND_CONFIG_FILE="$1"
    fi
fi

load_config "$CONFOUND_CONFIG_FILE"

# 01-logging.sh is special because we use it everywhere. We end up sourcing it twice.
source "${RESOURCE_DIR}/01-logging.sh"

# Redefine source so we always log when we're sourcing something
#source() {
#    log_info "- Sourcing $1"
#    command source "$1"
#}

function print_dirs() {
    log_info "This project lives at $CONFOUND_DIR"
    log_info "USER_STEPS_DIR = $USER_STEPS_DIR"
    log_info "Resource functions are at $RESOURCE_DIR"
}

function source_all_files_in_directory() {
    target_directory="$1"
    if [[ -d "$target_directory" ]]; then
        for resource_file in "$target_directory"/*; do
            if [[ -a "$resource_file" ]]; then
                #log_info "- Sourcing $resource_file"
                source "$resource_file"
                cd "$USER_CONFIG_REPO_DIR"
            else
                log_warning "- Could not source $resource_file. Does not exist."
            fi
        done
    fi
}

#function source_resource_files() {
#    source_all_files_in_directory "$RESOURCE_DIR"
#    # TODO: User RESOURCE_DIR
#}

#function source_step_files() {
#    source_all_files_in_directory "$USER_STEPS_DIR"
#}

print_dirs

source_all_files_in_directory "$RESOURCE_DIR"
source_all_files_in_directory "$USER_STEPS_DIR"
#source_resource_files
#source_step_files
