{ lib, config, ... }:
let
  cfg = config.deployment-dvb.net.wg;
in
  {
    options.deployment-dvb.net.wg = {
      _enable = mkOption {
        type = types.bool;
        default = true;
      };
      ownEndpoint.host = mkOption {
        type = types.str;
        default = "";
      };
      ownEndpoint.port = mkOption {
        type = types.port;
      };
      ownPubkey = mkOption {
        type = types.str;
        default = "";
      };
      privateKeyFile = mkOption {
        type = types.either types.str types.path;
      };
      addr4 = mkOption {
        type = types.str;
        default = "";
        description = "address with prefix in CIDR notation";
      };
    };

    config = let
    in {
      netoworking.useNetworkd = true;

      systemd.network.netdev.wg-dvb = {
        type = "wireguard";
        
      };
    };
  }
