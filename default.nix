{ stdenv
, fetchurl
, makeWrapper
, buildPythonPackage
, biopython
}:

buildPythonPackage rec {
  name = "justorthologs-${version}";
  version = "7ab9104";
  src = ./.;
  propagatedBuildInputs = [
    biopython
  ];

  phases = "installPhase fixupPhase";

  #unpackPhase = ''
    #source $stdenv/setup
    #cd $TMPDIR
    #tar xvzf $src
  #'';

  installPhase = ''
    mkdir -p $out/bin
    cp $src/*.py $out/bin/
  '';

  # problem:  https://github.com/NixOS/nixpkgs/issues/11133
  # solution: https://github.com/NixOS/nixpkgs/pull/74942
  fixupPhase = if stdenv.isDarwin then ''
    for script in $out/bin/*.py; do
      chmod +x "$script"
      patchShebangs "$script"
      substituteInPlace $script --replace "#!/nix" "#!/usr/bin/env /nix"
    done
    buildPythonPath "$out"
  '' else ''
    for script in $out/bin/*.py; do
      chmod +x "$script"
      patchShebangs "$script"
    done
    buildPythonPath "$out"
  '';
}
