import ./make-test-python.nix ({ pkgs, ... }: {
  name = "systemd-hardening";

  machine = { lib, ... }: {
    systemd.services.hardening-v1 = {
      script = "exit 0";
      defaultHardening = "v1";
      serviceConfig = {
        Type = "oneshot";
      };
    };
  };

  testScript = ''
    machine.succeed("systemctl start hardening-v1.service")
    result = machine.succeed("systemd-analyze security hardening-v1.service")
    print(result)
    assert 'Overall exposure level for hardening-v1.service: 1.0 OK :-)' in result
  '';
})
