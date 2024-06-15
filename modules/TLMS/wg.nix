{ lib, config, self, registry, ... }:
let
  cfg = config.deployment-TLMS.net.wg;
in
{
  options.deployment-TLMS.net.wg = with lib; {

    privateKeyFile = mkOption {
      type = types.either types.str types.path;
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

  config =
    let
      # move out as options?
      dvbwg-name = "wg-ddvb";
      keepalive = 25;

      # helpers
      registries = builtins.attrValues (builtins.mapAttrs (name: value: value.specialArgs.registry) self.unevaluatedNixosConfigurations);

      # find all other systems registries with wireguard
      peerSystemRegistries = (lib.filter (x: (x.wgAddr4 != registry.wgAddr4) && (!isNull x.wgAddr4)) registries);

      # find all endpoint registries
      endpointRegistries =
        let
          ep = (lib.filter
            (x: x.wgAddr4 != registry.wgAddr4 && (!isNull x.publicWireguardEndpoint))
            registries);
        in
        assert lib.assertMsg (lib.length ep == 1) "there should be exactly one endpoint"; ep;

      peers = map
        (x: {
          wireguardPeerConfig = {
            PublicKey = x.wireguardPublicKey;
            AllowedIPs = [ "${x.wgAddr4}/32" ];
            PersistentKeepalive = keepalive;
          };
        })
        peerSystemRegistries;

      ep = [{
        wireguardPeerConfig =
          let x = lib.elemAt endpointRegistries 0; in {
            PublicKey = x.wireguardPublicKey;
            AllowedIPs = [ "${x.wgAddr4}/${toString cfg.prefix4}" ];
            Endpoint = with x.publicWireguardEndpoint; "${host}:${toString port}";
            PersistentKeepalive = keepalive;
          };
      }];

      # stuff proper
      dvbwg-netdev = {
        Kind = "wireguard";
        Name = dvbwg-name;
        Description = "TLMS enterprise, highly available, biocomputing-neural-network maintained, converged network";
      };

      dvbwg-wireguard = {
        PrivateKeyFile = cfg.privateKeyFile;
      } //
      (if !isNull registry.publicWireguardEndpoint then { ListenPort = registry.publicWireguardEndpoint.port; } else { });

      expeers = map
        (x: {
          wireguardPeerConfig = {
            PublicKey = x.publicKey;
            AllowedIPs = [ "${x.addr4}/32" ];
            PersistentKeepalive = keepalive;
          };
        })
        cfg.extraPeers;

      peerconf = if isNull registry.publicWireguardEndpoint then ep else (peers ++ expeers);
    in
    lib.mkIf (registry ? wgAddr4) {
      networking.wireguard.enable = true;

      networking.firewall.trustedInterfaces = [ dvbwg-name ];

      systemd.network.netdevs."30-${dvbwg-name}" = {
        netdevConfig = dvbwg-netdev;
        wireguardConfig = dvbwg-wireguard;
        wireguardPeers = peerconf;
      };
      systemd.network.networks."30-${dvbwg-name}" = {
        matchConfig.Name = dvbwg-name;
        networkConfig = {
          Address = "${registry.wgAddr4}/${toString cfg.prefix4}";
        };
      };
    };
}
