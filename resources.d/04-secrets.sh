
if [[ -z $USER_CONFIG_REPO_DIR ]]; then
    SECRETS_FILE=~/.config/secrets.json
    log_warning "No USER_CONFIG_REPO_DIR defined. Assuming secrets are located $SECRETS_FILE"
else
    SECRETS_FILE="${SECRETS_FILE:-$USER_CONFIG_REPO_DIR/secrets/secrets.json}"
    log_info "Using secrets file @ $SECRETS_FILE"
fi

# Get secret: Uses sops/age to get a secret from the encrypted secrets file at
# env[SECRETS_FILE] (or fallback env[USER_CONFIG_REPO_DIR]/secrets/secrets.json)
# Arg 1: the path of the secret. This uses Python/Sops syntax, so
# `['foo']['bar']` would return "baz" in a secrets file that looks like this:
# ```
# {
#   "foo": {
#       "bar": "baz"
#   },
#   "qux": ...
# }
# ```
function confound_get_secret() {
    secret_path="${1:-}"
    >&2 log_info "Retrieving secret $secret_path"
    if ! type "sops" > /dev/null ; then
        >&2 log_error "sops must be installed before getting secret!"
        exit 30
    fi
    if ! sops decrypt --extract "$secret_path" "$SECRETS_FILE"; then
        log_error "Could not get the requested secret at path $secret_path from file $SECRETS_FILE. Quitting!"
        exit 31
    fi
}
export -f confound_get_secret
