#!/usr/bin/env bash
source "$TOP_DIR"/.iron.sh || exit 1

testAppendToNew() {
    # assign a random value to our testval
    local testval1="$RANDOM"
    # append its value to a random variable
    # (creates the new variable)
    append _${testval1} $testval1
    # capture the dynamically created variable
    local dynamicVar="_$testval1"
    # eval its value
    eval actualVal=\$$dynamicVar
    # and assert the result is what we expect
    assertEquals $testval1 "$actualVal"
}

testAppendToExisting() {
    # assign a random value to our testval
    local testval2="$RANDOM"
    # append its value to a random variable
    # (creates the new variable)
    append _${testval2} $testval2
    # append the same value
    # (append to the existing variable)
    append _${testval2} ${testval2}FOO

    # capture its value
    local dynamicVar="_$testval2"
    # eval its value
    eval actualVal=\$$dynamicVar

    # and assert the result is what we expect
    assertEquals "$testval2:${testval2}FOO" "$actualVal"
}

testVAppendToNew() {
    # shellcheck disable=SC2034
    OUTPUT=$(vappend testval3 "loudly proclaim this variable set")
    # NOTE testval3 is defaulted in a subshell; it is unavailable
    # we only assert output from the function was generated
    # shellcheck disable=SC2016
    assertTrue "function failed to produce output" '[ ! -z "$OUTPUT" ]'
}

testVAppendToExisting() {
    # assign a random value to our testval
    local testval4="$RANDOM"
    # append its value to a random variable
    # (creates the new variable)
    append _${testval4} $testval4

    # shellcheck disable=SC2034
    OUTPUT=$(vappend testval4 "loudly proclaim this variable set")
    # NOTE testval3 is defaulted in a subshell; it is unavailable
    # we only assert output from the function was generated
    # shellcheck disable=SC2016
    assertTrue "function failed to produce output" '[ ! -z "$OUTPUT" ]'
    echo
}

. "$(dirname "$BASH_SOURCE[0]")"/shunit2-2.1.6/src/shunit2
