# Flake-lock source reader
with builtins;
let
  readJSON = f: fromJSON (readFile f);

  flakeLock = readJSON ../flake.lock;

  fetchers = {
    "github" = { owner, repo, rev, type }: hash:
      let
        outPath =
          fetchTarball {
            url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
            sha256 = hash;
          };
      in
        {
          inherit owner repo rev type outPath;
          __toString = self: self.outPath;
        };
  };

  fetchInput = name: node:
    let
      locked = node.locked;
      type = locked.type;
    in
      (fetchers.${type} or (throw "type ${type} not supported"))
        locked
        node.info.narHash
        ;
in
  assert flakeLock.version == 5;
  mapAttrs fetchInput flakeLock.nodes
