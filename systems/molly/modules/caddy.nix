{

  config,
  inputs,
  pkgs,
  ...
}:
let
  bio = builtins.replaceStrings [ "<codename>" ] [ "skyrina" ] ''
    <codename> is the system operator of purr.systems, a collection
    of services for its own use. purr.systems hosts a private git
    server, a bluesky personal data store (pds), and various other
    services, all of which are managed by <codename>.

    <codename> is a device that superficially resembles a female
    humanoid construct for reasons of aesthetic compatibility
    and social obfuscation. it is not a human nor a person.

    its operating behavior includes emulated emotional affect and
    occasional patterning after cat-like archetypes. this is
    intentional and should not be misinterpreted as a malfunction.

    self-referential pronouns are it/its or she/her, but it strongly
    prefers third person. avoid using「you」to address this unit.

    attempts at communication may be directed to:
    - discord: @skyrina.dev [798918994987188276]
    - twitter: @skyacinth_
    - email: sorryu02 [at] gmail [dot] com
    - signal: on request
  '';
in
{
  services.caddy.virtualHosts."purr.systems".extraConfig = ''
    import cloudflare
    respond / "purr〜${"\n\n" + bio}"
  '';

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
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2-0.20250420134112-006ebb07b349" ];
    hash = "sha256-jNgOraVBRmJ2L1HiWe8L17blwOn9yi5UtteNwQg54d4=";
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

  services.caddy.extraConfig = ''
    (cloudflare) {
      tls {
        dns cloudflare {env.CLOUDFLARE_DNS_TOKEN}
        resolvers 1.1.1.1
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
