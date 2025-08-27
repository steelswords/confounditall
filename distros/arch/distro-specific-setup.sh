# Guard so we don't run these steps over and over again
GUARD_FILE=/tmp/CONFOUND_DISTRO_SPECIFIC_SETUP_DONE 
if [[ -f "$GUARD_FILE" ]]; then
	# Note how many times this has been called. This is for debugging later.
	times_done_already="$(cat "$GUARD_FILE")"
	times_done_already=$(( times_done_already + 1 ))
	echo -n "$times_done_already" > "$GUARD_FILE"
	return
fi

function install_arch_standard_packages() {
	sudo pacman -Syyu \
		inetutils \
		git \
		base-devel \
	;
}

function throw_up_and_die() {
	echo "!! ERROR: $@"
	exit 202
}

function install_yay() {
	if type yay > /dev/null; then
		echo "-> Yay already installed."
		return
	fi

	echo "-> Installing yay"
	TARGET_DIR="$HOME/Repos/notmine"
	mkdir -p "$TARGET_DIR" ||:
	if ! cd "$TARGET_DIR"; then
		throw_up_and_die "Could not create $TARGET_DIR to clone yay"
	fi

	if [[ ! -d yay ]]; then
		git clone "https://aur.archlinux.org/yay.git"
	fi
	cd yay
	makepkg -si
}

function do_arch_specific_setup() {
	echo "-> Running Arch-specific setup steps"
	install_arch_standard_packages

	install_yay
}

do_arch_specific_setup

echo 1 > "$GUARD_FILE"
