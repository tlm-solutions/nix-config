{ self, pkgs, lib }:
let
  # filter out deployable (aka not microvm or container) systems
  filterHosts = k: v: !(builtins.hasAttr "microvm" v.config);
  nonVmHosts = lib.filterAttrs filterHosts self.nixosConfigurations;

  # the deployment script
  deployScriptTemplate = (system: command:
    let
      ip = system.config.deployment-TLMS.net.wg.addr4;
      host = system.config.networking.hostName;
    in

    (pkgs.writeScriptBin "deploy" ''
      #!${pkgs.runtimeShell}
      set -xe

      echo -e "\033[0;33mChecking if ${host} is up (ip: ${ip})\033[0m"

      if ping -c 1 ${ip} > /dev/null
      then
          echo -e "\033[0;32mRedeploying ${host} with \"${command}\"\033[0m"
          nixos-rebuild --flake ${self}\#${system.config.networking.hostName} --target-host root@${ip} --use-substitutes ${command} -L
      else
          echo -e "\033[0;31m${ip} seems to be down!\033[0m"
          exit 1
      fi
    ''));

  deployScriptWriter = (command:
    pkgs.lib.mapAttrs'
      (name: system:
        lib.nameValuePair ("rebuild-" + command + "-" + name) (deployScriptTemplate system command))
      nonVmHosts);

  supported_commands = [
    "switch"
    "boot"
  ];

  installScripts = lib.foldl (attr: cmd: lib.mergeAttrs attr (deployScriptWriter cmd)) { } supported_commands;
in
installScripts
