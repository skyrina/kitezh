let
  dev = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2y6L1lVgpwrC2+P4esCoftNXFHIrBfi4cbwK5fSN73";
  molly = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICUTtjaYuzdPSDTbxNWNUX3ea/zWi2f4kmlYspXnkpdD";
  all = [
    dev
    molly
  ];
in
{
  "wireguard/molly.age".publicKeys = all;

  "caddy/.env.age".publicKeys = all;
  "caddy/nyaca.key.age".publicKeys = all;

  "forgejo/runner.age".publicKeys = all;
}
