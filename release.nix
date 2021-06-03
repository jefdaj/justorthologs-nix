let
  sources = import ./nix/sources.nix {};
  pkgs = import sources.nixpkgs {};

  # TODO any of the other pydeps from treecl-nix required here for biopython to function?
  myPython27Packages = pkgs.python27Packages // {
    biopython = pkgs.python27Packages.callPackage ./nix/pydeps/biopython {};
  };
  myPython = myPython27Packages.python.withPackages (_: [ myPython27Packages.biopython ]);

in pkgs.callPackage ./default.nix { python = myPython; }
