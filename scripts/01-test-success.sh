#!/usr/bin/env bash

# The next three lines are for the go shell.
export SCRIPT_HELP="Mimic a successful script."
export SCRIPT_DESC="test-success"
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0

# Normal script execution starts here.
echo -n "Pretending to do something... "
echo "SUCCESS"
exit 0

