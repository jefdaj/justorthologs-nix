{ stdenv, makeWrapper, python27Packages }:

# This is based on my psiblast-exb package, which in turn is based on the ncbi-blast one
# I'm not sure if this is the proper way to set libPath but it seems to work

# TODO include the newer diamond in the repo until nixpkgs updates it

let
  myPy2Pkgs = python27Packages // rec {
    biopython = python27Packages.callPackage ./nix/pydeps/biopython {};
  };
  myPython = myPy2Pkgs.python.withPackages (ps: with ps; [
    biopython
  ]);

in stdenv.mkDerivation rec {
  name = "justorthologs-${version}";
  version = "7ab9104";
  src = ./.;
  buildInputs = [ myPython ]; # ++ runDepends;
#   runDepends = [
#     ncbi-blast
#     diamond
#     fastme
#     mcl
#     myPython
#     utillinux # for taskset
#   ];
  #phases = "unpackPhase patchPhase installPhase fixupPhase";
  #patches = [
  #   ./remove-results-dates.patch
  # ];
  #unpackPhase = ''
    #source $stdenv/setup
    #cd $TMPDIR
    #tar xvzf $src
  #'';
  # TODO why does the libPath come from PsiBlast?
  # TODO need to add config.json to the same dir... and maybe other stuff at the same time?
  #installPhase = ''
    #mkdir -p $out/bin
    #exe="$out/bin/orthofinder"
    #cp OrthoFinder-${version}_source/orthofinder/orthofinder.py "$exe"
    #cp -r OrthoFinder-${version}_source/orthofinder/scripts $out/bin/
    #cp -r OrthoFinder-${version}_source/orthofinder/tools $out/bin/
    #cp OrthoFinder-${version}_source/orthofinder/config.json $out/bin/
  #'';

  # problem:  https://github.com/NixOS/nixpkgs/issues/11133
  # solution: https://github.com/NixOS/nixpkgs/pull/74942
#   fixupPhase = if stdenv.isDarwin then ''
#     for script in $out/bin/*/*.py; do
#       [[ $(basename $script) == '__init__.py' ]] && continue
#       chmod +x "$script"
#       patchShebangs "$script"
#       substituteInPlace $script --replace "#!/nix" "#!/usr/bin/env /nix"
#     done
#     patchShebangs "$exe"
#     substituteInPlace "$exe" --replace "#!/nix" "#!/usr/bin/env /nix"
#     wrapProgram "$exe" --prefix PATH : "${makeBinPath runDepends}"
#     buildPythonPath "$out"
#   '' else ''
#     for script in $out/bin/*/*.py; do
#       [[ $(basename $script) == '__init__.py' ]] && continue
#       chmod +x "$script"
#       patchShebangs "$script"
#     done
#     patchShebangs "$exe"
#     wrapProgram "$exe" --prefix PATH : "${makeBinPath runDepends}"
#     buildPythonPath "$out"
#    '';
}
