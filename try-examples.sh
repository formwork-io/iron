#!/usr/bin/env bash
#
# Executes from the top-level dir
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${DIR}" || exit 1
source env.sh || exit 1

export IRON_CONTRIB="$DIR"/examples/contrib
export IRON_SCRIPTS="$DIR"/examples

rlwrap -H .ironhst scripts/fe.sh "$@"

