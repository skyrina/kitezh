{ config, ... }:
{
  services.immich.enable = true;
  services.immich.port = 2283;
  services.immich.mediaLocation = "/media/immich";

  services.immich.accelerationDevices = [ "/dev/dri/renderD128" ];
  users.users.immich.extraGroups = [
    "video"
    "render"
  ];

  services.caddy.virtualHosts."immich.purr.systems".extraConfig = ''
    reverse_proxy http://[::1]:${toString config.services.immich.port}
  '';
}
