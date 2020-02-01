# Direnv

Homepage: https://direnv.net

## A list of all the direnv design mistakes that I know of

Things that are hard to change after the fact.

Naming `.envrc` and not `.env.sh` or `.direnv.sh`. Just a taste thing.

Not using a `[global]` section in the TOML config.

Stuffing too many things in the stdlib. Most direnv releases are just stdlib
changes. A better solution would be to create a plugin ecosystem for stdlib
functions (not too later for that!).

Not writing a comprehensive test suite. This makes changes much harder to
accept.
