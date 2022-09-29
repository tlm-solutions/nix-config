{ lib, config, ... }:
let
  cfg = config.deployment-dvb.net;
in
  {
    options.deployment-dvb.net = with lib; {
      iface.uplink = {
        name = mkOption {
          type = types.str;
          default = "";
        };
        useDHCP = mkOption {
          type = types.bool;
          default = true;
        };
        addr4 = mkOption {
          type = types.str;
          default = "";
          description = "address with prefix in CIDR notation";
        };
        routes =
          with utils.systemdUtils.unitOptions;
          with utils.systemdUtils.lib;
          with lib;
          mkOption {
            type = with types; listOf (submodule routeOptions);
            default = [ ];
            description = "default gateway";
          };
          dns = mkOption {
            type = types.listOf types.str;
            default = [ "9.9.9.9" "1.1.1.1" "8.8.8.8" ];
          };
        };
      };


      config = let
        upname = "30-${cfg.iface.uplink.name}";
        upconf = if cfg.iface.uplink.useDHCP == false then {
          MatchConfig = { Name = "${cfg.iface.uplink.name}"; };
          networkConfig = {
            DHCP = "no";
            Address = cfg.iface.uplink.addr4;
            DNS = cfg.iface.uplink.DNS;
          };
          routes = cfg.iface.uplink.routes;
        } else {
          MatchConfig = { Name = "${cfg.iface.uplink.name}"; };
          networkConfig = {
            DHCP = "yes";
          };
        };

      in
      {
        networking.useSystemd = true;
        systemd.networks.
      };
    }
