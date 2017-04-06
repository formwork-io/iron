#!/usr/bin/env bash
source "$IRON_FUNCS" || exit 1

testOverridePass() {
    echo "should be empty string: \"$testval1\""
    # assign a string to our testval
    default testval1 "this works"
    # override it
    override testval1 "so does this"
    # and assert the second assignment overrode the first
    assertEquals "$testval1" "so does this"
}

testVOverrideOutput() {
    # shellcheck disable=SC2034
    OUTPUT=$(voverride testval2 "loudly proclaim this variable overridden")
    # NOTE testval2 is defaulted in a subshell; it is unavailable
    # we only assert output from the function was generated
    # shellcheck disable=SC2016
    assertTrue "function failed to produce output" '[ ! -z "$OUTPUT" ]'
}

testOverriderEmpty() {
    # assign an empty string to our testval
    override testval3 ""
    # and assert the result is the empty string
    assertEquals "$testval3" ""
}

. "$(dirname "$BASH_SOURCE[0]")"/shunit2-2.1.6/src/shunit2
