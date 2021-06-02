let
  sources = import ./nix/sources.nix {};
  pkgs = import sources.nixpkgs {};

  # TODO any of the other pydeps from treecl-nix required here for biopython to function?
  myPython27Packages = pkgs.python27Packages // rec {
    biopython          = pkgs.python27Packages.callPackage ./nix/pydeps/biopython {};
  };

in
  myPython27Packages.callPackage ./default.nix { inherit (myPython27Packages) biopython; }
