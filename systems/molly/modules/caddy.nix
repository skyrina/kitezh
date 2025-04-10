{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age.secrets."caddy/.env".file = ../../../secrets/caddy/.env.age;
  age.secrets."caddy/nyaca.key" = {
    file = ../../../secrets/caddy/nyaca.key.age;
    owner = config.services.caddy.user;
    group = config.services.caddy.group;
  };

  services.caddy.enable = true;
  services.caddy.package = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.0.0-20250228175314-1fb64108d4de" ];
    hash = "sha256-YYpsf8HMONR1teMiSymo2y+HrKoxuJMKIea5/NEykGc=";
  };
  services.caddy.environmentFile = config.age.secrets."caddy/.env".path;

  services.caddy.globalConfig = ''
    skip_install_trust

    pki {
      ca nya {
        name "nyaca"
        root {
          cert ${../../common/nya-ca.pem}
          key ${config.age.secrets."caddy/nyaca.key".path}
        }
      }
    }
  '';
  # i can't seem to import this in other files :<
  services.caddy.extraConfig = ''
    (cloudflare) {
      tls {
        dns cloudflare {env.CLOUDFLARE_DNS_TOKEN}
      }
    }

    (private) {
      tls {
        issuer internal {
          ca nya
          sign_with_root
        }
      }
    }
  '';

  services.caddy.virtualHosts."https://nya".extraConfig = ''
    import private
    respond "にゃ～ん！"
  '';

  # fixme
  services.caddy.virtualHosts."*.nya.:80".extraConfig = ''
    import private
    redir https://{labels.2}.nya{uri}
  '';

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
