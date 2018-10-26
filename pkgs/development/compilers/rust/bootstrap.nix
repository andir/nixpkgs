{ stdenv, fetchurl, callPackage }:

let
  # Note: the version MUST be one version prior to the version we're
  # building
  version = "1.29.1";

  # fetch hashes by running `print-hashes.sh 1.29.1`
  hashes = {
    i686-unknown-linux-gnu = "05e2880beca45e7319074d2268fd79a70c7aade2fb14dbcbf39585b5560f2048";
    x86_64-unknown-linux-gnu = "b36998aea6d58525f25d89f1813b6bfd4cad6ff467e27bd11e761a20dde43745";
    armv7-unknown-linux-gnueabihf = "2cae2ecc366914707d6b753a96505c727df69df8bcbc1f8d14fbd66fca005239";
    aarch64-unknown-linux-gnu = "2685224f67b2ef951e0e8b48829f786cbfed95e19448ba292ac33af719843dbe";
    i686-apple-darwin = "51855f33631a9bd5cd5e89e6560e01285db7c83b8845374241cac0ccbeb963c6";
    x86_64-apple-darwin = "07b07fbd6fab2390e19550beb8008745a8626cc5e97b72dc659061c1c3b3d008";
  };

  platform =
    if stdenv.hostPlatform.system == "i686-linux"
    then "i686-unknown-linux-gnu"
    else if stdenv.hostPlatform.system == "x86_64-linux"
    then "x86_64-unknown-linux-gnu"
    else if stdenv.hostPlatform.system == "armv7l-linux"
    then "armv7-unknown-linux-gnueabihf"
    else if stdenv.hostPlatform.system == "aarch64-linux"
    then "aarch64-unknown-linux-gnu"
    else if stdenv.hostPlatform.system == "i686-darwin"
    then "i686-apple-darwin"
    else if stdenv.hostPlatform.system == "x86_64-darwin"
    then "x86_64-apple-darwin"
    else throw "missing bootstrap url for platform ${stdenv.hostPlatform.system}";

  src = fetchurl {
     url = "https://static.rust-lang.org/dist/rust-${version}-${platform}.tar.gz";
     sha256 = hashes."${platform}";
  };

in callPackage ./binaryBuild.nix
  { inherit version src platform;
    buildRustPackage = null;
    versionType = "bootstrap";
  }
