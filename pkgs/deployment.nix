{ self, pkgs, lib }:

# This generates deployement scripts **ONLY** for non-microvm (e.g. bare-metal
# or conventional vm) hosts

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
      set -e

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

  # garbage collect everything
  garbageCollect = (system:
    let
      ip = system.config.deployment-TLMS.net.wg.addr4;
      host = system.config.networking.hostName;
    in
    (pkgs.writeScriptBin "deploy" ''
      #!${pkgs.runtimeShell}
      set -e

      echo -e "\033[0;33mChecking if ${host} is up (ip: ${ip})\033[0m"

      if ping -c 1 ${ip} > /dev/null
      then
          echo -e "\033[0;32mCollecting garbage on ${host} with \"nix-collect-garbage -d\"\033[0m"
          ssh root@${ip} -- nix-collect-garbage -d
      else
          echo -e "\033[0;31m${ip} seems to be down!\033[0m"
          exit 1
      fi
    ''));

  # reboot everything
  reboot = (system:
    let
      ip = system.config.deployment-TLMS.net.wg.addr4;
      host = system.config.networking.hostName;
    in
    (pkgs.writeScriptBin "deploy" ''
      #!${pkgs.runtimeShell}
      set -e

      echo -e "\033[0;33mChecking if ${host} is up (ip: ${ip})\033[0m"

      if ping -c 1 ${ip} > /dev/null
      then
          echo -e "\033[0;32mRebooting ${host}\033[0m"
          ssh root@${ip} -- shutdown -r 1
          echo -e "\033[0;31m${host} IS SCHEDULED FOR REBOOT IN 1 MINUTE\033[0m"
      else
          echo -e "\033[0;31m${ip} seems to be down!\033[0m"
          exit 1
      fi
    ''));

  # individual script generation
  deployScriptWriter = (command:
    lib.mapAttrs'
      (name: system:
        lib.nameValuePair ("rebuild-" + command + "-" + name) (deployScriptTemplate system command))
      nonVmHosts);

  switchInstallScripts = deployScriptWriter "switch";
  bootInstallScripts = deployScriptWriter "boot";
  installScripts = bootInstallScripts // switchInstallScripts;

  garbageCollectScripts = lib.mapAttrs' (name: system: lib.nameValuePair ("collect-garbage-" + name) (garbageCollect system)) nonVmHosts;

  rebootScripts = lib.mapAttrs' (name: system: lib.nameValuePair ("reboot-" + name) (reboot system)) nonVmHosts;

  ## all at once
  switchAll = lib.strings.concatMapStringsSep "\n" (path: "${path}/bin/deploy") (builtins.attrValues switchInstallScripts);
  bootAll = lib.strings.concatMapStringsSep "\n" (path: "${path}/bin/deploy") (builtins.attrValues bootInstallScripts);
  rebootAll = lib.strings.concatMapStringsSep "\n" (path: "${path}/bin/deploy") (builtins.attrValues rebootScripts);
  garbageAll = lib.strings.concatMapStringsSep "\n" (path: "${path}/bin/deploy") (builtins.attrValues garbageCollectScripts);

  nukeAll = lib.mapAttrs'
    (name: scripts: lib.nameValuePair (name) (pkgs.writeScriptBin "${name}" ''
      #!${pkgs.runtimeShell}
      set -x

      ${scripts}
    ''))
    {
      rebuild-boot-all = bootAll;
      rebuild-switch-all = switchAll;
      reboot-all = rebootAll;
      garbage-collect-all = garbageAll;
    };

in
installScripts //
garbageCollectScripts //
rebootScripts //
nukeAll
