{ config, inputs, ... }:
{
  age.secrets."thermo.env".file = ../../../secrets/thermo.env.age;

  users.users.thermo = {
    isSystemUser = true;
    group = "thermo";
  };
  users.groups.thermo = { };

  systemd.services.thermo = {
    after = [
      "bluetooth.service"
      "network-online.target"
      "influxdb2.service"
      "dbus.service"
    ];
    requires = [
      "bluetooth.service"
      "network-online.target"
      "influxdb2.service"
      "dbus.service"
    ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      User = "thermo";
      Group = "thermo";
      EnvironmentFile = config.age.secrets."thermo.env".path;
      Restart = "always";
      RestartSec = 5;
      ExecStart = "${inputs.thermo.packages."x86_64-linux".default}/bin/thermo";

      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = "disconnected";
      PrivateDevices = true;
      PrivateMounts = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectProc = "noaccess";
      LockPersonality = true;
      RestrictSUIDSGID = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      NoNewPrivileges = true;
      MemoryDenyWriteExecute = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      SocketBindDeny = [
        "ipv4:tcp"
        "ipv4:udp"
        "ipv6:tcp"
        "ipv6:udp"
      ];
      CapabilityBoundingSet = [
        "~CAP_SYS_PTRACE"
        "~CAP_SYS_ADMIN"
        "~CAP_SYS_MODULE"
        "~CAP_NET_ADMIN"
        "~CAP_CHOWN"
        "~CAP_FSETID"
        "~CAP_SETFCAP"
        "~CAP_SETUID"
        "~CAP_SETGID"
        "~CAP_SETPCAP"
      ];
      # surely i know what all of these mean!
      SystemCallFilter = [
        "~@aio"
        "~@chown"
        "~@clock"
        "~@cpu-emulation"
        "~@debug"
        "~@ipc"
        "~@keyring"
        "~@memlock"
        "~@module"
        "~@mount"
        "~@obsolete"
        "~@pkey"
        "~@privileged"
        "~@raw-io"
        "~@reboot"
        "~@resources"
        "~@sandbox"
        "~@setuid"
        "~@swap"
        "~@sync"
        "~@timer"
      ];
      UMask = "077";
    };
  };
}
