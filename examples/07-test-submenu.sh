#!/usr/bin/env bash

# The next three lines are for the fe shell.
export SCRIPT_NAME="test-submenu"
export SCRIPT_HELP="Mimic a submenu."
[[ "$GOGO_IRON_SOURCE" -eq 1 ]] && return 0

# Normal script execution starts here.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IRON_SCRIPTS="$DIR"/submenu \
    IRON_PROMPT="submenu iron (?|#)> " \
    $IRON_PATH $@
exit 0

