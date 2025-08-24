{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.vaultwarden.config;
  inherit (config.systemd.services.vaultwarden) serviceConfig;
in
{
  warnings = lib.optional (lib.versionAtLeast pkgs.vaultwarden.version "1.34.2") "Using nixpkgs vaultwarden version ${pkgs.vaultwarden.version}, override may no longer be needed";

  services.vaultwarden = {
    enable = true;
    package =
      if lib.versionOlder pkgs.vaultwarden.version "1.34.2" then
        (pkgs.vaultwarden.overrideAttrs (
          finalAttrs: oldAttrs: rec {
            version = "1.34.2";
            src = pkgs.fetchFromGitHub {
              owner = "dani-garcia";
              repo = "vaultwarden";
              rev = "ce70cd2cf4f1faf84ce32266bcc65ca9482a5514";
              hash = "sha256-MFF9lPOoSOCT+dLiSCHf8dS04KmX+05BbiHyZCSK4IE=";
            };

            cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
              inherit src;
              hash = "sha256-q/kauDfLY+XqOUOawOMf+smw1oZYoDXkMgqjXSbFVUg=";
            };
          }
        ))
      else
        pkgs.vaultwarden;
    config = {
      DOMAIN = "https://vw.purr.systems";
      SIGNUPS_ALLOWED = false;

      ADMIN_TOKEN = "$argon2id$v=19$m=65540,t=3,p=4$ICT5f9Imk7szpoiWaO2AXA2FTcVHYx1wNZE5KLIB6IE$tZt2glpzPffy3MrNPnX5BfwW7qEduuj1wusP+J+DJs0";

      ROCKET_ADDRESS = "::1";
      ROCKET_PORT = 8222;

      DATA_FOLDER = "/media/vaultwarden";
    };
  };

  systemd.services.vaultwarden.serviceConfig.ReadWritePaths = [ cfg.DATA_FOLDER ];

  systemd.tmpfiles.settings."10-vaultwarden" = {
    "${cfg.DATA_FOLDER}"."d" = {
      mode = "0700";
      user = serviceConfig.User;
      group = serviceConfig.Group;
    };
  };

  services.caddy.virtualHosts."vw.purr.systems".extraConfig = ''
    reverse_proxy http://[::1]:${toString cfg.ROCKET_PORT}
  '';
}
