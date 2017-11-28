{ stdenv, fetchFromGitHub, pcsclite }:
stdenv.mkDerivation rec {
  version = "2016-08-14";
  name = "pcsc-ctapi-wrapper-${version}";


  buildInputs = [ pcsclite ];

  src = fetchFromGitHub {
    owner = "sixtyfive";
    repo = "pcsc-ctapi-wrapper";
    rev = "4be687dc5867c021df85ceb8a12232c760448c97";
    sha256 = "185s1vv8jidnglc3fqha0z0zism03p1z51wj98ngy2lpk74znvfs";
  };

  patchPhase = ''
    sed -i Makefile -e 's,/usr/include/PCSC,${pcsclite}/include/PCSC,'
    sed -i Makefile -e 's,/usr/local/lib,$out/lib,'
  '';


  installPhase = ''
    mkdir -p $out/lib
    make DESTDIR=$out/lib install
  '';

}
