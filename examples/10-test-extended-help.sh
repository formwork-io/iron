#!/usr/bin/env bash

# The next four lines are for the fe shell.
export SCRIPT_NAME="test-extended-help"
export SCRIPT_HELP="Demonstrate extended help."
export SCRIPT_EXTENDED_HELP="The test-extended-help script demonstrates \
how you can provide more detailed help documentation for a script. This \
may help in capturing additional documentation.

For example, this script supports one environment variable. So it is \
documented here.

\e[1mENVIRONMENT VARIABLES\e[0m

       FOO -- the FOO environment variable
"
[[ "$GOGO_IRON_SOURCE" -eq 1 ]] && return 0

# Normal script execution starts here.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"/../
cd "$DIR" || exit 1
source env.sh || exit 1
if [ ! -z "$FOO" ]; then
    echo "I have a FOO for you. Here it is: $FOO"
else
    echo "I have no FOO for you at this time. Check back later."
fi
exit 0

