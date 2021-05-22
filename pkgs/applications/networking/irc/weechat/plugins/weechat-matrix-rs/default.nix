{ stdenv
, lib
, linuxHeaders
, fetchFromGitHub
, rustPlatform
, openssl
, pkg-config
, cmake
, llvmPackages
, weechat-unwrapped
}:
rustPlatform.buildRustPackage rec {
  pname = "weechat-matrix-rs";
  version = "git";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = pname;
    rev = "a846e76b7abf9b70fbcbf955255f99fde185b9cb";
    sha256 = "1gx5vxc8391i8cr6d8r6gwywypl0zn3d1xjydg6y6228qcxl3vmm";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    openssl
    weechat-unwrapped
    llvmPackages.libclang
  ];

  cargoSha256 = "1wfb0937vyy3h43c20lpgrn9anlqqp32vb6a3wxggyx1cqc0z1px";

  WEECHAT_PLUGIN_FILE = "${weechat-unwrapped.dev}/include/weechat/weechat-plugin.h";
  preConfigure = ''
    export BINDGEN_EXTRA_CLANG_ARGS="$(< ${stdenv.cc}/nix-support/libc-crt1-cflags) \
      $(< ${stdenv.cc}/nix-support/libc-cflags) \
      $(< ${stdenv.cc}/nix-support/cc-cflags) \
      $(< ${stdenv.cc}/nix-support/libcxx-cxxflags) \
      ${lib.optionalString stdenv.cc.isClang "-idirafter ${stdenv.cc.cc}/lib/clang/${lib.getVersion stdenv.cc.cc}/include"} \
      ${lib.optionalString stdenv.cc.isGNU "-isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc} -isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc}/${stdenv.hostPlatform.config} -idirafter ${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${lib.getVersion stdenv.cc.cc}/include"}
    "
  '';
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
}
