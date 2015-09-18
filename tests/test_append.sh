#!/usr/bin/env bash
source "$TOP_DIR"/.gosh.sh || exit 1

testAppendPass() {
    # assign a random value to our testval
    local testval1="$RANDOM"
    # default its value to a random variable
    default _${testval1} $testval1
    # capture the dynamically created variable
    local dynamicVar="_$testval1"
    # eval its value
    eval actualVal=\$$dynamicVar
    # and assert the result is what we expect
    assertEquals $testval1 "$actualVal"
}

testAppendFail() {
    # assign a string to our testval
    default testval2 "this works"
    # try it again
    default testval2 "this does not"
    # and assert the second assignment had no effect
    assertEquals "$testval2" "this works"
}

testVAppendOutput() {
    # shellcheck disable=SC2034
    OUTPUT=$(vdefault testval3 "loudly proclaim this variable set")
    # NOTE testval3 is defaulted in a subshell; it is unavailable
    # we only assert output from the function was generated
    # shellcheck disable=SC2016
    assertTrue "function failed to produce output" '[ ! -z "$OUTPUT" ]'
}

testAppendEmpty() {
    # assign an empty string to our testval
    default testval4 ""
    # and assert the result is the empty string
    assertEquals "$testval4" ""
}

. "$(dirname "$BASH_SOURCE[0]")"/shunit2-2.1.6/src/shunit2
