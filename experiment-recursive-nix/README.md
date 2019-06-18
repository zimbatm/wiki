# Recursive Nix experiment

Recursive Nix is the idea that Nix could be invoked from withing a Nix build.
This is not my idea, it's been around in the community. @edolstra (the creator
of Nix) has been talking about it.

If a project is using Nix as a build system, it would be nice if those could
be re-used when packaging the project for nixpkgs. At the moment this is only
possible by using Import From Derivation (IFD).

TODO: ping me if you want me to explain more clearly why IFD is undesirable
and the differences between IFD and recursive Nix.

This is a little experiment to see if it's possible to implement Recursive Nix
with today's tooling.

## V0

Ok so the basic idea is that there will be one derivation invoking nix again
in it's build.

NOTE: build sandboxing is enabled and the nix-daemon is running.

The outer derivation:
`default.nix`
```nix
with import <nixpkgs> {};
runCommand "recursive-nix" { buildInputs = [ nix ]; } ''
  nix-build ${./inner.nix} > $out
''
```

The inner derivation:
`inner.nix`
```nix
with import <nixpkgs> {};
runCommand "inside" {} ''
  echo FOO | tee $out
''
```

Trying things out:
```
$ nix-build
[snip]
error: creating directory '/nix/var': Permission denied
[snip]
```

### Debugging

Nix needs access to `/nix/var` to talk to the nix-daemon socket.

## V1

The nix configuration allows to poke holes in the sandbox. This is not very
desirable because it introduces impurities into the build and any user of that
nix code will also need to have the same impurities configured.

Add `/nix/var` to the sandboxPaths:

`/etc/nix/nix.conf`
```
extra-sandbox-paths = /nix/var
```

or add `nix.sandboxPaths = [ "/nix/var" ];` to my configuration.nix

```
$ systemctl restart nix-daemon
[snip]
$ nix-build
[snip]
error: file 'nixpkgs' was not found in the Nix search path (add it using $NIX_PATH or -I), at /nix/store/j1hayqcvwcl2ci2fl04vnhpf41h5jklh-foo.nix:1:13
[snip]
```

### Debugging

Ok so `NIX_PATH` is not set in the context of the build. Is it possible to
pass it along?

## V2

Propagate the same version of nixpkgs to the inner build:

`default.nix`
```nix
with import <nixpkgs> {};
runCommand "recursive-nix" { buildInputs = [ nix ]; } ''
  NIX_PATH=nixpkgs=${pkgs.path} nix-build ${./foo.nix} > $out
''
```

```
$ nix-build 
[snip]
error: cannot open connection to remote store 'daemon': reading from file: Connection reset by peer
[snip]
```

### Debugging

Wut?

```
$ journalctl -u nix-daemon
[snip]
Jun 17 15:42:59 x1 nix-daemon[6810]: error processing connection: user 'nixbld1' is not allowed to connect to the Nix daemon
[snip]
```

/etc/nix/nix.conf has `allowed-users = *` adding `@nixbld` to the
trusted-users doesn't help.

Actually looking into the source code:

https://github.com/nixos/nix/blob/2.2.2/src/nix-daemon/nix-daemon.cc#L1016-L1018

Since the user is part of the the `buildUserGroup` is it disallowed. The only
way to fix this is to fork nix.

## V3

Forking nix and using [Niv](https://github.com/nmattia/niv/) to import that
into my system configuration:
```
$ niv add zimbatm/nix --branch allow-recursive-nix
Reading sources file
unpacking...
[0.8 MiB DL]
path is '/nix/store/j62jidqfyncj4xzxl947hvdby0prhfn9-b2068e762d4c7c107ccaf87346fef14879b16066.tar.gz'
Writing new sources file
```

and in the configuration.nix
```
nix.package = pkgs.nix.override {
  src = (import ./nix/sources.nix).nix;
  fromGit = true;
};
```

after a `nixos-rebuild switch`:
```
$ nix-build
these derivations will be built:
  /nix/store/q4jxahknj5njrqpd8qv5qfxndmwpc7zi-recursive-nix.drv
building '/nix/store/q4jxahknj5njrqpd8qv5qfxndmwpc7zi-recursive-nix.drv'...
/nix/store/9l599ms92ywmcqgdmm6anqw7yi0pr238-recursive-nix

$ cat /nix/store/9l599ms92ywmcqgdmm6anqw7yi0pr238-recursive-nix
/nix/store/6wr36r1d05phhn3nvdizffx5jrjndw8r-inside
```

Success!!

## Conclusion

Recursive Nix is possible today with a single line patch to Nix and a small
configuration change. It's possible but the next step is to think about if
it's desirable or not? If yes then we could maybe make those changes
permanent.

## Known issues

* The `/nix/var` hole has security and build impurity implications that need
  to be studied further.

* Any builtins fetchers will fail because they are executed by the client, which
is sandboxed by the build.

* Nixpkgs overlays and other configurations are not propagated to the inner
build.

* Why does the Nix source code denies the builder group to the nix daemon? There
must be a reason behind it which I do not know yet.

* Nixpkgs is going to be evaluated for every derivation that uses recursive nix.
On the non-cached case it will be much slower than using IFD.

## See also

* [RET cont RFC](https://discourse.nixos.org/t/new-rfcs-40-ret-cont-recursive-nix-open-for-shepherd-nominations/2075)
* [@edolstra's Nix experiment](https://github.com/edolstra/nix/commit/1a27aa7d64ffe6fc36cfca4d82bdf51c4d8cf717)

## Comments

Discussion should be happening over there:
https://discourse.nixos.org/t/recursive-nix-experiment/3206
