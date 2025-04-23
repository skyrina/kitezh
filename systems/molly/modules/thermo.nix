{ config, inputs, ... }:
{
  age.secrets."thermo.env".file = ../../../secrets/thermo.env.age;

  systemd.services.thermo = {
    requires = [
      "influxdb2.service"
      "network-online.target"
    ];
    after = [
      "network-online.target"
      "influxdb2.service"
    ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      DynamicUser = true;
      EnvironmentFile = config.age.secrets."thermo.env".path;
      Restart = "always";
      ExecStart = "${inputs.thermo.packages."x86_64-linux".default}/bin/thermo";
    };
  };
}
