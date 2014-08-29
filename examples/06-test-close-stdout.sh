#!/usr/bin/env bash

# The next three lines are for the go shell.
export SCRIPT_HELP="Mimic a script that closes stdout."
export SCRIPT_DESC="test-close-stdout"
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0

# Normal script execution starts here.
echo "Closing stdout, script will fail on writing to stdout."
exec 1>&-
echo || exit 1
exit 0

