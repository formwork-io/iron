#!/usr/bin/env bash
source "$TOP_DIR"/.gosh.sh || exit 1

test_g_varset() {
    # assert PATH is usable for testing
    # shellcheck disable=SC2016
    assertTrue "test assumption failed" '[ ! -z "$PATH" ]'

    # and assert a 0 return with PATH set
    _g_varset PATH
    RC=$?
    assertEquals 0 $RC

    # and assert a 1 return with testInternal2 unset
    _g_varset testInternal2
    RC=$?
    assertEquals 1 $RC
}

test_g_varunset() {
    # assert PATH is usable for testing
    # shellcheck disable=SC2016
    assertTrue "test assumption failed" '[ ! -z "$PATH" ]'

    # and assert a 0 return with _G_VARUNSET unset
    _g_varunset _G_VARUNSET
    RC=$?
    assertEquals 0 $RC

    # and assert a 1 return with PATH set
    _g_varunset PATH
    RC=$?
    assertEquals 1 $RC
}

. "$(dirname "$BASH_SOURCE[0]")"/shunit2-2.1.6/src/shunit2
