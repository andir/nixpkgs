# NIX_PATH=foo=$(pwd):$NIX_PATH nix-build ./test.nix -A fail --option restrict-eval true
# vs
# NIX_PATH=foo=$(pwd):$NIX_PATH nix-build ./test.nix -A success --option restrict-eval true
with import ./default.nix {};
let
  src = ./.;
  t = f: writeText "test" (builtins.readFile f);
in
{
  fail = t "${src}/test.nix";
  success = t (src + "/test.nix");
}
