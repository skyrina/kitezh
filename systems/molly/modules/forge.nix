{
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
  domain = "git.purr.systems";
  ssh_port = 2222;
in
{
  services.forgejo.enable = true;
  services.forgejo.stateDir = "/media/forgejo";
  services.forgejo.package = pkgs.forgejo;
  services.forgejo.lfs.enable = true;

  services.forgejo.settings = {
    DEFAULT.APP_NAME = "purr.systems";

    server.DOMAIN = domain;
    server.ROOT_URL = "https://${domain}/";
    server.SSH_DOMAIN = "home.purr.systems";
    server.SSH_PORT = 22;
    server.SSH_LISTEN_PORT = ssh_port;

    session.PROVIDER = "db";
    session.COOKIE_SECURE = true;
    session.COOKIE_NAME = "session";

    service.DISABLE_REGISTRATION = true;

    indexer.REPO_INDEXER_ENABLED = true;
    actions.DEFAULT_ACTIONS_URL = "github";

    "ui.meta".AUTHOR = "purr.systems";
    "ui.meta".DESCRIPTION = "robot girl's git server";

    other.SHOW_FOOTER_VERSION = false;
    other.SHOW_FOOTER_POWERED_BY = false;
  };

  networking.firewall.allowedTCPPorts = [ ssh_port ];

  services.caddy.virtualHosts."${domain}" = {
    serverAliases = [ "git.nya" ];
    extraConfig = ''
      import cloudflare
      import private
      reverse_proxy http://127.0.0.1:${toString srv.HTTP_PORT}
    '';
  };
}
