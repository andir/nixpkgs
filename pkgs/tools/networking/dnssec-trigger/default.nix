{ stdenv
, lib
, fetchFromGitHub
, pkgconfig

# runtime dependencies for the dnssec-trigger script
, python3 # script runtime
, procps # pidof
, systemd # systemctl
, e2fsprogs # chattr

# compile time dependencies
, openssl
, ldns
, unbound # for unbound-control (also runtime dep)
, gtk2
}:
stdenv.mkDerivation rec {
  pname = "dnssec-trigger";
  version = "0.17";

  src = fetchFromGitHub {
    owner = "NLnetLabs";
    repo = "dnssec-trigger";
    rev = "dnssec-trigger-${version}";
    sha256 = "0afc7zjyz66vfcp1aski98vsbkknyil4v8pkrsf2xgm4qrj9vsmz";
  };

  patches = [
    ./nixos-runtime-path.patch
  ];

  dnssecTriggerScriptPATH = lib.makeBinPath [
    e2fsprogs
    procps
    systemd
    unbound
    (placeholder "out")
  ];

  postPatch = ''
    substituteInPlace dnssec-trigger-script.in --replace @nixosRuntimePath@ "$dnssecTriggerScriptPATH"
  '';

  nativeBuildInputs = [
    pkgconfig
  ];

  buildInputs = [
    openssl
    ldns
    unbound
    gtk2
    python3 # required so the python scripts are patched with the proper shebang
  ];

  configureFlags = [
    "--with-ssl=${openssl.dev}"
    "--with-hooks=networkmanager"
  ];

  installFlags = [
    "DESTDIR=${placeholder "out"}"
  ];

  meta = with lib; {
    license = licenses.bsd3;
    homepage = "https://nlnetlabs.nl/projects/dnssec-trigger/";
    platforms = platforms.linux;
    maintainers = [ maintaners.andir ];
  };
}
