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

  phases = "installPhase fixupPhase installCheckPhase";

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

  installCheckPhase = ''
    source $stdenv/setup
    set -x
    cd $TMPDIR

    python $out/bin/justOrthologs.py -q ${src}/smallTest/orthologTest/bonobo.fa -s ${src}/smallTest/orthologTest/human.fa -o output -c && head -n3 output; rm -rf output*
    python $out/bin/combineOrthoGroups.py -id ${src}/smallTest/testCombineOrthoGroups/ -o output && head -n3 output; rm -rf output*
    python $out/bin/gff3_parser.py -g ${src}/smallTest/wrapperTest/small_human.gff3 -f ${src}/smallTest/wrapperTest/small_human.fasta.gz -o output.fasta && head -n3 output.fasta; rm -rf output*
    python $out/bin/getNoException.py -i ${src}/smallTest/testNoException/test.fasta -o output.fasta && head -n3 output.fasta; rm -rf output*

    # TODO fix this one
    # python $out/bin/wrapper.py -g1 ${src}/smallTest/wrapperTest/small_pan.gff3 -g2 ${src}/smallTest/wrapperTest/small_human.gff3 -r1 ${src}/smallTest/wrapperTest/small_pan.fasta.gz -r2 ${src}/smallTest/wrapperTest/small_human.fasta.gz -all -o output && head -n3 output; rm -rf output*

    set +x
  '';
}
