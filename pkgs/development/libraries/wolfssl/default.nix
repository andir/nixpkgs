{ stdenv, fetchFromGitHub, fetchpatch, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "wolfssl-${version}";
  version = "3.12.2";

  src = fetchFromGitHub {
    owner = "wolfSSL";
    repo = "wolfssl";
    rev = "v${version}-stable";
    sha256 = "1a45kd15xb7ni176kr28sxpl7g26v99mb0nikbzrlq3lfv0h95lh";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/wolfSSL/wolfssl/commit/fd455d5a5e9fef24c208e7ac7d3a4bc58834cbf1.diff";
      sha256 = "0xlbk6fkqpjbwpfn1g4vq5aq7pps7lmb4dkqna69in11fmv73002";
    })
  ];

  outputs = [ "out" "dev" "doc" "lib" ];

  nativeBuildInputs = [ autoreconfHook ];

  postInstall = ''
     # fix recursive cycle:
     # wolfssl-config points to dev, dev propagates bin
     moveToOutput bin/wolfssl-config "$dev"
     # moveToOutput also removes "$out" so recreate it
     mkdir -p "$out"
  '';

  meta = with stdenv.lib; {
    description = "A small, fast, portable implementation of TLS/SSL for embedded devices";
    homepage    = "https://www.wolfssl.com/";
    platforms   = platforms.all;
    maintainers = with maintainers; [ mcmtroffaes ];
  };
}
