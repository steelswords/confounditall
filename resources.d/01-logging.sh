# Colors for more visual statuses
_RED_TEXT='\033[31m'
_GREEN_TEXT='\033[32m'
_YELLOW_TEXT='\033[33m'
_BLUE_TEXT='\033[34m'
_CLEAR_TEXT='\033[0m'
_BOLD_TEXT='\033[1m'

_CYAN_TEXT='\033[36m'

function echo_warning() { echo -e "${_YELLOW_TEXT}$*${_CLEAR_TEXT}"; }
function echo_error()   { echo -e "${_RED_TEXT}$*${_CLEAR_TEXT}";    }
function echo_success() { echo -e "${_GREEN_TEXT}$*${_CLEAR_TEXT}";  }
function echo_status()  { echo -e "${_BLUE_TEXT}$*${_CLEAR_TEXT}";   }

CONFOUND_LOG_FILE="${CONFOUND_DIR}/confound.log"

CONFOUND_LOG_LEVEL="info" # values are info, debug, warn, error, crit

declare -A confound_log_level_numerical
confound_log_level_numerical=(
    [info]=1
    [debug]=2
    [warn]=3
    [error]=4
    [crit]=5
)

# @param $1: log_level
# Returns 0 if the log_level is greater than or equal to CONFOUND_LOG_LEVEL
# Returns 1 if not.
function should_print_log_level() {
    log_level="$1"
    log_level_numeric="${confound_log_level_numerical["${log_level}"]}"
    if [[ -z "$log_level_numeric" ]]; then
        echo_error "Invalid log level passed in: $log_level"
        exit 10
        return 1
    fi

    confound_log_level_numeric="${confound_log_level_numerical["${CONFOUND_LOG_LEVEL}"]}"
    if (( "$log_level_numeric" < "$confound_log_level_numeric" )) ; then
        return 1
    fi

    return 0
}

# Arg 1: The log level
function echo_log_color_code() {
    log_level="${1:-}"
    case "$log_level" in
        info)
            echo -e "$_BLUE_TEXT"
            ;;
        debug)
            echo -e "$_CYAN_TEXT"
            ;;
        warn)
            echo -e "$_YELLOW_TEXT"
            ;;
        errorcrit)
            echo -e "$_RED_TEXT"
            ;;
        *)
            ;;
    esac
}

# Wraps a log message in the format of a log message, e.g. with timestamp and level
# Arg 1: The message
# Arg 2: [optional] The log level
function wrap_log_message() {
    message="${1:-}"
    log_level="${2:-}"
    printf "%s @ [%5s] %s %s%s\n" "$(date +%T.%5N)" "${log_level^^}" $(echo_log_color_code "$log_level") "$message"
    echo -e "${_CLEAR_TEXT}"
}

# First arg is log level, rest are passed to echo.
function confound_log() {
    log_level="$1"
    shift
    log_message="$*"
    if should_print_log_level "$log_level"; then
        echo $(wrap_log_message "$log_message" "$log_level") | tee -a "$CONFOUND_LOG_FILE"
    fi
}

function log_warning() {
    confound_log "warn" "$@"
}

function log_debug() {
    confound_log "debug" "$@"
}

function log_error() {
    confound_log "error" "$@"
}

function log_info() {
    confound_log "info" "$@"
}
