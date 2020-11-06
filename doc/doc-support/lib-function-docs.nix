# Generates the documentation for library functons via nixdoc. To add
# another library function file to this list, the include list in the
# file `doc/functions/library.xml` must also be updated.

{ pkgs ? import ./.. {}
, locationsXml
, src ? ./../../lib
, targets ? {
    strings = "String manipulation functions";
    trivial = "Miscellaneous functions";
    lists = "Llist manipulation functions";
    debug = "Debugging functions";
    options = "NixOS / nixpkgs option handling";
  }
}:

with pkgs; stdenv.mkDerivation {
  name = "nixpkgs-lib-docs";
  inherit src;

  buildInputs = [ nixdoc ];
  installPhase = ''
    function docgen {
      nixdoc -c "$1" -d "$2" -f "./$1.nix"  > "$out/$1.xml"
    }

    mkdir -p $out
    ln -s ${locationsXml} $out/locations.xml

    ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: desc: "docgen '${name}' '${desc}'") targets
    )}
  '';
}
