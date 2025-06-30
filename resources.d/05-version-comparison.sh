#!/usr/bin/env bash
# Usage: source 05-version-comparison.sh

################################################################################
# Functions
################################################################################
# is_version_format_supported <version_string> Returns 0 if version string is in
#       a format that this module supports. Returns 1 if not.
#
# is_version_less_than <version_to_test> <reference_version>
#       Returns 0 if <version_to_test> is less than <reference_version>
#       Returns 1 if not less than
# is_version_equal_to <version_to_test> <reference_version>
# is_version_greater_than <version_to_test> <reference_version>
# is_version_greater_than_or_equal_to <version_to_test> <reference_version>
# is_version_less_than_or_equal_to <version_to_test> <reference_version>
#       Similar to is_version_less_than

set -ue -o pipefail
#set -x

# This whole function is likely to have to be revamped as things progress
function is_version_format_supported() {
    version_str="$1"

    # Version cannot be empty
    [[ -z "$version_str" ]] && return 1

    # Trim off leading v if it exists
    [[ ${version_str:0:1} == 'v' ]] && version_str="${version_str:1}"

    # Make sure we start with a number
    [[ ! $version_str =~ ^[0-9] ]] && return 1

    # Make sure we don't end with a '.'
    # We are allowed to end with a number or a letter
    [[ ${version_str: -1:1} == '.' ]] && return 1

    # Make sure we don't have consecutive '.' characters
    [[ ${version_str} =~ \.\. ]] && return 1


    [[ ${version_str} =~ \.[a-zA-Z]+*\. ]] && return 1

    return 0
}

# Removes leading 'v' if present
# Splits version into separate words
function decompose_version() {
    version_str="$1"

    # Trim off leading v if it exists
    if [[ ${version_str:0:1} == 'v' ]]; then
        version_str="${version_str:1}"
    fi

    # Split version into segments
    echo "$version_str" | tr '.' ' '
}

function is_version_less_than() {
    version_to_test="$1"
    reference_version="$2"

    #echo "--> is_version_less_than called with $version_to_test and $reference_version"

    local -a segments_to_test segments_to_reference
    # TODO: This has a badness. It adds a newline or some such nonsense
    mapfile -t -d ' ' segments_to_test < <( decompose_version "$version_to_test" )
    mapfile -t -d ' ' segments_to_reference < <( decompose_version "$reference_version" )

    if [[ ${#segments_to_test} -ne ${#segments_to_reference} ]]; then
        echo "ERROR: Reference version ($reference_version) and test version ($version_to_test) have incompatible formats! "
        exit 33
    fi

    num_of_segments=${#segments_to_test[@]}
    #echo "There are $num_of_segments segments to " "${segments_to_test[@]}"
    for (( i=0; i < num_of_segments ; i++ )); do
        echo -n "-> Comparing segment $i. Test version = \"${segments_to_test[${i}]}\", Reference version segment = \"${segments_to_reference[${i}]}\": "
        if [[ ${segments_to_test[${i}]} > ${segments_to_reference[${i}]} ]]; then
            echo "gt"
            return 1
        elif [[ ${segments_to_test[${i}]} == "${segments_to_reference[${i}]}" ]]; then
            echo "equal"
            continue
        elif [[ ${segments_to_test[${i}]} < ${segments_to_reference[${i}]} ]]; then
            echo "less than"
            # We are actually less than here.
            return 0
        fi
        # If we reach this point, we have already proven that we are equal, not less than
    done
    return 2
}


# version = the version string to test
# expect_valid = 'valid' or 'invalid'
function test_assert_version_valid_or_not() {
    version="$1"
    expect_valid="$2"
    echo -en "Asserting version string \"$version\" is $expect_valid...\t"
    if is_version_format_supported "$version"; then
        if [[ $expect_valid == 'valid' ]]; then
            echo "OK"
            return 0
        elif [[ $expect_valid == 'invalid' ]]; then
            echo "ERROR: Expected to be invalid, but was found to be valid."
            return 1
        else
            echo "ERROR: Bad parameters passed to test_assert_version_valid_or_not: \$2 should be 'valid' or 'invalid', got $2"
            return 1
        fi
    else
        if [[ $expect_valid == "invalid" ]]; then
            echo "OK"
            return 0
        elif [[ $expect_valid == "valid" ]]; then
            echo "ERROR: Expected to be valid, but was found invalid."
        else
            echo "ERROR: Bad parameters passed to test_assert_version_valid_or_not: \$2 should be 'valid' or 'invalid', got $2"
        fi
        return 1
    fi
}

# expected_lt = 'yes' or 'no'
test_assert_version_lt() {
    local version_to_test="$1"
    local version_to_reference="$2"
    local expected_lt="$3"

    echo -ne "Testing if version \"$version_to_test\" is less than \"$version_to_reference\"...\t"
    if is_version_less_than "$version_to_test" "$version_to_reference" ; then
        if [[ $expected_lt == 'yes' ]]; then
            echo "OK"
            return 0
        else
            echo "ERROR: Did not expect $version_to_test to be less than $version_to_reference, but it was."
        fi
    else # Not less than
        if [[ $expected_lt == 'yes' ]]; then
            echo "ERROR: Expected $version_to_test to be less than $version_to_reference, but it was not."
        else
            echo "OK"
            return 0
        fi
    fi

    return 1
}

function file_unit_tests() {
    test_assert_version_valid_or_not "0.0.1" valid
    test_assert_version_valid_or_not "v0.0.1a" valid
    test_assert_version_valid_or_not "v1" valid
    test_assert_version_valid_or_not "1" valid
    test_assert_version_valid_or_not "10.0" valid
    test_assert_version_valid_or_not "13." invalid
    test_assert_version_valid_or_not "a" invalid
    test_assert_version_valid_or_not "" invalid
    test_assert_version_valid_or_not "1.2.4.5.6.7.1222.41234.0" valid
    test_assert_version_valid_or_not "1.2.4.5.6.7..41234.0" invalid
    test_assert_version_valid_or_not "1.2.4.T.41234.0" invalid

    test_assert_version_lt "0.0.1" "0.0.2" yes
    test_assert_version_lt "0.0.2" "0.0.1" no
    test_assert_version_lt "v0.0.2" "v0.0.1" no
    test_assert_version_lt "v2.0.2" "v2.0.1" no
    test_assert_version_lt "v2.0.1" "v2.0.1" no
    test_assert_version_lt "0.0.2a" "0.0.2b" yes
    test_assert_version_lt "0.0.2a" "0.0.3b" yes
    test_assert_version_lt "0.0.2a" "0.1.0" yes
    test_assert_version_lt "1.0.0" "0.1.0" no

}

#file_unit_tests
