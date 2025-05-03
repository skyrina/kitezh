{ config, ... }:
{
  age.secrets."pds.env" = {
    file = ../../../secrets/pds.env.age;
    owner = "pds";
    group = "pds";
  };

  services.pds = {
    enable = true;
    settings = {
      PDS_HOSTNAME = "purr.systems";
      PDS_PORT = 3333;

      PDS_SERVICE_NAME = "purr.systems";
      # PDS_LOGO_URL = "";

      PDS_RATE_LIMITS_ENABLED = "true";
      PDS_INVITE_REQUIRED = "true";

      # PDS_DATA_DIRECTORY = "/media/pds";
      # PDS_BLOBSTORE_DISK_LOCATION = "/media/pds/blocks";

      PDS_DID_PLC_URL = "https://plc.directory";
      PDS_BSKY_APP_VIEW_URL = "https://api.bsky.app";
      PDS_BSKY_APP_VIEW_DID = "did:web:api.bsky.app";
      PDS_REPORT_SERVICE_URL = "https://mod.bsky.app";
      PDS_REPORT_SERVICE_DID = "did:plc:ar7c4by46qjdydhdevvrndac";
      PDS_CRAWLERS = "https://bsky.network";
    };

    environmentFiles = [ config.age.secrets."pds.env".path ];

    pdsadmin.enable = true;
  };

  services.caddy.virtualHosts."purr.systems".extraConfig = ''
    import cloudflare
    @xrpc path /xrpc* /.well-known/atproto-did
    @oauth path /@atproto* /oauth* /.well-known/oauth-protected-resource /.well-known/oauth-authorization-server

    reverse_proxy @xrpc http://localhost:${toString config.services.pds.settings.PDS_PORT}
    reverse_proxy @oauth http://localhost:${toString config.services.pds.settings.PDS_PORT}
  '';

  services.caddy.virtualHosts."*.purr.systems".extraConfig = ''
    import cloudflare
    reverse_proxy /.well-known/atproto-did http://localhost:${toString config.services.pds.settings.PDS_PORT}
  '';
}
