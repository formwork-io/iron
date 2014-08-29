gosh
====

the go shell
------------

**This is free software with ABSOLUTELY NO WARRANTY.**

Even in all its glory, your codebase will inevitably make you want to gouge
your eyes out. It will demand you recite arcane incantations. You will need to
coax it to finish a simple task. It will be best friends with your teammates
and visciously stab you behind your back when you need it most. It will be the
bicycle you forget how to ride.

The go shell will let you keep your eyes. You can forget the incantations. It
will do the coaxing, be your friend, and show you where the bicycle's pedals
are lest you forget.

Your scripts will be listed in a menu like the examples below. Enter the items
you want and the go shell will execute them in order. Should anything fail,
execution stops. The last menu item chosen will be highlighted.

.. contents::

Examples
--------

**Example menu**::

    gosh: the go shell
    https://github.com/formwork-io/gosh
    This is free software with ABSOLUTELY NO WARRANTY.
    
    Usage: <menu item>...
    Try 'help' for more information.
    
    Entering the shell, [CTRL-C] to exit.
    
    1: test-success
    2: test-failure
                                                                                                                                   
    
    gosh (?|#)> 


**Extended menu via '?'**::

    gosh (?|#)> ?
    
    1: test-success:    Mimic a successful script.
    2: test-failure:    Mimic a failing script.
                                                                    
**Execution stops on failure**::

The go shell will execute items ``1``, ``2``, and ``1``. Since ``2`` fails,
execution stops.

    gosh (?|#)> 1 2 1
    (01-test-success.sh)
    Pretending to do something... SUCCESS
    (02-test-failure.sh)
    Pretending to do something... FAILED
  
    (02-test-failure.sh failed)
    gosh (?|#)> 


Try It
------

A modern version of the `GNU Bash`_ shell and the `Readline Library`_ wrapper
`rlwrap`_ are required. Then just::

    git clone https://github.com/formwork-io/gosh.git
    cd gosh
    ./try-examples.sh

.. _GNU Bash: https://www.gnu.org/software/bash/bash.html
.. _Readline Library: http://cnswww.cns.cwru.edu/~chet/readline/rltop.html
.. _rlwrap: http://utopia.knoware.nl/~hlub/rlwrap/#rlwrap


Get It
------

The go shell is composed of a few files at the root of your codebase.

    .
    ├── .gosh.sh
    ├── env.sh
    ├── go.sh
    └── scripts
        └── go.sh
    
        1 directory, 4 files

Run the `overlay`_ script from the root of your codebase::

    cd my-project
    wget --content-disposition \
         https://raw.githubusercontent.com/formwork-io/gosh/master/overlay.sh
    bash overlay.sh

Take a look at your version control status (e.g., ``git status``) to see
exactly what the effect was.

.. _overlay: https://raw.githubusercontent.com/formwork-io/gosh/master/overlay.sh
    

Use It
------

Add executable scripts to the ``scripts`` directory, folowing this convention::

    scripts/01-<script_name>.sh
    scripts/02-<script_name>.sh

For example::

    scripts/01-clean.sh
    scripts/02-build.sh
    scripts/03-deploy.sh

Each script should have three lines included at the top immediately following
the interpreter directive::

    #!/usr/bin/env bash
    export SCRIPT_HELP="Short summary of what this script does."
    export SCRIPT_DESC="example"
    [[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0

These three lines let the go shell create a menu for you::

    gosh (?|#)> ?
    1: example:              Short summary of what this script does.

Customizing
-----------

GOSH_PROMPT
  Change the go shell prompt.

  For example::

    GOSH_PROMPT="the go shell: examples> " ./try-examples.sh

    gosh: the go shell
    https://github.com/formwork-io/gosh
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
    
    the go shell: examples> 

GOSH_SCRIPTS
  Change where the go shell looks for scripts. For example, here's a go shell
  script that behaves like an *admin* submenu::

    #!/usr/bin/env bash
    export SCRIPT_HELP="Access administrative menu."
    export SCRIPT_DESC="admin"
    [[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0

    DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    GOSH_SCRIPTS="$DIR"/admin GOSH_PROMPT="admin gosh (?|#)> " $GOSH_PATH
    exit 0

