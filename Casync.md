# Content Addressable Data Synchronizer

Some notes on the casync project. This project's goal is to synchronize data
across machines, similarly to rsync. And takes other use cases such a
filesystem snapshots (eg: Docker images) into account.

* homepage: https://github.com/systemd/casync
* Go implementation: https://github.com/folbricht/desync
* announce video: https://www.youtube.com/watch?v=JnNkBJ6pr9s

casync seems to get a lot of things right. It's a simple design and it's clear
from the video presentation that the author took a lot of use-cases into
account.

It was surprising to me that not more people have adopted it. After having
used it for a bit, it seems quite clear why: the CLI tooling interface isn't
quite right which makes it harder than necessary to use. For once Lennart
Poettering didn't build a tool that is opinionated enough, the flexibility is
the main issue.

## catar

One interesting sub-aspect of the project is that it introduces a new file
archive format: `catar`. Unlike the old Tape ARchive format, `catar` is
reproducible by design. And takes into account both high-fidelity backups
where even the extended file attributes are stored, and low-fidelity where
only filenames and executable bits are needed as a metadata (like Git and
NAR).

I wish somebody wrote a `catar` CLI that only wraps that aspect of the
project, and then starts integrating it will `git archive` and other projects.
