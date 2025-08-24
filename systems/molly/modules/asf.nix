{ config, ... }:
{
  age.secrets."asfIpcPassword" = {
    file = ../../../secrets/asfIpcPassword.age;
    owner = "archisteamfarm";
    group = "archisteamfarm";
  };

  services.archisteamfarm = {
    enable = true;
    settings.Statistics = false;
    ipcSettings.Kestrel.Endpoints.HTTP.Url = "http://127.0.0.1:1242";
    ipcPasswordFile = config.age.secrets."asfIpcPassword".path;
    bots.sky = {
      username = "skycinth";
      settings = {
        FarmingPreferences = 8;
        GamesPlayedWhileIdle = [ ];
        LootableTypes = [ ];
        MatchableTypes = [ ];
        OnlineStatus = 0;
        RemoteCommunication = 0;
        TransferableTypes = [ ];
      };
    };
  };

  services.caddy.virtualHosts."asf.purr.systems".extraConfig = ''
    import cloudflare
    reverse_proxy http://127.0.0.1:1242
  '';
}
