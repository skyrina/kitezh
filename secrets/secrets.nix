let
  saturday = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHFhEQe80MsvjHEQT/0d63q5T1arAWqjofkVtife/ri";
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

  "minio.env.age".publicKeys = all;
  "ntfy.env.age".publicKeys = all;
  "pds.env.age".publicKeys = all;
  "thermo.env.age".publicKeys = all;

  "transmission.json.age".publicKeys = all;
}
