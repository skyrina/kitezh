{ config, ... }:
let
  cfg = config.services.vaultwarden.config;
  serviceConfig = config.systemd.services.vaultwarden.serviceConfig;
in
{
  services.vaultwarden.enable = true;

  services.vaultwarden.config = {
    DOMAIN = "https://vw.purr.systems";
    SIGNUPS_ALLOWED = false;

    ADMIN_TOKEN = "$argon2id$v=19$m=65540,t=3,p=4$ICT5f9Imk7szpoiWaO2AXA2FTcVHYx1wNZE5KLIB6IE$tZt2glpzPffy3MrNPnX5BfwW7qEduuj1wusP+J+DJs0";

    ROCKET_ADDRESS = "::1";
    ROCKET_PORT = 8222;

    DATA_FOLDER = "/media/vaultwarden";
  };

  systemd.services.vaultwarden.serviceConfig.ReadWritePaths = [ cfg.DATA_FOLDER ];

  systemd.tmpfiles.settings."10-vaultwarden" = {
    "${cfg.DATA_FOLDER}" = {
      d = {
        mode = "0700";
        user = serviceConfig.User;
        group = serviceConfig.Group;
      };
    };
  };

  services.caddy.virtualHosts."vw.purr.systems".extraConfig = ''
    reverse_proxy http://[::1]:${toString cfg.ROCKET_PORT}
  '';
}
