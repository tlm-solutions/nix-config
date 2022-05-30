{ pkgs, systems }:
let

  installScript = (id: 
    let
      ip = "10.13.37.${toString (id + 100)}";
    in
      (pkgs.writeScriptBin "deploy" ''
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
    '')
    );

  # concatanes commands together
  deployBoxes = (systems: pkgs.lib.strings.concatStringsSep " "
    (builtins.map (system: "${(installScript system)}/bin/deploy") systems));

  deployAllScript = (pkgs.writeScriptBin "deploy-all" (
    ''
      #!${pkgs.runtimeShell} -ex
      ${pkgs.parallel}/bin/parallel --will-cite -j10 ::: ${deployBoxes id_list} || echo "Some deployment failed"
    ''
  ));

  individualScripts = pkgs.lib.mapAttrs' (name: value: pkgs.lib.attrsets.nameValuePair ("deploy-" + name) (builtins.map installScript value)) systems;
in {
  deploy-all = deployAllScript;
} // individualScripts;
