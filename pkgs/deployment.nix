{ self, pkgs, systems }:
let

  installScript = (system:
    let ip = "10.13.37.${toString (system.config.dvb-dump.systemNumber + 100)}";
    in (pkgs.writeScriptBin "deploy" ''
      #!${pkgs.runtimeShell}
      ssh root@${ip} "ps cax | grep \"nixos-rebuild\" > /dev/null"
      if [ $? -eq 0 ]
      then
          echo "\e[1;31m [!] nixos-rebuild is already running on ${ip}"
          exit 1
      else
          nix copy --to ssh://root@${ip} ${self}
          ssh root@${ip} -- nixos-rebuild switch --flake ${self} -L
      fi
    ''));

  installScripts = pkgs.lib.mapAttrs' (name: system:
    pkgs.lib.attrsets.nameValuePair ("deploy-" + name) (installScript system))
    systems;

  deployAllExecutablePathsConcatted =
    pkgs.lib.strings.concatMapStringsSep " " (path: "${path}/bin/deploy")
    (builtins.attrValues installScripts);

  deployAllScript = (name:
    pkgs.writeScriptBin name (''
      #!${pkgs.runtimeShell} -ex
      ${pkgs.parallel}/bin/parallel --will-cite -j10 ::: ${deployAllExecutablePathsConcatted} || echo "Some deployment failed"
    ''));

in {
  deploy-all = deployAllScript "deploy-all";
  nuke-all = deployAllScript "nuke-all";
} // installScripts
