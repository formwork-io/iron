#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Pull in standard functions, e.g., default.
source "$DIR/.gosh.sh" || exit 1

### GENERAL ENV VARS ###
default DIR             "$DIR"
default CUSTOM_ENV      "$DIR/env.sh.custom"

### THE GO SHELL ###
default GOSH_SCRIPTS    "$DIR"/scripts

default CUSTOM_ENV  "$GL_DIR/env.sh.custom"

if [ -r "$CUSTOM_ENV_SH" ]; then
    source $CUSTOM_ENV_SH || exit 1
fi

