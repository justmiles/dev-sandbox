# runs at boot; run with `nix-env -i -f ~/package.nix`
with import <nixpkgs> {};
buildEnv {
  name = "user-packages";
  paths = [
    # Add nix packages here to install them on container start
    # e.g.,
    # hello
  ];
}
