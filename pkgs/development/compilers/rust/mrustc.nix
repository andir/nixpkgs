{ stdenv, fetchFromGitHub, fetchurl, llvm, bison, flex }:
let
  gnuTripletForRust = hostPlatform: {
    "i686-linux" = "i686-unknown-linux-gnu";
    "x86_64-linux" = "x86_64-unknown-linux-gnu";
  }.${hostPlatform}; # or throw "Unsupported hostPlatform ${hostPlatform}";

  rustVersion = "1.29.0";

  rust_src = fetchurl {
    url = "https://static.rust-lang.org/dist/rustc-${rustVersion}-src.tar.gz";
    sha256 = "1sb15znckj8pc8q3g7cq03pijnida6cg64yqmgiayxkzskzk9sx4";
  };

in stdenv.mkDerivation rec {
  pname = "mrustc";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "thepowersgang";
    repo = "mrustc";
    rev = "v${version}";
    sha256 = "194ny7vsks5ygiw7d8yxjmp1qwigd71ilchis6xjl6bb2sj97rd2";
  };
  nativeBuildInputs = [ bison flex ];
  buildInputs = [ llvm ];

  enableParallelBuilding = true;

  postPatch = ''
    # support other host platforms
    sed -e 's/^RUSTC_TARGET := x86_64-unknown-linux-gnu/RUSTC_TARGET := ${gnuTripletForRust stdenv.hostPlatform.system}/' -i minicargo.mk

    tar xf ${rust_src}
    cd rustc-${rustVersion}-src
    patch -p0 ../rustc-${rustVersion}-src.patch
    cd ..

    echo '${rustVersion}' > rust-version

    # disable building LLVM
    sed -e 's,^$(LLVM_CONFIG):,xxx:,' \
        -e 's,^LLVM_CONFIG :=,LLVM_CONFIG := llvm-config,' \
        -e '/rustc: / s,$(LLVM_CONFIG),,' \
       -i minicargo.mk

    # increase max build jobs to $NIX_BUILD_CORES
    sed -e 's,-j [13] ,-j $NIX_BUILD_CORES,g' -i run_rustc/Makefile
  '';

  makeFlags = [
    "-f minicargo.mk"
    "LLVM_CONFIG=${llvm}/bin/llvm-config"
  ];

  postBuild = ''
    for target in cargo rustc libstd.rlib libproc_macro.rlib hello_world; do
        make -C run_rustc -j$NIX_BUILD_CORES LLVM_CONFIG=${llvm}/bin/llvm-config output/$target
    done
  '';

  installPhase = ''
    ls -la
    pwd
    rm -rf output/local_tests
    find output -name '*.txt' -delete

    mkdir -p $out{/tools,}/bin
    mkdir -p $out/lib

    find tools
    find bin
    find lib

    install -m 755 bin/mrustc $out/bin
    install -m 755 bin/tools/minicargo $out/bin/minicargo
    cp -rv output $out/lib/mrust
  '';
}
