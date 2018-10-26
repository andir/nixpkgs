import ../make-test.nix ({ pkgs, ...} :

let
   trivialJob = pkgs.writeTextDir "trivial.nix" ''
     { trivial = builtins.derivation {
         name = "trivial";
         system = "x86_64-linux";
         builder = "/bin/sh";
         args = ["-c" "sleep 600; echo success > $out; exit 0"];
         meta = {
           timeout = 10;
         };
       };
     }
   '';

    createTrivialProject = pkgs.stdenv.mkDerivation {
      name = "create-trivial-project";
      unpackPhase = ":";
      buildInputs = [ pkgs.makeWrapper ];
      installPhase = "install -m755 -D ${./create-trivial-project.sh} $out/bin/create-trivial-project.sh";
      postFixup = ''
        wrapProgram "$out/bin/create-trivial-project.sh" --prefix PATH ":" ${pkgs.stdenv.lib.makeBinPath [ pkgs.curl ]} --set EXPR_PATH ${trivialJob}
      '';
    };

in {
  name = "hydra-init-localdb";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ pstn lewo ma27 ];
  };

  nodes = {
    builder = { config, pkgs, ...}: {
      services.openssh.enable = true;
#      virtualisation.writeableStore = true;
      nix.useSandbox = true;
    };

    hydra = { pkgs, ... }: {
      virtualisation.memorySize = 1024;
      time.timeZone = "UTC";

      environment.systemPackages = [ createTrivialProject pkgs.jq ];
      services.hydra = {
        enable = true;

        #Hydra needs those settings to start up, so we add something not harmfull.
        hydraURL = "example.com";
        notificationSender = "example@example.com";
      };
      nix = {
        buildMachines = [{
          hostName = "builder1";
          sshUser = "root";
          sshKey = "/root/.ssh/id_ed25519";
          systems = [ "x86_64-linux" ];
        }];

        binaryCaches = [];
      };
    };
  };

  testScript =
    ''
      startAll;

      # let the system boot up
      $hydra->waitForUnit("multi-user.target");
      $builder->waitForUnit("multi-user.target");

      # Create an SSH key on the client.
      my $key = `${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f key -N ""`;
      $hydra->succeed("mkdir -p -m 700 /root/.ssh");
      $hydra->copyFileFromHost("key", "/root/.ssh/id_ed25519");
      $hydra->succeed("chmod 600 /root/.ssh/id_ed25519");
      $hydra->waitForUnit("network.target");

      $builder->succeed("mkdir -p -m 700 /root/.ssh");
      $builder->copyFileFromHost("key.pub", "/root/.ssh/authorized_keys");
      $builder->waitForUnit("sshd");
      $hydra->succeed("ssh -o StrictHostKeyChecking=no " . $builder->name() . " 'echo hello world'");

      # test whether the database is running
      $hydra->succeed("systemctl status postgresql.service");
      # test whether the actual hydra daemons are running
      $hydra->succeed("systemctl status hydra-queue-runner.service");
      $hydra->succeed("systemctl status hydra-init.service");
      $hydra->succeed("systemctl status hydra-evaluator.service");
      $hydra->succeed("systemctl status hydra-send-stats.service");

      $hydra->succeed("hydra-create-user admin --role admin --password admin");

      # create a project with a trivial job
      $hydra->waitForOpenPort(3000);

      # make sure the build as been successfully built
      $hydra->succeed("create-trivial-project.sh");

      $hydra->waitUntilSucceeds('curl -L -s http://localhost:3000/build/1 -H "Accept: application/json" |  jq .buildstatus | xargs test 0 -eq');
    '';
})
