#!/usr/bin/env bash

# Exports the following variables if it can find a good value for them:
# confound_os_id: A short string identifying the distro
# confound_os_name: The "PRETTY_NAME" of the distro
# TODO: Include version if necessary
function confound_get_os_type() {
    # First, check for /etc/os-release
    if [[ -f /etc/os-release ]]; then
        export confound_os_id=$(awk -F'=' '/^ID=.*/ { print $2; }' /etc/os-release)
        export confound_os_name=$(awk -F'=' '/^PRETTY_NAME=.*/ { print $2; }' /etc/os-release)
    else
        export confound_os_id="unknown"
        export confound_os_name="Unknown"
    fi

    echo "Detected OS: $confound_os_name"
}

confound_get_os_type
