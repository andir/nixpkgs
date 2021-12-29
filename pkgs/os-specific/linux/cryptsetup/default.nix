{ lib, stdenv, fetchurl, lvm2, json_c
, openssl, libuuid, pkg-config, popt, systemd, autoreconfHook }:

stdenv.mkDerivation rec {
  pname = "cryptsetup";
  version = "2.4.1";

  outputs = [ "out" "dev" "man" ];

  src = fetchurl {
    url = "mirror://kernel/linux/utils/cryptsetup/v2.4/${pname}-${version}.tar.xz";
    sha256 = "sha256-o1anJ6g6RkreVm6VI5Yioi2+Tg9IKxmP2wSrDTpanF8=";
  };

  # Disable 4 test cases that fail in a sandbox
  patches = [
    ./disable-failing-tests.patch
    ./0001-NixOS-remove-the-plugin-path-installation.patch
    ./0002-NIXOS-Support-defining-external-token-library-locati.patch
  ];

  postPatch = ''
    patchShebangs tests

    # O_DIRECT is filesystem dependent and fails in a sandbox (on tmpfs)
    # and on several filesystem types (btrfs, zfs) without sandboxing.
    # Remove it, see discussion in #46151
    substituteInPlace tests/unit-utils-io.c --replace "| O_DIRECT" ""
  '';

  NIX_LDFLAGS = "-lgcc_s";

  configureFlags = [
    "--enable-cryptsetup-reencrypt"
    "--with-crypto_backend=openssl"
    "--disable-ssh-token"
    # enable cryptsetup to unlock via the systemd FIDO & TPM plugins
    "--with-luks2-external-tokens-path=/run/current-system/systemd/lib/cryptsetup"
  ];

  nativeBuildInputs = [ pkg-config autoreconfHook ];
  buildInputs = [ lvm2 json_c openssl libuuid popt ];

  doCheck = true;

  meta = {
    homepage = "https://gitlab.com/cryptsetup/cryptsetup/";
    description = "LUKS for dm-crypt";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ ];
    platforms = with lib.platforms; linux;
  };
}
