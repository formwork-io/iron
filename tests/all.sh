#!/usr/bin/env bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TOP_DIR="$DIR"/../
cd "$DIR" || exit 1

export TOP_DIR="$DIR"/..
export IRON_FUNCS="$TOP_DIR/bin/iron-funcs"
for test_script in *.sh; do
    if [ "$test_script" == "all.sh" ]; then
        continue
    fi
    ./"$test_script"
done

