#!/usr/bin/env bash
# Description: This allows distro-specific setup steps, like installing an AUR helper,
# etc. for Arch-based distros. These steps are found in distros/<distroname>/distro-specific-setup.sh.

function do_distro_specific_setup_if_available() {
	distro_specific_setup_script="${PACKAGES_DIR}/${confound_os_id}/distro-specific-setup.sh"
	if [[ -f "$distro_specific_setup_script" ]]; then
		echo "-> Distro ${confound_os_id} has specific setup steps. Running those now."
		. "$distro_specific_setup_script"
	else
		echo "-> Distro ${confound_os_id} does not have specific setup steps."
	fi
}

do_distro_specific_setup_if_available
