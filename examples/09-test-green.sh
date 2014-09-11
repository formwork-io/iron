#!/usr/bin/env bash

# The next three lines are for the go shell.
export SCRIPT_NAME="\e[32mtest-green\e[0m"
export SCRIPT_HELP="Demonstrate a colorful script name"
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0

# Normal script execution starts here.
exit 0

