{self, pkgs, lib, boxes}: 
let
    # command which generates the update script for that specific machine
    installScript = (target: (pkgs.writeScript "deploy" ''
      #!${pkgs.runtimeShell}
      ssh root@10.13.37.${toString (target + 100)} "ps cax | grep \"nixos-rebuild\" > /dev/null"
      if [ $? -eq 0 ]
      then
          echo "Process is running."
          exit
      else
          echo "Process is not running."
          nix copy --to ssh://root@10.13.37.${toString (target + 100)} ${self}
          ssh root@10.13.37.${toString (target + 100)} -- nixos-rebuild switch --flake ${self}#traffic-stop-box-${toString target}
      fi
    ''));

    # concatanes commands together
    deployBoxes = (systems: lib.strings.concatStringsSep " "
      (builtins.map (system: "${(installScript system)}") systems));

    deployAllScript = (pkgs.writeScript "deploy-all" (
      '' 
              #!${pkgs.runtimeShell} -ex
              ${pkgs.parallel}/bin/parallel --citation
              ${pkgs.parallel}/bin/parallel -j10 ::: ${deployBoxes boxes} || echo "Some deployment failed"
      ''
    ));

  individualScripts = lib.foldl (x: y: lib.mergeAttrs x y) {} (builtins.map (number: {"deploy-box-${toString number}" = (installScript number);}) boxes);

in ({
  deploy-all = deployAllScript;
}) #individualScripts

#in (individualScripts // {
#  deploy-all = deployAllScript;
#})
