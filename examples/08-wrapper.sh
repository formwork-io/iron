#!/usr/bin/env bash

# The next three lines are for the go shell.
export SCRIPT_NAME="wrapper"
export SCRIPT_HELP="Simple wrapper example."
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0

# Normal script execution starts here.
./wrap-this.sh

