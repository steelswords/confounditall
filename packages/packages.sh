# This is the list of supported OSes. The ids come from /etc/os-release in the
# ID field.
# Each ID here needs to correspond to a file in $PACKAGES_DIR/$ID, which defines
# details on how to install packages, as well as the distro-specific names for
# packages.
declare -a confound_supported_os_ids=(
    arch
    ubuntu
    pop
)
