{ stdenv, fetchFromGitHub, makeWrapper, pkgs }:
let
  _version = [ "2" "6" "6" ];
  _build = "439";
  joinVersion = sep: initial: builtins.foldl' (b: a: if b != "" then "${b}${sep}${a}" else a) initial _version;
  pkg_version = joinVersion "." "";
  src_version = joinVersion "_" "V";
  next_version = "2.7.0";
in
stdenv.mkDerivation rec {
  version = "${pkg_version}-build-${_build}";
  name = "jamaica-${version}";

  nativeBuildInputs = with pkgs; [ jdk gradle ant makeWrapper unzip ];
  buildInputs = with pkgs; [ gtk2 glib xorg.libXtst ];

  src = fetchFromGitHub {
    owner = "willuhn";
    repo = "jameica";
    rev = "${src_version}_BUILD_${_build}";
    sha256 = "0s6fcnib2s254wb1xd11ihp2v5hm7zd19yrpa0x4jxdkaggcvdic";
  };

  postPatch = ''
    #sed -i plugin.xml /jameica-${next_version}-nightly/, s,nightly/jameica-${next_version}-nightly.zip,current/

    sed -i plugin.xml -e 's/version="${next_version}-nightly/version="${pkg_version}/'

    # remove the git tag and sign phase from the release process
    sed -i build/build.xml -e '/init,compile,tag,jar,zip,javadoc,src,sign,lib,clean/ s/tag,//'
    sed -i build/build.xml -e '/init,compile,jar,zip,javadoc,src,sign,lib,clean/ s/sign,//'
  '';


  buildPhase = with pkgs; ''
    cd build
    ant all
    cd ..
  '';

  installPhase = ''
    mkdir -p $out/opt
    mkdir $out/bin
    unzip releases/${pkg_version}-${_build}/jameica-linux64.zip -d $out/opt
    wrapProgram $out/opt/jameica/jameica.sh --prefix LD_LIBRARY_PATH : ${stdenv.lib.makeLibraryPath buildInputs} \
                                            --prefix PATH : ${pkgs.jre}/bin/
    cat <<EOF > $out/bin/jameica
    #!/bin/sh
    exec $out/opt/jameica/jameica.sh
    EOF
    chmod +x $out/bin/jameica
  '';
}
