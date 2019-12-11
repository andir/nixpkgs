{ writeScript }:
crate:
  assert crate ? testCrate;
let
  testBuild = (crate.testCrate.override {
    extraRustcOpts = [ "--test" ];
  }).overrideAttrs (old: {
    outputs = [ "out" ];
    outputDev = [ "out" ];
    doCheck = true;
    checkPhase = ''
      set -ex

      find target/bin target/lib -type f -executable -exec {} \;
      set +xe
    '';

    installPhase = ''
      echo noop > $out
    '';
  });
in ''
  test -e ${testBuild}
''
