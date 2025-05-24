{ config, ... }:
let
  dataDir = "/media/ntfy";
  cfg = config.services.ntfy-sh.settings;
  inherit (config.systemd.services.ntfy-sh) serviceConfig;
in
{
  age.secrets."ntfy.env".file = ../../../secrets/ntfy.env.age;

  services.ntfy-sh.enable = true;
  services.ntfy-sh.settings = {
    auth-file = "${dataDir}/user.db";
    attachment-cache-dir = "${dataDir}/attachments";
    cache-file = "${dataDir}/cache-file.db";

    base-url = "https://ntfy.purr.systems";
    auth-default-access = "deny-all";
    behind-proxy = true;
    enable-login = true;
  };

  systemd.services.ntfy-sh.serviceConfig.EnvironmentFile = config.age.secrets."ntfy.env".path;
  systemd.services.ntfy-sh.serviceConfig.ReadWritePaths = [ dataDir ];

  services.caddy.virtualHosts."ntfy.purr.systems".extraConfig = ''
    reverse_proxy http://${toString cfg.listen-http}
  '';

  systemd.tmpfiles.settings."10-ntfy" = {
    "${dataDir}"."d" = {
      mode = "0770";
      user = serviceConfig.User;
      group = serviceConfig.User;
    };
  };
}
