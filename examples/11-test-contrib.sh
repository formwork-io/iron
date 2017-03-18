#!/usr/bin/env bash

# The next four lines are for the fe shell.
export SCRIPT_NAME="test-contrib"
export SCRIPT_HELP="Demonstrate use of IRON_CONTRIB scripts."
export SCRIPT_EXTENDED_HELP="The test-contrib script demonstrates how \
you can reuse functionality across scripts in a simple way.
"
[[ "$GOGO_IRON_SOURCE" -eq 1 ]] && return 0

# Normal script execution starts here.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"/../
source "$DIR"/env.sh || exit 1
use-iron-contrib || exit 1
echo "Calling 'Hello, world!' contrib function."
# Call the function provided by the example contrib script.
contrib_hello_world
exit 0

