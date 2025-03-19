# Sets up a symlink from $1 to $2.
# In other words, makes $1 show up at destination $2
function confound_ln() {
    conf_file="${1:-}"
    install_destination="${2:-}"

    if [[ -L "$install_destination" ]] || [[ ! -e "$install_destination" ]]; then
        log_info "Installing $conf_file to $install_destination"
        ln -sfn "$(realpath "$conf_file")" "$install_destination"
    else
        log_error "There is an existing file at $install_destination. Remove it before continuing."
        exit 5
    fi
}
