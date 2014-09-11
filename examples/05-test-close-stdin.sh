#!/usr/bin/env bash

# The next three lines are for the go shell.
export SCRIPT_NAME="test-close-stdin"
export SCRIPT_HELP="Mimic a script that closes stdin."
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0

# Normal script execution starts here.
echo -n "Closing stdin... "
exec 0>&-
echo "okay"
echo "Script will fail on reading from stdin."
read || exit 1
exit 0

