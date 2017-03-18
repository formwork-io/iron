#!/usr/bin/env bash

# The next three lines are for the fe shell.
export SCRIPT_NAME="wrapper"
export SCRIPT_HELP="Simple wrapper example."
[[ "$GOGO_IRON_SOURCE" -eq 1 ]] && return 0

# Normal script execution starts here.
./wrap-this.sh

