#!/usr/bin/env bash
#
# Executes from the top-level dir
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DIR
cd "${DIR}" || exit 1
source env.sh || exit 1

export IRON_CONTRIB="$DIR"/examples/contrib

rlwrap -H .ironhst scripts/fe.sh "$@"

