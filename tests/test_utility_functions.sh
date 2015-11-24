#!/usr/bin/env bash
source "$TOP_DIR"/.gosh.sh || exit 1

testIfFailedDieSuccess() {
    rslt=$(rslt2=$(exit 0); if-failed-die)
    local ec=$?
    assertEquals "Successful command should exit with 0" 0 $ec
}

testIfFailedDieSuccessWithStatus() {
    rslt=$(rslt2=$(exit 0); if-failed-die 42)
    local ec=$?
    assertEquals "Successful command (with status) should exit with 0" 0 $ec
}

testIfFailedDieFailure() {
    rslt=$(rslt2=$(exit 1); if-failed-die)
    local ec=$?
    assertEquals "Failed command should exit with 1" 1 $ec
}

testIfFailedDieFailureWithStatus() {
    rslt=$(rslt2=$(exit 1); if-failed-die 42)
    local ec=$?
    assertEquals "Failed command (with status) should exit with 42" 42 $ec
}

. "$(dirname "$BASH_SOURCE[0]")"/shunit2-2.1.6/src/shunit2
