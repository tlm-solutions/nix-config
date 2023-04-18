{ lib, config, utils, ... }:
let
  cfg = config.deployment-TLMS.net;
in
{
  options.deployment-TLMS.net = with lib; {
    iface.uplink = {
      name = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      mac = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      matchOn = mkOption {
        type = types.enum [ "name" "mac" ];
        default = "name";
      };

      useDHCP = mkOption {
        type = types.bool;
        default = true;
      };
      addr4 = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "address with prefix in CIDR notation";
      };
      routes =
        with utils.systemdUtils.unitOptions;
        with utils.systemdUtils.lib;
        with lib;
        mkOption {
          #type = with types; listOf (submodule routeOptions);
          type = types.listOf (types.attrsOf unitOption);
          default = [ ];
          description = "default gateway";
        };
      dns = mkOption {
        type = types.listOf types.str;
        default = [ "9.9.9.9" "1.1.1.1" "8.8.8.8" ];
      };
    };
  };

  config =
    let
      match = if cfg.iface.uplink.matchOn == "name" then { Name = cfg.iface.uplink.name; } else { MACAddress = cfg.iface.uplink.mac; };
      upname = "30-${cfg.iface.uplink.name}";
      upconf =
        if cfg.iface.uplink.useDHCP then {
          matchConfig = match;
          networkConfig = {
            DHCP = "yes";
          };
        } else {
          matchConfig = match;
          networkConfig = {
            DHCP = "no";
            Address = cfg.iface.uplink.addr4;
            DNS = cfg.iface.uplink.dns;
          };
          routes = cfg.iface.uplink.routes;
        };
    in
    {
      systemd.network.networks."${upname}" = upconf;

      networking.interfaces.${cfg.iface.uplink.name}.useDHCP = if !cfg.iface.uplink.useDHCP then (lib.mkForce false) else (lib.mkDefault true);
      networking.useDHCP = if !cfg.iface.uplink.useDHCP then (lib.mkForce false) else (lib.mkDefault true);
    };
}
