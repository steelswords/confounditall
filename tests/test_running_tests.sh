#!/usr/bin/env bash

set -ue -o pipefail

export CONFOUND_TEST_NAME="Test unit test framework"
export CONFOUND_TEST_PASSED_MSG="Unit tests can run"
export CONFOUND_TEST_FAILED_MSG="Unit test framework is broken."

run_this_test() {
    echo "This succeeds."
}
