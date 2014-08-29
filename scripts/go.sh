#!/usr/bin/env bash
#
# gosh: the go shell
# https://github.com/formwork-io/gosh
#
# Copyright (c) 2014 Nick Bargnesi
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
GOSH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GOSH_PATH="$GOSH_DIR"/"$(basename "$0")"
GOSH_SCRIPTS="${GOSH_SCRIPTS:=$GOSH_DIR}"
# Execute from GOSH_SCRIPTS
cd "$GOSH_SCRIPTS" || exit 1

# GS1: default go shell prompt.
GS1=${GS1:="gosh (?|#)> "}

function header {
    echo "gosh: the go shell"
    echo "https://github.com/formwork-io/gosh"
    echo "This is free software with ABSOLUTELY NO WARRANTY."
}
header

# Defines the SCRIPTS array for use everywhere else.
function redefine_scripts {
    # How go shell scripts are found.
    SCRIPTS=($(find "$GOSH_SCRIPTS" -maxdepth 1 -executable \
              -regex '.*/[0-9]+-.*\.sh' -exec basename {} \; | sort))
    if [ "${#SCRIPTS[@]}" -eq 0 ]; then
        echo "No scripts found."
        echo "See https://github.com/formwork-io/gosh."
        exit 1
    fi
}

# Prints help.
function help {
    header
    echo "--"
    echo "WHAT IS THIS MADNESS?!"
    echo
    echo -en "Even in all its glory, your codebase will inevitably make you "
    echo -en "want to gouge\nyour eyes out. It will demand you recite arcane "
    echo -en "incantations. You will need to\ncoax it to finish a simple "
    echo -en "task. It will be best friends with your teammates\nand "
    echo -en "visciously stab you behind your back when you need it most. "
    echo -en "It will be the\nbicycle you forget how to ride.\n"
    echo
    echo -en "The go shell will let you keep your eyes. You can forget the "
    echo -en "incantations. It\nwill do the coaxing, be your friend, and "
    echo -en "show you where the bicycle's pedals\nare lest you forget.\n"
    echo
    echo -en "Your scripts, if you have any, are listed below. Enter the "
    echo -en "items you want and\nthe go shell will execute them in order. "
    echo -en "Should anything fail, execution stops.\nThe last menu item "
    echo -en "chosen will be highlighted.\n"
    echo
    echo -en "See https://github.com/formwork-io/gosh for more.\n"
    echo "--"
}

# Resets the prompt.
function reset_prompt {
    PROMPT="\n${GS1}"
}

reset_prompt

# Flush the stdin buffer.
function flush_stdin {
    # note the current mode
    CUR_MODE=$(stty -g)
    # set completed read as 0 chars, read timeout of 0
    stty -icanon min 0 time 0
    # read until empty
    while read; do : ; done
    # restore old mode
    stty "$CUR_MODE"
}

# Echo $1 in reverse video.
function echo_hl {
    tput smso
    echo -n "$1"
    tput rmso
}

# Output a script header.
# E.g.:
#     script "./01-foo.sh"
# Prints:
#     (01-foo.sh)
function script {
    # output a script header
    local SCRIPT=$(basename "$1")
    echo -n "("
    echo_hl "$SCRIPT"
    echo ")"
    ./"$@"
    EC=$?
    flush_stdin
    return $EC
}

function menu_short() {
    echo
    redefine_scripts
    declare -i i=0
    while [ $i -lt ${#SCRIPTS[@]} ]; do
        source "${SCRIPTS[$i]}"
        declare -i LASTCMD=${LASTCMD:-0}
        if [ "$((LASTCMD))" -eq "$((i + 1))" ]; then
            tput smso
            echo -e "$((i + 1)): $SCRIPT_DESC"
            tput rmso
        else
            echo -e "$((i + 1)): $SCRIPT_DESC"
        fi
        i=$i+1
    done
    tabs -8
}

function menu_long() {
    echo
    redefine_scripts
    declare -i i=0
    while [ $i -lt ${#SCRIPTS[@]} ]; do
        source "${SCRIPTS[$i]}"
        declare -i LASTCMD=${LASTCMD:-0}
        if [ "$((LASTCMD))" -eq "$((i + 1))" ]; then
            tput smso
            echo -e "$((i + 1)): $SCRIPT_DESC:\t$SCRIPT_HELP"
            tput rmso
        else
            echo -e "$((i + 1)): $SCRIPT_DESC:\t$SCRIPT_HELP"
        fi
        i=$i+1
    done
    tabs -8
}

function loop() {
    echo
    echo "Usage: <menu item>..."
    echo "Try 'help' for more information."
    echo
    echo "Entering the shell, [CTRL-C] to exit."
    menu_short
    while true; do
        echo -en "$PROMPT"
        read REPLY || exit 0
        reset_prompt
        if [ -z "$REPLY" ]; then
            menu_short
            continue
        elif [ "$REPLY" == "?" ]; then
            menu_long
            continue
        elif [ "$REPLY" == "help" ]; then
            help
            menu_short
            continue
        elif [ "$REPLY" == "exit" ]; then
            exit 0
        fi
        for x in $REPLY; do
            # XXX check x is valid
            declare -i x=$x-1
            local CHOICE=${SCRIPTS[$x]}
            script "$CHOICE"
            declare -i EC=$?
            LASTCMD=$((x + 1))
            if [ "$EC" -ne 0 ]; then
                PROMPT="\n($CHOICE failed)\n${GS1}"
                # stop here, last CHOICE failed
                break
            fi
            # continue to next CHOICE
        done
    done
}

function args() {
    echo
    echo "Processing arguments before entering the shell."
    redefine_scripts
    for x in "$@"; do
        # XXX check x is valid
        declare -i x=$x-1
        local CHOICE=${SCRIPTS[$x]}
        script "$CHOICE"
        declare -i EC=$?
        LASTCMD=$((x + 1))
        if [ "$EC" -ne 0 ]; then
            PROMPT="\n($CHOICE failed)\n${GS1}"
            # stop here, last CHOICE failed
            break
        fi
        # continue to next CHOICE
    done
}

if [ $# -gt 0 ]; then
    args "$@"
fi
loop
