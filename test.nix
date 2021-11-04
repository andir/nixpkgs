{
  m1 = (import ./default.nix { system = "aarch64-darwin"; }).gopass;
  legacy = (import ./default.nix { system = "x86_64-darwin"; }).gopass;
}
