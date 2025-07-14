# Returns 0 if the listed dconf value is an array, 1 if not.
# Args: $1 - the path to the value to check.
confound_dconf_is_array() {
    path="${1:-}"
    value="$(dconf read "$path")"
    if [[ "$value" =~ ^\[\'.*\'\]$ ]]; then
        return 0
    fi
    return 1
}

confound_dconf_get_array_elements() {
    path="${1:-}"
    if ! confound_dconf_is_array "$path" ; then
        #>&2 log_warning "dconf $path is not an array! "
        >&2 echo "dconf $path is not an array! "
        return 2
    fi
    whole_array="$( dconf read "$path" )"

    # Strip off initial and final '[' and ']'
    whole_array=${whole_array#[}
    whole_array=${whole_array%]}
    
    # Evalaute whole_array so that each element shows up as a space separated string (hopefully)
    #echo $whole_array

    for element in $whole_array; do
        element=${element#\'}
        element=${element%,}
        element=${element%\'}
        printf "%s " "$element"
    done
    printf '\n'
}

# Args: All the elements of the array as space-separated strings.
# Each element should NOT have single quotes (') or commas (,) mixed
# in that don't relate to the actual value.
dconf_assemble_into_array() {
    loop_i=1
    last_element_i=$#
    last_element_i=$(( last_element_i - 1 ))
    printf '['
    for element in "$@"; do
        if [[ $loop_i == "$last_element_i" ]]; then
            printf "'%s']\n" "$element"
        else
            printf "'%s', " "$element"
        fi
        loop_i=$(( loop_i + 1 ))
    done
}

# Ensures that $value is inserted into an array at $path exactly once.
# Args: $1: $path: The dconf path to ensure $value exists once.
#       $2: $value: The value to make sure is in the array
dconf_ensure_inserted() {
    path="${1:-}"
    value="${2:-}"

    if ! confound_dconf_is_array "$path"; then
        log_error "Dconf $path is not an array"
        exit 4
    fi

    existing_values=( $(confound_dconf_get_array_elements "$path" ) )

    found_desired_element='false'
    for element in "${existing_values[@]}"; do
        if [[ "$element" == "$value" ]]; then
            found_desired_element='true'
        fi
    done

    if [[ "$found_desired_element" == 'true' ]]; then
        log_info "$value already in path $path"
        return 0
    else
        log_info "Inserting $value into $path (originally value=${existing_values[@]})"
        new_value="$( dconf_assemble_into_array "${existing_values[@]}" "$value" )"
        dconf write "$path" "$new_value"
    fi
}
