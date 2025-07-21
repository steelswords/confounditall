# Tests

This `tests/` directory contains all the unit tests for the confounditall project.
The format of such tests is documented below:

# Test Format, or: How to Create a Test

All files of the format `test_*.sh` are run when calling the `run-tests.sh`
script.

Tests are expected to define the following variables, which `run-tests.sh` sources
from the test script itself.

## Variables

- `CONFOUND_TEST_NAME`: The name of the test
- `CONFOUND_TEST_PASSED_MSG`: The message to print when the test passes
- `CONFOUND_TEST_FAILED_MSG`: The messasge to print when the test fails

## Functions
- `run_this_test`: A function that takes zero arguments and runs the tests for
  a given file.
