{ ... }:
{
  services.caddy.virtualHosts."invidious.purr.systems".extraConfig = ''
    reverse_proxy http://127.0.0.1:19120
  '';
}
