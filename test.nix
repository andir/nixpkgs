let
  overlays = [
    (self: super: {
      openwrt_src = super.fetchFromGitHub {
        owner = "openwrt";
        repo = "openwrt";
        rev = "b974293efa24b8e1bf859b1ed253ca0042ab273e";
        sha256 = "1a8y43pndnid0rrz8n2fl6xjr14bvzcwlh8lm3nhvmhk4v1fhvsr";
      };

      unifi_kernel_files = super.runCommand "unifi_kernel_files" {
        inherit (self) openwrt_src;
      } ''
        mkdir $out
        cp -rv $openwrt_src/target/linux/generic/files/* $out
        chmod -R +rw $out
        cp -rv $openwrt_src/target/linux/ath79/files/* $out
      '';

      unifi_kernel_src = super.runCommand "unifi_kernel_src" {
        inherit (self.linux_latest) src;
        inherit (self) unifi_kernel_files;
      } ''
        mkdir $out
        cd $(mktemp -d)
        tar xf $src
        cd linux-*
        cp -rv $unifi_kernel_files/* .
        cp -rv $PWD/* $out
      '';

      unifi_kernel_patches = super.runCommand "megapatch.patch" {
        inherit (self) openwrt_src;
      } ''
        touch $out
        for dir in backport-5.10 pending-5.10 hack-5.10; do
          test -d $openwrt_src/target/linux/generic/$dir/ && cat $openwrt_src/target/linux/generic/$dir/*.patch >> $out
        done
        cat $openwrt_src/target/linux/ath79/patches-5.10/*.patch >> $out
      '';

      my-kernel = super.linux_5_10.override {
        argsOverride.src = self.unifi_kernel_src;
        kernelPatches = with self.kernelPatches; [
          bridge_stp_helper
          request_key_helper
          export-rt-sched-migrate
          ({
            name = "openwrt-patches";
            patch = self.unifi_kernel_patches;
          })
        ];
      };

    })
  ];
  pkgs = (import ./default.nix { inherit overlays; }).pkgsCross.unifi-appro;
in
  {
    kernel = pkgs.my-kernel;
    inherit pkgs;
  }
