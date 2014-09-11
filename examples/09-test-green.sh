#!/usr/bin/env bash

# The next three lines are for the go shell.
export SCRIPT_HELP="Demonstrate a colorful script description."
export SCRIPT_DESC="\e[32mtest-green\e[0m"
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0

# Normal script execution starts here.
exit 0

