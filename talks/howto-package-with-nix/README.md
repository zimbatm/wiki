---
title: How to package with Nix
marp: true
author: zimbatm
tags: Nix, Talk
description: View the slide with "Slide Mode".
---

# How to package with Nix

by: zimbatm <https://zimbatm.com>

slide: <https://zimbatm.com/talks/howto-package-with-nix>

---

## Nixpkgs

<https://github.com/NixOS/nixpkgs>

---

# the derivation

```nix
{ name
, system
, builder
, args ? [ ]
, outputs ? [ "out" ]
, __structuredAttrs ? false
, outputHash ? null
, outputHashAlgo ? null
, outputHashMode ? null
, allowedReferences ? null
, disallowedReferences ? null
, allowedRequisites ? null
, disallowedRequisites ? null
, maxSize ? null
, maxClosureSize ? null
, ...
}@drvAttrs:

let
  self = {
    all = [ self ];
    name = name;
    outPath = ...;
    drvPath = ..."
    drvAttrs = drvAttrs
    type = "derivation";
    outputName = "out";
  };
in
  self
```

---

## stdenv.mkDerivation

`pkgs/stdenv/generic/setup.sh`

```nix
{ pname ? null
, version ? null
, name = "${pname}-${version}"

, buildInputs ? []
, nativeBuildInputs ? []

, phases = [
    "unpackPhase"
    "patchPhase"
    "configurePhase"
    "buildPhase"
    "checkPhase"
    "installPhase"
    "fixupPhase"
    "installCheckPhase"
    "distPhase"
  ]
 
, meta = {}
, passthru  ? {}
 
}: ...
```

---

## build phases cont

```nix
{
  # unpackPhase
, src ? null
 
  # patchPhase
, patches ? []
 
  # configurePhase
, configureFlags ? []
, cmakeFlags ? []
 
  # checkPhase
, doCheck ? false
 
  # installPhase
, outputs ? [ "out" ]
 
  # installCheckPhase
, doInstallCheck ? false

}: ...
```

---

## build hooks

```nix
{
  buildInputs = [ cmake ];
}
```

* autoreconfHook - run autreconf on broken autotools
* autoPatchelfHook - automatically fixup binaries, good for pre-built dist
* breakPointHook - add a breakpoint to failing builds
* makeWrapper - add wrapProgram utility
* pkg-config hooks

search for make

---

## packaging a C program

* all-packages.nix
* callPackage

---


## entering the build

cntr support

breakpointHook

---

## dev vs nixpkgs

---

# Python

* [poetry2nix](https://github.com/adisbladis/poetry2nix)

---

# Ruby

* [bundix](https://github.com/nix-community/bundix)

---

# Rust

* [carnix](https://github.com/nix-community/carnix)
* [naersk](https://github.com/nmattia/naersk/)

---

# Node

* [napalm](https://github.com/svanderburg/node2nix)
* [node2nix](https://github.com/svanderburg/node2nix)
* [yarn2nix](https://github.com/moretea/yarn2nix)

---

# Go

* [dep2nix](https://github.com/nixcloud/dep2nix)
* [vgo2nix](https://github.com/adisbladis/vgo2nix)

```nix
{ buildGoPackage, fetchFromGitHub }:
buildGoPackage rec {
  name = "vgo2nix-${version}";
  version = "example";
  src = fetchFromGitHub { ... };  # Incomplete
  goDeps = ./deps.nix;
}
```

---

