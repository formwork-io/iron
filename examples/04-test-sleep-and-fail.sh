#!/usr/bin/env bash

# The next three lines are for the go shell.
export SCRIPT_NAME="test-sleep-and-fail"
export SCRIPT_HELP="Mimic a failing script that does some processing."
[[ "$GOGO_GOSH_SOURCE" -eq 1 ]] && return 0

# Normal script execution starts here.
echo -n "Pretending to do something... "
sleep 1
echo "FAILED"
exit 1

