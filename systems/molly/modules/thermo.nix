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
      "network-online.target"
      "influxdb2.service"
      "dbus.service"
    ];
    requires = [
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
      ExecStart = "${inputs.thermo.packages."x86_64-linux".default}/bin/thermo";
    };
  };
}
