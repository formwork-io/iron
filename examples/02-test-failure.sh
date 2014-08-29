#!/usr/bin/env bash

# The next three lines are for the go shell.
export SCRIPT_HELP="Mimic a failing script."
export SCRIPT_DESC="test-failure"
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0

# Normal script execution starts here.
echo -n "Pretending to do something... "
echo "FAILED"
exit 1

