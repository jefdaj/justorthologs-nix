{ stdenv
, fetchurl
, makeWrapper
, python
}:

stdenv.mkDerivation rec {
  name = "justorthologs-${version}";
  version = "7ab9104";
  src = ./.;

  # this python needs to have biopython 1.76 available
  buildInputs = [ makeWrapper python ];

  phases = "installPhase fixupPhase checkPhase";

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
      wrapProgram "$script" --prefix PATH : "${python}/bin"
    done
  '' else ''
    for script in $out/bin/*.py; do
      chmod +x "$script"
      patchShebangs "$script"
      wrapProgram "$script" --prefix PATH : "${python}/bin"
    done
  '';

  doCheck = true;
  checkPhase = ''
    source $stdenv/setup
    set -e
    set -x
    cd $TMPDIR

    $out/bin/justOrthologs.py -q ${src}/smallTest/orthologTest/bonobo.fa -s ${src}/smallTest/orthologTest/human.fa -o output -c && head -n3 output; rm -rf output*
    $out/bin/combineOrthoGroups.py -id ${src}/smallTest/testCombineOrthoGroups/ -o output && head -n3 output; rm -rf output*
    $out/bin/gff3_parser.py -g ${src}/smallTest/wrapperTest/small_human.gff3 -f ${src}/smallTest/wrapperTest/small_human.fasta.gz -o output.fasta && head -n3 output.fasta; rm -rf output*
    $out/bin/getNoException.py -i ${src}/smallTest/testNoException/test.fasta -o output.fasta && head -n3 output.fasta; rm -rf output*

    # TODO figure out this one
    # $out/bin/wrapper.py -g1 ${src}/smallTest/wrapperTest/small_pan.gff3 -g2 ${src}/smallTest/wrapperTest/small_human.gff3 -r1 ${src}/smallTest/wrapperTest/small_pan.fasta.gz -r2 ${src}/smallTest/wrapperTest/small_human.fasta.gz -all -o output && head -n3 output; rm -rf output*

    set +x
  '';
}
