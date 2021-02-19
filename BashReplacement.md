# Bash Replacement

A collection of ideas for a new language intended at replacing bash.

## Observations on Bash

Bash has two modes: repl and scripting. Both modes work the same way but
should probably have different levels of strictness. REPL should be forgiving
but not scripting. It should be easy to copy-and-paste from the REPL to a
script for experimentation.

Bash's best *and* worst feature is that strings don't need to be quoted. This
makes it very easy to type and pass arguments to programs.

The fact that bash functions act like normal programs is also great, both are
integrated seamlessly.

Bash string escaping is causing a lot of trouble but is made better if one
knows how to use bash arrays properly.

Bash has a lot of weird syntax that has been slapped on top of each-other.

## New bash

Can declare new processes, new processes behave exactly like system processes

Has only one "hash" table which mixes exported and unexported variables

Lists of strings is the primary data type.

Lists are auto-splatted:

x=a b c
y=$x d e


## See also

http://www.oilshell.org/

https://github.com/saitoha/libsixel
