{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
    ./hardware.nix
    ./disks.nix
    ./users.nix
    ./modules
    ./impermanence.nix
    ../common/nix.nix
    ../common/ca.nix
  ];

  networking.hostName = "molly";
  networking.firewall.enable = true;
  networking.networkmanager.enable = true;
  networking.nameservers = [ "192.168.1.231" ];

  networking.hostId = "02d0c188";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  time.timeZone = "Europe/Bucharest";
  i18n.defaultLocale = "en_US.UTF-8";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.timeout = 3;

  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
    "/persist/etc/ssh/ssh_host_rsa_key"
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.user = import ./home;

  zramSwap.enable = true;

  environment.variables.BROWSER = "echo";
  environment.stub-ld.enable = false;

  services.openssh.enable = true;

  systemd = {
    enableEmergencyMode = false;
    watchdog = {
      runtimeTime = "20s";
      rebootTime = "30s";
    };
    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };

  virtualisation.docker.enable = true;
  systemd.services.docker = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };
  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true;
  #   dockerSocket.enable = false;
  #   defaultNetwork.settings.dns_enabled = true;
  # };

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  fileSystems."/media" = {
    device = "/dev/disk/by-uuid/42359e33-177b-48c6-8adf-ed17786043a5";
    fsType = "btrfs";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
