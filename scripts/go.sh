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
export GOSH_DIR GOSH_PATH GOSH_SCRIPTS
# Execute from GOSH_SCRIPTS
cd "$GOSH_SCRIPTS" || exit 1

# GOSH_PROMPT: go shell prompt.
GOSH_PROMPT=${GOSH_PROMPT:="gosh (?|#)> "}

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

# Returns 0 if $1 looks like an int greater than 0, false otherwise.
function valid_item {
    if [[ "$1" =~ ^[1-9][0-9]*$ ]]; then
        return 0
    fi
    return 1
}

# Source script $1, defaulting VARS as needed.
function source_script {
    unset SCRIPT_NAME SCRIPT_HELP SCRIPT_EXTENDED_HELP
    source "$1"
    if [ -z "$SCRIPT_NAME" ]; then
        SCRIPT_NAME="$(basename "$1")"
    fi
    if [ -z "$SCRIPT_HELP" ]; then
        SCRIPT_HELP="This script has no help."
    fi
    if [ -z "$SCRIPT_EXTENDED_HELP" ]; then
        SCRIPT_EXTENDED_HELP="This script has no extended help."
    fi
}

function warn_item() {
    echo -e "\nMenu items are between 1 and ${#SCRIPTS[@]}."
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
    PROMPT="\n${GOSH_PROMPT}"
}

reset_prompt

# Drain the stdin buffer.
function drain_stdin {
    # any input on stdin?
    while read -t 0; do
        read
    done
}

# Strip the color codes in $1.
function strip_color {
    echo -en "$@" \
        | sed -E "s/"$'\E'"\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g"
}

# Echo $1 in reverse video.
function echo_hl {
    echo -en "\e[7m$1\e[0m"
}

# Echo $1 in normal video.
function echo_nohl {
    echo -en "\e[0m$1\e[0m"
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
    echo
    ./"$@"
    EC=$?
    drain_stdin
    return $EC
}

# Output script help.
# E.g.:
#     script "./01-foo.sh"
# Prints:
#     <script filename>
#
#     NAME
#            SCRIPT_NAME
#
#     HELP
#            SCRIPT_HELP
#     
#     EXTENDED HELP
#            SCRIPT_EXTENDED_HELP
#
function script_help {
    source_script "$1"
    local fname=$(basename "$1")
    echo     "$fname"
    echo
    echo -e  "\e[1mNAME\e[0m"
    echo -e  "       $SCRIPT_NAME"
    echo
    echo -e  "\e[1mHELP\e[0m"
    echo -e  "       $SCRIPT_HELP"
    echo
    echo -e  "\e[1mEXTENDED HELP\e[0m"
    FOLD_WIDTH=$(($(tput cols) - 14))
    echo -e "$SCRIPT_EXTENDED_HELP" | fold -sw $FOLD_WIDTH | while read line; do
        echo "       $line"
    done
}

function menu_short() {
    echo
    declare -i i=0
    while [ $i -lt $NUM_SCRIPTS ]; do
        source_script "${SCRIPTS[$i]}"
        declare -i LASTCMD=${LASTCMD:-0}
        ITEM=$(printf "%${PADDING}s" "$((i + 1)):")
        if [ "$((LASTCMD))" -eq "$((i + 1))" ]; then
            local NAME=$(strip_color "$SCRIPT_NAME")
            echo_hl "$ITEM $NAME"
            echo
        else
            echo_nohl "$ITEM $SCRIPT_NAME"
            echo
        fi
        i=$i+1
    done
}

function menu_long() {
    declare -i i=0
    while [ $i -lt $NUM_SCRIPTS ]; do
        source_script "${SCRIPTS[$i]}"
        declare -i LASTCMD=${LASTCMD:-0}
        SCRIPT_NAME=$(strip_color "$SCRIPT_NAME")
        SCRIPT_HELP=$(strip_color "$SCRIPT_HELP")
        ITEM="$((i + 1)): $SCRIPT_NAME:\t$SCRIPT_HELP"
        if [ "$((LASTCMD))" -eq "$((i + 1))" ]; then
            echo_hl "$ITEM"
            echo
        else
            echo_nohl "$ITEM"
            echo
        fi
        i=$i+1
    done
}

function process_input() {
    while (($#)); do
        # special case; allow exit in input arrays
        if [ "$1" == "exit" ]; then
            exit 0
        fi

        # does $1 look like an int greater than 0?
        if ! (valid_item "$1"); then
            warn_item
            # discard all remaining input
            break
        fi

        # does $1 fall outside the range of menu items?
        if [ "$1" -gt ${#SCRIPTS[@]} ]; then
            warn_item
            # discard all remaining input
            break
        fi

        # SCRIPTS is a zero-based array so decrement
        # menu item (menu item 1 becomes choice 0)
        local x=$(($1 - 1))
        local CHOICE=${SCRIPTS[$x]} || break

        # Run the script...
        script "$CHOICE"

        # ... and capture its exit status
        declare -i EC=$?

        LASTCMD=$(($1))
        if [ "$EC" -ne 0 ]; then
            PROMPT="\n($CHOICE failed)\n${GOSH_PROMPT}"
            # stop here, last CHOICE failed
            break
        fi

        # continue to next CHOICE
        shift
    done
}

function loop() {
    echo
    echo "Entering the shell, [CTRL-C] to exit."
    menu_short
    while true; do
        echo -en "$PROMPT"
        read -a REPLY || exit 0
        reset_prompt
        if [ "${#REPLY[@]}" -eq 0 ]; then
            menu_short
            continue
        elif [ "${#REPLY[@]}" -eq 1 ]; then
            if [ "${REPLY[0]}" == "?" ]; then
                echo
                menu_long | column -t -s '	'
                continue
            elif [ "${REPLY[0]}" == "help" ]; then
                help
                menu_short
                continue
            fi
        fi
        process_input "${REPLY[@]}"
        redefine_scripts
    done
}

function args() {
    echo
    echo "Processing arguments before entering the shell."
    process_input "$@"
    echo "Processing arguments before entering the shell."
}

redefine_scripts
if [ $# -gt 0 ]; then
    args "$@"
else
    echo
    echo "Usage: <menu item>..."
    echo "Try 'help' for more information."
fi
loop

