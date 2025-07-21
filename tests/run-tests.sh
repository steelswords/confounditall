#!/usr/bin/env bash
# File:        run-tests.sh
# Author:      Tristan Andrus
# Description: Runs all the unit tests in the tests/ directory, with helpful
#              printouts for each.
################################################################################

set -o errexit   # Abort on nonzero exitstatus
set -o nounset   # Abort on unbound variable
set -o pipefail  # Don't hide errors within pipes

trap "echo 'An error occurred! Quitting mid-script!'" ERR

# Colors for more visual statuses
_RED_TEXT='\033[31m'
_GREEN_TEXT='\033[32m'
_YELLOW_TEXT='\033[33m'
_BLUE_TEXT='\033[34m'
_CLEAR_TEXT='\033[0m'
_BOLD_TEXT='\033[1m'

function echo_warning() { echo -e "${_YELLOW_TEXT}$*${_CLEAR_TEXT}"; }
function echo_error()   { echo -e "${_RED_TEXT}$*${_CLEAR_TEXT}";    }
function echo_success() { echo -e "${_GREEN_TEXT}$*${_CLEAR_TEXT}";  }
function echo_status()  { echo -e "${_BLUE_TEXT}$*${_CLEAR_TEXT}";   }

# Uncomment to debug
# set -x

################################################################################

# To add tests, add a file with the format `test_*.sh`

# TODO: Make sure this is run from the repo root

for test_script in tests/test_*.sh; do
    (

        echo "-> Sourcing $test_script"
        source "$test_script"

        # Normalize some vars if they are not set
        if [[ ! -v CONFOUND_TEST_NAME ]]; then export CONFOUND_TEST_NAME="test_script"; fi
        export CONFOUND_TEST_NAME
        export CONFOUND_TEST_PASSED_MSG
        export CONFOUND_TEST_FAILED_MSG

        echo_status "================ Testing $CONFOUND_TEST_NAME ================>"
        # run_this_test is defined by the test script itself.
        if run_this_test; then
            echo_success "* [$CONFOUND_TEST_PASSED_MSG]"
            echo_success " -> \"$CONFOUND_TEST_NAME\" PASS"
        else
            echo_error "$CONFOUND_TEST_FAILED_MSG"
            echo_error " -> \"$CONFOUND_TEST_NAME\" FAIL"
            # TODO: A variable that lets you waive this test
            exit 3
        fi
        echo_status "================ End of test $CONFOUND_TEST_NAME ============>"
    )
done
