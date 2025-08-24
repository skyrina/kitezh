{ config, ... }:
let
  rootDomain = "purr.systems";
  domain = "vpn.${rootDomain}";
in
{
  age.secrets."tailscale/headscaleOidcSecret" = {
    file = ../../../secrets/tailscale/headscaleOidcSecret.age;
    mode = "600";
    owner = config.services.headscale.user;
    group = config.services.headscale.group;
  };

  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 1111;
    settings = {
      server_url = "https://${domain}";
      dns = {
        base_domain = "lan.${rootDomain}";
        nameservers.global = [
          "1.1.1.1"
          "1.0.0.1"
          "9.9.9.9"
        ];
      };
      oidc = {
        issuer = config.services.pocket-id.settings.APP_URL;
        client_id = "f15cddbb-d9f8-4cc4-a418-63e0e95a0187";
        client_secret_path = config.age.secrets."tailscale/headscaleOidcSecret".path;
        pkce.enabled = true;
        only_start_if_oidc_is_available = true;
      };
    };
  };

  services.caddy.virtualHosts.${domain}.extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString config.services.headscale.port}
  '';
}
