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

Your scripts will be listed in a menu like the one shown below. Enter the items
you want and the go shell will execute them in order. Should anything fail,
execution stops. The last menu item chosen will be highlighted.

**Example**::

    gosh: the go shell
    https://github.com/formwork-io/gosh
    This is free software with ABSOLUTELY NO WARRANTY.
    
    Usage: <menu item>...
    Try 'help' for more information.
    
    Entering the shell, [CTRL-C] to exit.
    
    1: test-success
    2: test-failure
                                                                                                                                   
    
    gosh (?|#)> 


**Question mark displays help**::

    gosh (?|#)> ?
    
    1: test-success:    Mimic a successful script.
    2: test-failure:    Mimic a failing script.
                                                                    
**Execution stops on failure**::

    gosh (?|#)> 1 2 1
    (01-test-success.sh)
    Pretending to do something... SUCCESS
    (02-test-failure.sh)
    Pretending to do something... FAILED
  
    (02-test-failure.sh failed)
    gosh (?|#)> 

