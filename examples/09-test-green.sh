#!/usr/bin/env bash

# The next three lines are for the fe shell.
export SCRIPT_NAME="\e[32mtest-green\e[0m"
export SCRIPT_HELP="Demonstrate a colorful script name"
[[ "$GOGO_IRON_SOURCE" -eq 1 ]] && return 0

# Normal script execution starts here.
exit 0

