#!/usr/bin/env bash

# The next three lines are for the fe shell.
export SCRIPT_NAME="submenu-item"
export SCRIPT_HELP="Simple submenu script."
[[ "$GOGO_IRON_SOURCE" -eq 1 ]] && return 0

# Normal script execution starts here.
echo -n "Pretending to do something... "
echo "SUCCESS"
exit 0

