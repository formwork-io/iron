#!/usr/bin/env bash
#
# Executes from the top-level dir
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${DIR}" || exit 1
source env.sh || exit 1

export GOSH_CONTRIB="$DIR"/examples/contrib
export GOSH_SCRIPTS="$DIR"/examples

rlwrap -H .goshhst scripts/go.sh "$@"

