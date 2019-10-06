{ stdenv, fetchurl, gmp, gwenhywfar, libtool, libxml2, libxslt
, pkgconfig, gettext, xmlsec, zlib
}:

let
  inherit ((import ./sources.nix).aqbanking) sha256 releaseId version;
in stdenv.mkDerivation rec {
  pname = "aqbanking";
  inherit version;

  src = fetchurl {
    name = "${pname}-${version}.tar.gz";
    url = "https://www.aquamaniac.de/rdm/attachments/download/${releaseId}/${pname}-${version}.tar.gz";
    inherit sha256;
  };

  postPatch = ''
    sed -i -e '/^aqbanking_plugindir=/ {
      c aqbanking_plugindir="\''${libdir}/gwenhywfar/plugins"
    }' configure
  '';

  buildInputs = [ gmp gwenhywfar libtool libxml2 libxslt xmlsec zlib ];

  nativeBuildInputs = [ pkgconfig gettext ];

  configureFlags = [ "--with-gwen-dir=${gwenhywfar}" ];

  meta = with stdenv.lib; {
    description = "An interface to banking tasks, file formats and country information";
    homepage = https://www.aquamaniac.de/;
    hydraPlatforms = [];
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ goibhniu ];
    platforms = platforms.linux;
  };
}
