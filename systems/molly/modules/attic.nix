{ config, lib, ... }:
let
  port = 4200;
in
{
  age.secrets."attic.env".file = ../../../secrets/attic.env.age;

  services.atticd.enable = true;
  services.atticd.environmentFile = config.age.secrets."attic.env".path;

  services.atticd.settings = {
    listen = "127.0.0.1:${toString port}";

    database.url = "sqlite:///media/attic/server.db?mode=rwc";

    storage.type = "local";
    storage.path = "/media/attic/storage";
  };

  systemd.services.atticd.serviceConfig.DynamicUser = lib.mkForce false;
  systemd.services.atticd.serviceConfig.User = "atticd";
  systemd.services.atticd.serviceConfig.Group = "atticd";
  systemd.services.atticd.serviceConfig.ReadWritePaths = [ "/media/attic" ];

  users.users.atticd.isSystemUser = true;
  users.users.atticd.group = "atticd";
  users.groups.atticd = { };

  services.caddy.virtualHosts."attic.purr.systems".extraConfig = ''
    import cloudflare
    reverse_proxy http://127.0.0.1:${toString port}
  '';
}
