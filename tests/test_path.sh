#!/usr/bin/env bash
source "$TOP_DIR"/.iron.sh || exit 1

testNotInPath() {
    local testval="$(mktemp -d)"

    # assert temporary directory not-in-path
    if ! not-in-path $testval; then
        assertTrue "test assumption failed" "$testval in PATH: $PATH"
    fi

    # re-assert temporary directory not in-path
    if in-path $testval; then
        assertTrue "test assumption failed" "$testval in PATH: $PATH"
    fi

    rmdir "$testval"
}

testInPath() {
    local paths=($(echo $PATH | sed 's/:/\n/g'))

    for elem in ${paths[@]}; do
        # assert path element not-in-path
        if not-in-path "$elem"; then
            assertTrue "test assumption failed" "$elem not in PATH: $PATH"
        fi

        # re-assert path element in-path
        if ! in-path "$elem"; then
            assertTrue "test assumption failed" "$elem in PATH: $PATH"
        fi
    done
}

testVNotInPath() {
    local testval="$(mktemp -d)"

    # shellcheck disable=SC2034
    OUTPUT=$(vin-path "$testval")
    # we only assert output from the function was generated
    # shellcheck disable=SC2016
    assertTrue "function failed to produce output" '[ ! -z "$OUTPUT" ]'

    # shellcheck disable=SC2034
    OUTPUT=$(vnot-in-path "$testval")
    # we only assert output from the function was generated
    # shellcheck disable=SC2016
    assertTrue "function failed to produce output" '[ ! -z "$OUTPUT" ]'

    rmdir "$testval"
}

testVInPath() {
    local paths=($(echo $PATH | sed 's/:/\n/g'))

    for elem in ${paths[@]}; do
        # shellcheck disable=SC2034
        OUTPUT=$(vin-path "$elem")
        # we only assert output from the function was generated
        # shellcheck disable=SC2016
        assertTrue "function failed to produce output" '[ ! -z "$OUTPUT" ]'

        # shellcheck disable=SC2034
        OUTPUT=$(vnot-in-path "$elem")
        # we only assert output from the function was generated
        # shellcheck disable=SC2016
        assertTrue "function failed to produce output" '[ ! -z "$OUTPUT" ]'
    done
}

. "$(dirname "$BASH_SOURCE[0]")"/shunit2-2.1.6/src/shunit2
