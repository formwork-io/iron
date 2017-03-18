#!/usr/bin/env bash
source "$TOP_DIR"/.iron.sh || exit 1

testPrependToNew() {
    # assign a random value to our testval
    local testval1="$RANDOM"
    # prepend its value to a random variable
    # (creates the new variable)
    prepend _${testval1} $testval1
    # capture the dynamically created variable
    local dynamicVar="_$testval1"
    # eval its value
    eval actualVal=\$$dynamicVar
    # and assert the result is what we expect
    assertEquals $testval1 "$actualVal"
}

testPrependToExisting() {
    # assign a random value to our testval
    local testval2="$RANDOM"
    # prepend its value to a random variable
    # (creates the new variable)
    prepend _${testval2} $testval2
    # prepend the same value
    # (prepends to the existing variable)
    prepend _${testval2} ${testval2}FOO

    # capture its value
    local dynamicVar="_$testval2"
    # eval its value
    eval actualVal=\$$dynamicVar

    # and assert the result is what we expect
    assertEquals "${testval2}FOO:$testval2" "$actualVal"
}

testVPrependToNew() {
    # shellcheck disable=SC2034
    OUTPUT=$(vprepend testval3 "loudly proclaim this variable set")
    # NOTE testval3 is defaulted in a subshell; it is unavailable
    # we only assert output from the function was generated
    # shellcheck disable=SC2016
    assertTrue "function failed to produce output" '[ ! -z "$OUTPUT" ]'
}

testVPrependToExisting() {
    # assign a random value to our testval
    local testval4="$RANDOM"
    # prepend its value to a random variable
    # (creates the new variable)
    prepend _${testval4} $testval4

    # shellcheck disable=SC2034
    OUTPUT=$(vprepend testval4 "loudly proclaim this variable set")
    # NOTE testval3 is defaulted in a subshell; it is unavailable
    # we only assert output from the function was generated
    # shellcheck disable=SC2016
    assertTrue "function failed to produce output" '[ ! -z "$OUTPUT" ]'
    echo
}

. "$(dirname "$BASH_SOURCE[0]")"/shunit2-2.1.6/src/shunit2
