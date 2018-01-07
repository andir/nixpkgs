{ stdenv, fetchurl, dpkg, arch ? null }:
assert arch != null;
let
  major = "8";
  version = "8u151-b12-1-deb9u1";
  debian_version = "8u151-b12-1~deb9u1";
  package = {
    "x86_64-linux" = {
      inherit version debian_version;
      arch = "amd64";
      jdk_sha256 = "1rwhfkap2mlcb49rkdinr38nv2wjqgf5v2c85h5558kgpa9fs40r";
      jre_sha256 = "0lhpi0mirkfz3s9hiqx12nha65smnrznn0a98zfbjvzvhgva8j5c";
    };
    "aarch64-linux" = {
      inherit version debian_version;
      arch = "arm64";
      jdk_sha256 = "1b3cz8mi71xqaxxcn7cb5pl5343sfyc1nqbv5nqdxc23qdlyl8w3";
      jre_sha256 = "0anqmjgc6xgdq7a7b5l7vwh12wkp124fc3k8dz7lg43njnw5igbv";
    };
  }."${arch}";
  self = stdenv.mkDerivation rec {
    name = "openjdk-${major}-${arch}-${package.version}-boot-jre";
    nativeBuildInputs = [ dpkg ];
    srcs = [
      (fetchurl {
        name = "openjdk-${arch}-${package.version}-debian-jre.deb";
        url = "https://deb.debian.org/debian/pool/main/o/openjdk-${major}/openjdk-${major}-jre-headless_${package.debian_version}_${package.arch}.deb";
        sha256 = package.jre_sha256;
      })
      (fetchurl {
        name = "openjdk-${arch}-${package.version}-debian-jdk.deb";
        url = "https://deb.debian.org/debian/pool/main/o/openjdk-${major}/openjdk-${major}-jdk-headless_${package.debian_version}_${package.arch}.deb";
        sha256 = package.jdk_sha256;
      })
    ];

    unpackPhase = stdenv.lib.concatStringsSep "\n" (map (s: "dpkg-deb -x ${s} ./") srcs);
    dontBuild = true;
    installPhase = ''
      find .
      mkdir -p $out
      cp -avr usr/* $out/.
      ln -sv $out/lib/jvm/java-${major}-openjdk-${package.arch}/ $out/lib/openjdk
      ln -sv $out/lib/openjdk/include $out/include
    '';
    postFixup = ''
      # find broken symlinks and remove them
      find $out -type l -exec test ! -e {} \; -print | xargs rm -v

    '';
    passthru = {
        home = "${self}/lib/openjdk/";
    };
  };
in self
