#!/usr/bin/env bash

# The next three lines are for the fe shell.
export SCRIPT_NAME="test-failure"
export SCRIPT_HELP="Mimic a failing script."
[[ "$GOGO_IRON_SOURCE" -eq 1 ]] && return 0

# Normal script execution starts here.
echo -n "Pretending to do something... "
echo "FAILED"
exit 1

