#!/usr/bin/env bash

# The next three lines are for the go shell.
export SCRIPT_HELP="Simple submenu script."
export SCRIPT_DESC="submenu-item"
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0

# Normal script execution starts here.
echo -n "Pretending to do something... "
echo "SUCCESS"
exit 0

