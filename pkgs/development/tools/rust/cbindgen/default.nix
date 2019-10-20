{ stdenv, fetchFromGitHub, rustPlatform, Security }:

rustPlatform.buildRustPackage rec {
  name = "rust-cbindgen-${version}";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "eqrion";
    repo = "cbindgen";
    rev = "v${version}";
    sha256 = "1g0vrkwkc8wsyiz04qchw07chg0mg451if02sr17s65chwmbrc19";
  };

  cargoSha256 = "06xgy8kzls0m2ypa7kk7g4d9yndrjdx9868x9rd7vrh18km9xysb";

  buildInputs = stdenv.lib.optional stdenv.isDarwin Security;

  # https://github.com/eqrion/cbindgen/issues/338
  RUSTC_BOOTSTRAP = 1;

  meta = with stdenv.lib; {
    description = "A project for generating C bindings from Rust code";
    homepage = https://github.com/eqrion/cbindgen;
    license = licenses.mpl20;
    maintainers = with maintainers; [ jtojnar andir ];
  };
}
