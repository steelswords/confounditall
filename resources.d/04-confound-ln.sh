# Sets up a symlink from $1 to $2.
# In other words, makes $1 show up at destination $2
function confound_ln() {
    conf_file="${1:-}"
    install_destination="${2:-}"

    log_info "Installing $conf_file to $install_destination"
    ln -sn "$(realpath "$conf_file")" "$install_destination"
}
