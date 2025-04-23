let
  saturday = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMKDQK22Wqmzd+3f3teCgiS4Qx/QlmCQcIfAeKg7mtcx";
  molly = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICUTtjaYuzdPSDTbxNWNUX3ea/zWi2f4kmlYspXnkpdD";
  all = [
    saturday
    molly
  ];
in
{
  "caddy/.env.age".publicKeys = all;
  "caddy/nyaca.key.age".publicKeys = all;

  "wireguard/molly.age".publicKeys = all;

  "pds.env.age".publicKeys = all;

  "thermo.env.age".publicKeys = all;
}
