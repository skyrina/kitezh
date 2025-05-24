{ config, ... }:
let
  cfg = config.services.minio;
in
{
  age.secrets."minio.env".file = ../../../secrets/minio.env.age;

  services.minio.enable = true;
  services.minio.rootCredentialsFile = config.age.secrets."minio.env".path;
  services.minio.dataDir = [ "/media/minio/data" ];
  services.minio.configDir = "/media/minio/config";

  services.caddy.virtualHosts."s3.purr.systems".extraConfig = ''
    reverse_proxy http://127.0.0.1${toString cfg.listenAddress}
  '';

  services.caddy.virtualHosts."minio.purr.systems".extraConfig = ''
    reverse_proxy http://127.0.0.1${toString cfg.consoleAddress}
  '';
}
