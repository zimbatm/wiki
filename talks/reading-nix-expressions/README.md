---
marp: true
title: Reading Nix expressions
author: zimbatm
tags: Nix, Talk
description: View the slide with "Slide Mode".
---

# Reading the Nix expressions language

by zimbatm <https://zimbatm.com>

slide: <https://zimbatm.com/talks/reading-nix-expressions/>

keywords: #pure, #functional, #lazy

---

Once upon a time...

---

## `pkgs/applications/misc/hello/default.nix`

```nix
{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "hello";
  version = "2.10";

  src = fetchurl {
    url = "mirror://gnu/hello/${pname}-${version}.tar.gz";
    sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
  };

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A program that produces a familiar, friendly greeting";
    longDescription = ''
      GNU Hello is a program that prints "Hello, world!" when you run it.
      It is fully customizable.
    '';
    homepage = https://www.gnu.org/software/hello/manual/;
    changelog = "https://git.savannah.gnu.org/cgit/hello.git/plain/NEWS?h=v${version}";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.eelco ];
    platforms = platforms.all;
  };
}
```

---

## `configuration.nix`

```nix
{ config, pkgs, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.grub.device = "/dev/sda";
  fileSystems."/".device = "/dev/disk/by-label/nixos";

  # Enable the OpenSSH server.
  services.sshd.enable = true;
}
```

---

## `shell.nix`

```nix
with import <nixpkgs> {};
mkShell {
  buildInputs = [ mdsh ];
}
```

---

# JSON value

---

| JSON | Nix | Name |
| ---- | --- | ---- |
| `"foo"` | `"foo"` | string |
| `10` | `10` | int |
| `5.0` | `5.0` | float |
| `[1,2]` | `[1 2]` | list |
| `{"foo": 5}` | `{ foo = 4; }` | set / attrset |
| `null` | `null` | null |
| `true` `false` | `true` `false` | bool |

---

## Put together

```nix
{
  attrsets = { key = "value"; };
  lists = [ 1 2 3 ];
  strings = "hello";
  integers = 10;
  floats = 1.337;
  bools = [ true false ];
  nulls = null;
}
```

---

## Strings

```nix
"some simple string"
```

```nix
'''
  multiline
  strings
'''
```

```nix
https://urls.com
```

---

## Paths

```shell=
export NIX_PATH=/home/zimbatm/.nix-defexpr/channels:nixpkgs=/home/zimbatm/src/nixpkgs
```

```nix
{
  relative_path = ./relative;
  absolute_path = /etc/password;
  hpath = ~/.config/nixpkgs/config.nix;
  spath = <nixpkgs>;
}
```

---

# Functions

---

lambda curry
```nix
a: b: a + b
```

keyword arguments
```nix
{ a, b }: a + b
```

talk about scoping

---

## Keyword arguments - more

```nix
{ stdenv
, libz ? null
, ... }@args:
args
```

---

## `builtins`

* `toString <value>`
* `import <path>`
* `throw <string>`
* `derivation <attrs>`
* `builtins.toJSON <value>`

---

# Keywords

---

## `let .. in ...`

```nix
let
  hello = pkgs.hello;
  pkgs = import <nixpkgs> {};
in
  hello
```

---

## `rec`

```nix
rec {
  name = "${pname}-${version}";
  pname = "hello";
  version = "1.4.2";
  
  src = {
    url = "https://github.com/gnu/hello/tarballs/${version}.tar.gz";
  };
}
```

---

## `with`

```nix
pkgs:
{
  buildInputs = with pkgs; [ libxml2 libxslt ];
}
```

---

## `inherit`

```nix
pkgs:
{
  inherit (pkgs) gcc cmake;
}
```
==
```nix
pkgs:
{
  gcc = pkgs.gcc;
  cmake = pkgs.cmake;
}
```

---

```nix
pkgs: {
  inherit pkgs;
}
```
==
```nix
pkgs: {
  pkgs = pkgs;
}
```

---

## `if .. then .. else`

```nix
if true then "yes" else "no"
```

## `assert`

```nix
let
  x = import ./x.nix;
in
  assert builtins.typeOf x == "set";
  x
```

---

# Operators

---

## attrset operators

```nix
{
  fileSystems."/".device = "/dev/disk/by-label/nixos";
}
```

```nix
pkgs:
pkgs.hello or pkgs.world
```

```nix
pkgs:
assert pkgs ? hello;
pkgs.hello
```

---

## boolean operators

```nix
true || false
```

```nix
true && false
```

```nix
true -> false
```

---

## string interpolation

```nix
pkgs:
'''
  ${pkgs.hello}/bin/hello > $out
'''
```

---

## more

```nix
{ a = 4; } // { b = 5; }
```

---

# Interlude

---

## Functional

## Lazy

## Pure

---

# Debugging

## `error: cannot coerce an integer to a string`

add `toString`

## `__toString`

```nix
let
  obj = {
    name = "foo";
    __toString = self: self.name;
  };
in
  "${obj}"
# => "foo"
```

## `__functor`

```nix
let
  adder = {
    __functor = a: b: a + b;
  }
in
  adder 4 5
# => 9
```

---

# The end

* <https://github.com/NixOS/nixpkgs>
* `nix repl`

Thanks for listening!