{ config, lib, ... }:
let
  cfg = config.services.grafana;
  set = cfg.settings;

  # https://github.com/NixOS/nixpkgs/blob/bbd42dd89b7a547e4551455589c8b43f74dcdeef/nixos/modules/services/databases/influxdb2.nix#L75-L84
  influxHost = "http://${
    lib.escapeShellArg (
      if
        !lib.hasAttr "http-bind-address" cfg.settings
        || lib.hasInfix "0.0.0.0" cfg.settings.http-bind-address
      then
        "localhost:8086"
      else
        cfg.settings.http-bind-address
    )
  }";
in
{
  services.grafana.enable = true;
  services.grafana.dataDir = "/media/grafana";
  services.grafana.settings = {
    server = {
      http_addr = "127.0.0.1";
      http_port = 8720;
      enforce_domain = true;
      enable_gzip = true;
      domain = "grafana.purr.systems";
    };

    security.cookie_secure = true;

    analytics.feedback_links_enabled = false;
    analytics.reporting_enabled = false;
  };

  services.caddy.virtualHosts."${set.server.domain}" = {
    serverAliases = [ "grafana.nya" ];
    extraConfig = ''
      import cloudflare
      import private
      reverse_proxy http://127.0.0.1:${toString set.server.http_port}
    '';
  };

  services.influxdb2.enable = true;
  systemd.services.influxdb2.serviceConfig.BindPaths = [ "/media/influxdb2:/var/lib/influxdb2" ];

  services.caddy.virtualHosts."influxdb.purr.systems" = {
    serverAliases = [ "influxdb.nya" ];
    extraConfig = ''
      import cloudflare
      import private
      reverse_proxy ${influxHost}
    '';
  };
}
