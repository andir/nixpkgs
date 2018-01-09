import ./make-test.nix ({ pkgs, lib, ... }:
  let
    hosts = {
      node1 = {
        ed25519PublicKey = "WFPS09g/Sxv0mUffBez+d5fQsPjgGTafynmO9BlHuQJ";
        ed25519PrivateKey = ''
          -----BEGIN ED25519 PRIVATE KEY-----
          4S3OXAdIBxoxjQ9uSfnd9eaG9kjfT3o00kPABLX44B2xCz6S8i7cWzu2u2ejTRfB
          aMmnzVqoFlMcc9rzW2L6HYV8IR3D+LF/SbS99F4N73l/Bx+MCaMp9Jfa60HUe4Cl
          -----END ED25519 PRIVATE KEY-----
        '';
        subnets = ["192.168.1.1/24"];
        ip = "192.168.1.1/24";
      };
      node2 ={
        ed25519PublicKey = "ttDk2SN49Ro3/0ioc7DxKZBXqdZlMON7y/vneUINtiC";
        ed25519PrivateKey = ''
          -----BEGIN ED25519 PRIVATE KEY-----
          gN0X/tOrF+niT5MGjt+wtgAJiPYUONy+oWABGfJ+kpGmcsw7+1Z8m8T/rG4B2MgE
          zg3GNxfnJJSomTSpSgrZS12OQaL1g3Hhe/TLiytPErkFcp2lVy40sL//e6Rh00KK
          -----END ED25519 PRIVATE KEY-----
        '';
        subnets = ["192.168.2.2/24"];
        ip = "192.168.1.2/24";
      };
    };
    nodeBase = {
      virtualisation.vlans = [ 1 ];
    };
    splitNet = net: let
      parts = lib.splitString "/" net;
      ip = lib.head parts;
      prefixLength = lib.tail parts;
    in {
      inherit ip prefixLength;
    };
    mkHosts = hosts: lib.mapAttr (n: v: ''
      Name = ${v.name}
      Ed25519PublicKey = ${v.ed25519PublicKey}
      Address = ${(splitNet v.ip).ip}
      ${lib.concatStringsSep "\n" (s: "Subnet = ${s}") v.subnets}
    '') hosts;
    mkNode = name: host: { config, ... }: (lib.mkMerge [
        nodeBase
        ({
          networking.interfaces."tinc-test".ip4 = lib.listToAttrs (map (subnet:
          let
            net = splitNet subnet;
          in
          lib.nameValuePair "${net.ip}" {
              address = net.ip;
              prefixLength = net.prefixLength;
            }
          ) host.subnets);
          services.tinc.networks.test = {
            name = name;
            hosts = mkHosts hosts;
            ed25519PrivateKey = lib.writeText "tinc-key-${name}" hosts."${name}".ed25519PrivateKey;
          };
        })
    ]);
  in
  {
    nodes = lib.mapAttrs (name: v: mkNode name v) hosts;

    testScript = { nodes, ... }: let
        execAll = cmd: lib.concatStringsSep "\n" (map (n: v: cmd n) nodes);
      in ''
      # start all instances
      ${execAll (n: "$${n}->start;")}

      # wait for the network.target on all nodes
      ${execAll (n: "$${n}->waitForUnit(\"network.target\");")}

      # ping each other in the "underlay"
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: v: execAll (n: "$${n}->succeed(\"ping -c 1 ${name} >&2\")")) nodes)}

      # Wait for tinc to come up
      ${execAll (n: "$${n}->waitForUnit(\"tinc.test\");")}

      # Ping all of the nodes in the overlay (tinc)
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: v: execAll (n: "$${n}->succeed(\"ping -c 1 ${(lib.head hosts."${name}".subnets).ip} >&2\")")) nodes)}

    '';
  })
