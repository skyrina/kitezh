{
  pkgs,
  ...
}:
let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMKDQK22Wqmzd+3f3teCgiS4Qx/QlmCQcIfAeKg7mtcx user@saturday"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLP1/L7eVgH+UzM54PXF1vYgBStu2ZUehemv3M8RKQp user@pixel"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2y6L1lVgpwrC2+P4esCoftNXFHIrBfi4cbwK5fSN73 user@removeme" # TODO: remove me
  ];
in
{
  users.mutableUsers = false;

  users.users = {
    root.openssh.authorizedKeys.keys = keys;

    user = {
      home = "/home/user";
      createHome = true;
      isNormalUser = true;
      description = "user";
      shell = pkgs.nushell;
      initialHashedPassword = "$y$j9T$iIbcAAjcFCjPuLcQIDiVc0$LzlxYuq8HpLYSF9sYO1OEbV8k88T4CNRrP4g8yb2Yv9";
      openssh.authorizedKeys.keys = keys;
      extraGroups = [
        "wheel"
        "docker"
        "caddy"
        "kubernetes"
      ];
    };
  };
}
