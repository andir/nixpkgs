{ config, pkgs, lib, ...}:

with lib;

let
  cfg = config.services.prometheus.birdExporter;
in {
  options = {
    services.prometheus.birdExporter = {
      enable = mkEnableOption "prometheus bird exporter";
      port = mkOption {
        type = types.int;
        default = 9324;
        description = ''
          Port to listen on.
        '';
      };

      extraFlags = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Extra commandline options when launching the bird exporter.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open port in firewall for incoming connections.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = optional cfg.openFirewall cfg.port;
    systemd.services."prometheus-bird-exporter" = {
      description = "Prometheus exporter for bird";
      unitConfig.Documentation = "https://github.com/czerwonk/bird_exporter";
      wantedBy = [ "multi-user.target" ];
      after = [ "bird.service" "bird6.service" ];
      serviceConfig = {
        User = "root"; # required to have access to bird.ctl & bird6.ctl
        Restart = "on-failure";
        PrivateTmp = true;
        WorkingDirectory = /tmp;
        ProtectSystem = "full";
        ReadWritePaths = "/run/bird.ctl /run/bird6.ctl";
        SystemCallArchitectures= "native";
        SystemCallFilter = "~@aio @basic-io @file-system @timer @signal";
        ExecStart = ''
          ${pkgs.prometheus-bird-exporter}/bin/bird_exporter \
            -bird.socket /run/bird.ctl \
            -bird.socket6 /run/bird6.ctl \
            -format.new \
            -web.listen-address ${toString cfg.port} \
            ${concatStringsSep " \\\n  " cfg.extraFlags}
        '';
      };
    };
  };
}
