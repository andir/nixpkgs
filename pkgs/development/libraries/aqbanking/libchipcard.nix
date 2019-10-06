{ stdenv, fetchurl, pkgconfig, gwenhywfar, pcsclite, zlib }:

let
  inherit ((import ./sources.nix).libchipcard) sha256 releaseId version;
in stdenv.mkDerivation rec {
  pname = "libchipcard";
  inherit version;

  src = fetchurl {
    name = "${pname}-${version}.tar.gz";
    url = "https://www.aquamaniac.de/rdm/attachments/download/${releaseId}/${pname}-${version}.tar.gz";
    inherit sha256;
  };

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ gwenhywfar pcsclite zlib ];

  makeFlags = [ "crypttokenplugindir=$(out)/lib/gwenhywfar/plugins/ct" ];

  configureFlags = [ "--with-gwen-dir=${gwenhywfar}" ];

  meta = with stdenv.lib; {
    description = "Library for access to chipcards";
    homepage = http://www2.aquamaniac.de/sites/download/packages.php?package=02&showall=1;
    license = licenses.lgpl21;
    maintainers = with maintainers; [ aszlig ];
    platforms = platforms.linux;
  };
}
