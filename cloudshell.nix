{ pkgs ? import <nixpkgs> { }
, pkgsLinux ? import <nixpkgs> { system = "x86_64-linux"; }
}:

pkgs.dockerTools.buildImage {
  name = "shell";
  copyToRoot = pkgs.buildEnv {
    pathsToLink = [ "/bin" ];
    name = "image-root";
    paths = [
      pkgs.nomad
      pkgs.gotty
    ];
  };
}
  