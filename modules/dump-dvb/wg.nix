{ lib, config, self, ... }:
let
  cfg = config.deployment-dvb.net.wg;
in {
    options.deployment-dvb.net.wg = with lib; {

      ownEndpoint.host = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      ownEndpoint.port = mkOption {
        type = types.port;
        default = 51820;
      };

      publicKey = mkOption {
        type = types.str;
        default = "";
        description = "own public key";
      };
      privateKeyFile = mkOption {
        type = types.either types.str types.path;
      };
      addr4 = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      prefix4 = mkOption {
        type = types.int;
        default = 24;
        description = "network prefix";
      };

      extraPeers = mkOption {
        description = "extra peers that are not part of the deployment";
        type = types.listOf (types.submodule {
          options.addr4 = mkOption {
            type = types.str;
            description = "ip _without_ a network prefix";
          };
          options.publicKey = mkOption {
            type = types.str;
            description = "public key";
          };
        });
      };
    };

    config = let
      # move out as options?
      dvbwg-name = "wg-ddvb";
      keepalive = 25;

      # helpers
      peer-systems = (lib.filter (x: (x.config.deployment-dvb.net.wg.addr4 != cfg.addr4) && (!isNull x.config.deployment-dvb.net.wg.addr4))
      (lib.attrValues self.nixosConfigurations));

      endpoint =
        let
          ep = (lib.filter (x:
          x.config.deployment-dvb.net.wg.addr4 != cfg.addr4
          && (!isNull x.config.deployment-dvb.net.wg.ownEndpoint.host))
          (lib.attrValues self.nixosConfigurations));
        in
        assert lib.assertMsg (lib.length ep == 1) "there should be exactly one endpoint"; ep;

         peers = map (x: {
          wireguardPeerConfig = {
            PublicKey = x.config.deployment-dvb.net.wg.publicKey;
            AllowedIPs = [ "${x.config.deployment-dvb.net.wg.addr4}/32" ];
            PersistentKeepalive = keepalive;
          };
        }) peer-systems;

        ep = [ {
          wireguardPeerConfig =
            let x = lib.elemAt endpoint 0; in {
            PublicKey = x.config.deployment-dvb.net.wg.publicKey;
            AllowedIPs = [ "${x.config.deployment-dvb.net.wg.addr4}/${toString cfg.prefix4}" ];
            Endpoint = with x.config.deployment-dvb.net.wg.ownEndpoint; "${host}:${toString port}";
            PersistentKeepalive = keepalive;
          };
        } ];

      # stuff proper
      dvbwg-netdev = {
        Kind = "wireguard";
        Name = dvbwg-name;
        Description = "dump-dvb enterprise, highly available, biocomputing-neural-network maintained, converged network";
      };

      dvbwg-wireguard = {
        PrivateKeyFile = cfg.privateKeyFile;
      };

      expeers = map (x: {
        wireguardPeerConfig = {
          PublicKey = x.publicKey;
          AllowedIPs = [ "${x.addr4}/32" ];
          PersistentKeepalive = keepalive;
        };
      }) cfg.extraPeers;

      peerconf = if isNull cfg.ownEndpoint.host then ep else (peers ++ expeers);
    in
    lib.mkIf (!isNull cfg.addr4) {
      networking.wireguard.enable = true;

      systemd.network.netdevs."30-${dvbwg-name}" = {
        netdevConfig = dvbwg-netdev;
        wireguardConfig = dvbwg-wireguard;
        wireguardPeers = peerconf;
      };
    systemd.network.networks."30-${dvbwg-name}" = {
      matchConfig.Name = dvbwg-name;
      networkConfig = {
        Address = "${cfg.addr4}/${toString cfg.prefix4}";
      };
    };
  };
}
