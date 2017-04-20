Iron
====

the fe shell
------------

**This is free software with ABSOLUTELY NO WARRANTY.**

.. image:: https://badge.buildkite.com/1cc84fbae89b6ccc0dee4530f6d00d18f298b9d44f6d73b89f.svg?branch=master
    :target: https://buildkite.com/nbargnesi/formwork-io-slash-iron
.. image:: https://goreportcard.com/badge/github.com/formwork-io/iron
    :target: https://goreportcard.com/report/github.com/formwork-io/iron
.. image:: https://img.shields.io/github/license/formwork-io/iron.svg
    :target: https://github.com/formwork-io/iron/blob/master/LICENSE
.. image:: https://img.shields.io/github/release/formwork-io/iron.svg
    :target: https://github.com/formwork-io/iron/releases

Even in all its glory, your codebase will inevitably make you want to gouge
your eyes out. It will demand you recite arcane incantations. You will need to
coax it to finish a simple task. It will be best friends with your teammates
and visciously stab you behind your back when you need it most. It will be the
bicycle you forget how to ride.

Iron will let you keep your eyes. You can forget the incantations. It
will do the coaxing, be your friend, and show you where the bicycle's pedals
are lest you forget.

Your scripts will be listed in a menu like the examples below. Enter the items
you want and Iron will execute them in order. Should anything fail, execution
stops. The last menu item chosen will be highlighted.

.. contents::


Examples
--------

Example Menu
++++++++++++

Here's an example for a codebase with two scripts ``test-success`` and
``test-failure``::

    iron: the fe shell
    https://github.com/formwork-io/iron
    This is free software with ABSOLUTELY NO WARRANTY.

    Usage: <menu item>...
    Try 'help' for more information.

    Entering the shell, [CTRL-C] to exit.

    1: test-success
    2: test-failure


    iron (?|#|#?)>

Extended Menu
+++++++++++++

Here's an example showing the same scripts in the extended menu via ``?``::

    iron (?|#|#?)> ?

    1: test-success:    Mimic a successful script.
    2: test-failure:    Mimic a failing script.

Script Help
+++++++++++

Here's an example showing a script's help via ``1?``::

    iron (?|#|#?)> 1?

    1: test-success:    Mimic a successful script.
    2: test-failure:    Mimic a failing script.
    01-test-success.sh

    **NAME**
           test-success

    **HELP**
           Mimic a successful script.

    **EXTENDED HELP**
           This script has no extended help.

Execution Stops on Failure
++++++++++++++++++++++++++

The fe shell executes scripts in order. Should a script fail, execution will
stop. In the following example, the third script is not run as the previous
script fails::

    iron (?|#|#?)> 1 2 1
    (01-test-success.sh)
    Pretending to do something... SUCCESS
    (02-test-failure.sh)
    Pretending to do something... FAILED

    (02-test-failure.sh failed)
    iron (?|#|#?)>

Try It
------

A modern version of the `GNU Bash`_ shell and the `Readline Library`_ wrapper
`rlwrap`_ are required. Then paste this into your terminal::

    git clone https://github.com/formwork-io/iron.git
    cd iron
    ./try-examples.sh

.. _GNU Bash: https://www.gnu.org/software/bash/bash.html
.. _Readline Library: http://cnswww.cns.cwru.edu/~chet/readline/rltop.html
.. _rlwrap: http://utopia.knoware.nl/~hlub/rlwrap/#rlwrap


Get It
------

The fe shell is composed of a few files at the root of your codebase::

    .
    |-- .iron.sh
    |-- env.sh
    |-- fe.sh
    \-- scripts
        |-- fe.sh

    1 directory, 4 files

You can get them easily by running the `overlay`_ script from the root of your
codebase::

    cd my-project
    wget --content-disposition \
         https://raw.githubusercontent.com/formwork-io/iron/latest/overlay.sh
    bash overlay.sh

Take a look at your version control status (e.g., ``git status``) to see
exactly what the effect was.

.. _overlay: https://raw.githubusercontent.com/formwork-io/iron/latest/overlay.sh


Use It
------

Add executable scripts to the ``scripts`` directory, folowing this convention::

    scripts/01-<script_name>.sh
    scripts/02-<script_name>.sh

For example::

    scripts/01-clean.sh
    scripts/02-build.sh
    scripts/03-deploy.sh

Each script should have four lines included at the top immediately following
the interpreter directive::

    #!/usr/bin/env bash
    export SCRIPT_NAME="example"
    export SCRIPT_HELP="Short summary of what this script does."
    export SCRIPT_EXTENDED_HELP="Extended help for this script... "
    [[ "$GOGO_IRON_SOURCE" -eq 1 ]] && return 0

The variable exports aren't *strictly required* though **the following line
should absolutely be included**::

    [[ "$GOGO_IRON_SOURCE" -eq 1 ]] && return 0

This prevents the script from running any further when the fe shell sources
the script to create its menus.


Customize It
------------

IRON_PROMPT
  Change the fe shell prompt.

  For example::

    IRON_PROMPT="the fe shell: examples> " ./try-examples.sh

    iron: the fe shell
    https://github.com/formwork-io/iron
    This is free software with ABSOLUTELY NO WARRANTY.

    Usage: <menu item>...
    Try 'help' for more information.

    Entering the shell, [CTRL-C] to exit.

    1: test-success
    2: test-failure
    3: test-sleep-success
    4: test-sleep-and-fail
    5: test-close-stdin
    6: test-close-stdout
    7: test-submenu

    the fe shell: examples>

IRON_SCRIPTS
  Change where the fe shell looks for scripts. For example, here's a fe shell
  script that behaves like an *admin* submenu::

    #!/usr/bin/env bash
    export SCRIPT_HELP="Access administrative menu."
    export SCRIPT_NAME="admin"
    [[ "$GOGO_IRON_SOURCE" -eq 1 ]] && return 0

    DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    IRON_SCRIPTS="$DIR"/admin IRON_PROMPT="admin iron (?|#|#?)> " $IRON_PATH
    exit 0

