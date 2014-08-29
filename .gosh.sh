#!/usr/bin/env bash

# Default a variable named $1 to $2 unless already set.
# This is more readable than expansion syntax.
# E.g.,
#    default foo bar
# vice:
#    export FOO="${FOO:=$BAR}"
function default {
    if [ $# -ne 2 ]; then
        echo "usage: default <variable> <default value>"
        echo "(got: $@)"
        exit 1
    fi
    eval __=\$$1
    if [ -z "$__" ]; then
        export $1="$2"
    fi
}

