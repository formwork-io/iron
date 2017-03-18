#!/usr/bin/env bash
source "$TOP_DIR"/.iron.sh || exit 1

testRunSuccess() {
    rslt=$(run-or-die true)
    local ec=$?
    assertEquals "Successful run-or-die call should be quiet" "" "$rslt"
    assertEquals "Successful run-or-die call should exit with 0" 0 $ec
}

testRunFailure() {
    rslt=$(run-or-die false)
    local ec=$?
    assertEquals "Failed run-or-die call should be quiet" "" "$rslt"
    assertEquals "Failed run-or-die call should exit with 1" 1 $ec
}

testVRunSuccess() {
    rslt=$(vrun-or-die true)
    local ec=$?
    assertNotEquals "Successful vrun-or-die call should be verbose" "" "$rslt"
    assertEquals "Successful vrun-or-die call should exit with 0" 0 $ec
}

testVRunFailure() {
    rslt=$(vrun-or-die false)
    local ec=$?
    assertNotEquals "Failed vrun-or-die call should be verbose" "" "$rslt"
    assertEquals "Failed vrun-or-die call should exit with 1" 1 $ec
}

. "$(dirname "$BASH_SOURCE[0]")"/shunit2-2.1.6/src/shunit2
