{
  config,
  inputs,
  lib,
  ...
}:
let
  l = lib // builtins;
  port = 51820;
  peers = {
    robot = [
      {
        name = "saturday";
        publicKey = "EP8LcZjVxzh7mV9UuicBXrmlypkONUoFmNgWNHKDamQ=";
        allowedIPs = [ "10.0.0.2/32" ];
      }
      {
        name = "phone";
        publicKey = "/x3cVhfxEkBgNeZLeS/0eprprunO91IHBKkpmMyHeVg=";
        allowedIPs = [ "10.0.0.3/32" ];
      }
    ];

    moth = [
      {
        name = "melon";
        publicKey = "3qGJJDgclpaR/5tNMpcK11VV28tvlcJMWUhY95GBwho=";
        allowedIPs = [ "10.0.0.10/32" ];
      }
      {
        name = "phone";
        publicKey = "hXMyGtk/UTyv0HV8HIev7wSvpXiSeylVKBWD0Zm+/1A=";
        allowedIPs = [ "10.0.0.11/32" ];
      }
      {
        name = "tablet";
        publicKey = "GaUyI5eZDlff10+QDkVxAfD6SNet8Y4tw/J8CwM9yAc=";
        allowedIPs = [ "10.0.0.12/32" ];
      }
      {
        name = "laptop";
        publicKey = "q/VFNIYz/qsE1keB4LJJWfvOyYm0hreUmYBI0dpNw1I=";
        allowedIPs = [ "10.0.0.13/32" ];
      }
    ];
  };

  allPeers = l.flatten (
    l.mapAttrsToList (
      category: nodes: l.map (node: node // { name = "${category}-${node.name}"; }) nodes
    ) peers
  );
in
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [
      53
      port
    ];
  };

  age.secrets."wireguard/molly".file = ../../../secrets/wireguard/molly.age;

  # publicKey: 3qGJJDgclpaR/5tNMpcK11VV28tvlcJMWUhY95GBwho=
  networking.wireguard.interfaces."wg0" = {
    listenPort = port;
    privateKeyFile = config.age.secrets."wireguard/molly".path;
    ips = [ "10.0.0.1/24" ];
    peers = allPeers;
  };
}
