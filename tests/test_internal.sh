#!/usr/bin/env bash
source "$TOP_DIR"/.iron.sh || exit 1

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

test_g_in_path() {
    # assert PATH is usable for testing
    # shellcheck disable=SC2016
    assertTrue "test assumption failed" '[ ! -z "$PATH" ]'

    # PATH -> to array
    local path_array
    OLDIFS=$IFS
    IFS=":" path_array=($PATH)
    IFS=$OLDIFS
    for path in "${path_array[@]}"; do
        _g_in_path "$path"
        RC=$?
        assertEquals "0" $RC
    done
}

test_g_add_path() {
    # assert PATH is usable for testing
    # shellcheck disable=SC2016
    assertTrue "test assumption failed" '[ ! -z "$PATH" ]'

    # create a fake path
    local testpath1="/$RANDOM/$RANDOM/$RANDOM"

    # add it
    _g_add_path "$testpath1"
    _g_in_path "$testpath1"
    RC=$?
    # and assert it's there
    assertEquals 0 $RC
    # rm it
    _g_rm_path "$testpath1"
}

test_g_rm_path() {
    # assert PATH is usable for testing
    # shellcheck disable=SC2016
    assertTrue "test assumption failed" '[ ! -z "$PATH" ]'

    # create a fake path
    local testpath2="/$RANDOM/$RANDOM/$RANDOM"
    local curpath="$PATH"
    # and assert it's not there
    _g_in_path "$testpath2"
    RC=$?
    assertEquals 1 $RC

    # try removing it
    _g_rm_path "$testpath2"
    # and assert it had no effect
    _g_in_path "$testpath2"
    RC=$?
    assertEquals 1 $RC

    # add it
    _g_add_path "$testpath2"
    # and assert it's there
    _g_in_path "$testpath2"
    RC=$?
    assertEquals 0 $RC

    # rm it
    _g_rm_path "$testpath2"
    # and assert it's not there
    _g_in_path "$testpath2"
    RC=$?
    assertEquals 1 $RC
}

. "$(dirname "$BASH_SOURCE[0]")"/shunit2-2.1.6/src/shunit2
