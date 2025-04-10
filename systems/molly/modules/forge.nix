{ pkgs, config, ... }:
let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
  domain = "git.nyaa.bar";
  ssh_port = 2222;
in
{
  services.forgejo.enable = true;
  services.forgejo.stateDir = "/media/forgejo";
  services.forgejo.package = pkgs.forgejo;
  services.forgejo.lfs.enable = true;

  services.forgejo.settings = {
    DEFAULT.APP_NAME = "nyaa.bar";

    server.DOMAIN = domain;
    server.ROOT_URL = "https://${domain}/";
    server.SSH_DOMAIN = "home.nyaa.bar";
    server.SSH_PORT = 22;
    server.SSH_LISTEN_PORT = ssh_port;

    session.PROVIDER = "db";
    session.COOKIE_SECURE = true;
    session.COOKIE_NAME = "session";

    service.DISABLE_REGISTRATION = true;

    actions.DEFAULT_ACTIONS_URL = "github";

    "ui.meta".AUTHOR = "nyaa.bar";
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

  age.secrets."forgejo/runner".file = ../../../secrets/forgejo/runner.age;

  services.gitea-actions-runner.package = pkgs.forgejo-runner;
  services.gitea-actions-runner.instances.molly = {
    enable = true;
    name = "molly";
    url = "https://${domain}";
    tokenFile = config.age.secrets."forgejo/runner".path;
    labels = [
      "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
      "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
      "ubuntu-20.04:docker://ghcr.io/catthehacker/ubuntu:act-20.04"
    ];
  };
}
