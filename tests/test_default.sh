#!/usr/bin/env bash
source "$TOP_DIR"/.gosh.sh || exit 1

testDefaultPass() {
    # assign a variable at random
    local testval1="$RANDOM"
    default _${testval1} $testval1

    # _$testval1 should default to $testval
    local dynamicVar="_$testval1"
    eval actualVal=\$$dynamicVar
    assertEquals $testval1 "$actualVal"
}

testDefaultFail() {
    default testval2 "this works"
    default testval2 "this does not"
    assertEquals "$testval2" "this works"
}

testVDefaultOutput() {
    # shellcheck disable=SC2034
    OUTPUT=$(vdefault testval3 "loudly proclaim this variable set")
    # shellcheck disable=SC2016
    assertTrue "function failed to produce output" '[ ! -z "$OUTPUT" ]'
}

. "$(dirname "$BASH_SOURCE[0]")"/shunit2-2.1.6/src/shunit2
