{ lib }:
let
  mkHardeningLevel = options: lib.mapAttrs (_: lib.mkDefault) options;
in
{
  v1 = unitConfig: mkHardeningLevel {
    PrivateNetwork = true;
    DynamicUser = true;
    DevicePolicy = "closed";
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
    PrivateTmp = true;
    PrivateUsers = true;
    ProtectClock = true;
    ProtectHome = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProcSubset = "pid";
    ProtectSystem = "strict";
    ProtectHostname = true;
    RestrictSUIDSGID = true;
    RestrictNamespaces = "~" + (lib.concatStringsSep " " [
      "cgroup" "ipc" "net" "mnt" "pid" "user" "uts"
    ]);
    CapabilityBoundingSet = [
      "~CAP_AUDIT_CONTROL"
      "~CAP_AUDIT_READ"
      "~CAP_AUDIT_WRITE"
      "~CAP_KILL"
      "~CAP_MKNOD"
      "~CAP_NET_BIND_SERVICE"
      "~CAP_NET_BROADCAST"
      "~CAP_NET_ADMIN"
      "~CAP_NET_RAW"
      # "~CAP_SYSLOG" # fairly frequently used
      "~CAP_SYS_RAWIO"
      "~CAP_SYS_MODULE"
      "~CAP_SYS_PTRACE"
      "~CAP_SYS_TIME"
      "~CAP_SYS_NICE"
      "~CAP_SYS_RESOURCE"
      "~CAP_CHOWN"
      "~CAP_FSETID"
      "~CAP_SETUID"
      "~CAP_SETGID"
      "~CAP_SETPCAP"
      "~CAP_SETFCAP"
      "~CAP_DAC_OVERRIDE"
      "~CAP_DAC_READ_SEARCH"
      "~CAP_FOWNER"
      "~CAP_IPC_OWNER"
      "~CAP_IPC_LOCK"
      "~CAP_KILL" # FIXME: does this affect ExecReload and -HUP?
      "~CAP_SYS_BOOT"
      "~CAP_SYS_ADMIN"
      "~CAP_MAC_ADMIN"
      "~CAP_MAC_OVERRIDE"
      "~CAP_SYS_CHROOT"
      "~CAP_BLOCK_SUSPEND"
      "~CAP_WAKE_ALARM"
      "~CAP_LEASE"
      "~CAP_SYS_PACCT"
    ];
    SystemCallFilter = [
      "~@clock"
      "~@debug"
      "~@module"
      "~@mount"
      "~@raw-io"
      "~@reboot"
      "~@swap"
      "~@privileged"
      "~@resources"
      "~@cpu-emulation"
      "~@obsolete"
    ];
    RestrictAddressFamilies = [
      "~AF_PACKET"
    ];
    ProtectControlGroups = true;
    UMask = "0077";
    SystemCallArchitectures = "native";
    DeviceAllow = "";
  };
}
