#!/usr/bin/env bash

# The next three lines are for the go shell.
export SCRIPT_HELP="Mimic a failing script that does some processing."
export SCRIPT_DESC="test-sleep-and-fail"
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0

# Normal script execution starts here.
echo -n "Pretending to do something... "
sleep 1
echo "FAILED"
exit 1

