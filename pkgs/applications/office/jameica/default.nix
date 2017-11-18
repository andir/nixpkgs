{ stdenv, fetchFromGitHub, makeWrapper, pkgs }:
let
  _version = [ "2" "6" "6" ];
  _build = "439";
  joinVersion = sep: initial: builtins.foldl' (b: a: if b != "" then "${b}${sep}${a}" else a) initial _version;
  pkg_version = joinVersion "." "";
  src_version = joinVersion "_" "V";
in
stdenv.mkDerivation rec {
  version = "${pkg_version}-${_build}";
  name = "jamaica-${version}";

  nativeBuildInputs = with pkgs; [ jdk gradle ant makeWrapper unzip ];
  buildInputs = with pkgs; [ gtk2 glib xorg.libXtst ];

  src = fetchFromGitHub {
    owner = "willuhn";
    repo = "jameica";
    rev = "${src_version}_BUILD_${_build}";
    sha256 = "0s6fcnib2s254wb1xd11ihp2v5hm7zd19yrpa0x4jxdkaggcvdic";
  };

  buildPhase = with pkgs; ''
    cd build
    ant init
    ant compile
    ant jar
    ant zip
  '';

  installPhase = ''
    mkdir -p $out
    pwd
    ls -la releases/
    unzip releases/2.7.0-nightly-439/jameica-linux64.zip -d $out
    find $out
    wrapProgram $out/jameica/jameica.sh --prefix LD_LIBRARY_PATH : ${stdenv.lib.makeLibraryPath buildInputs }
  '';
}
