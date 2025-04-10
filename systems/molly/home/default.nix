{
  # nixosConfig,
  ...
}:
{
  imports = [
    ../../common/home/nushell
  ];

  home = {
    username = "user";
    homeDirectory = "/home/user";
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      nix_shell.format = "in [nix shell]($style) ";
    };
  };

  # nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
