/*
  This file contains the configuration for the gnuradio sdr decoding pipeline
*/

{ pkgs, config, lib, ... }: 
let
  #file = ../configs/config_+"${toString config.dvb-dump.systemNumber}.json";
  configFiles = [
    ../configs/config_0.json
  ];
  
  file = builtins.elemAt configFiles config.dvb-dump.systemNumber;

in { 
  systemd = {
    services = {
      "gnuradio" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = "exec ${pkgs.gnuradio-decode}/bin/recv_and_demod.py &";

        serviceConfig = {
          Type = "forking";
          User = "gnuradio";
          Restart = "always";
        };
      };

      "telegram-decoder" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = "exec ${pkgs.telegram-decoder}/bin/telegram-decode --config ${file} &";

        serviceConfig = {
          Type = "forking";
          User = "telegram-decoder";
          Restart = "always";
        };
      };
    };
  };

  # user accounts for systemd units
  users.users = {
    gnuradio = {
      name = "gnuradio";
      description = "gnu radio service user";
      isNormalUser = true;
      extraGroups = [ "plugdev" ];
    };
    telegram-decoder = {
      name = "telegram-decoder";
      description = "gnu radio service user";
      isNormalUser = true;
    };
  };

  security.wrappers = {
    gnuradio-decode = {
      owner = "gnuradio";
      group = "users";
      capabilities = "cap_sys_nice+eip";
      source = "${pkgs.gnuradio-decode}/bin/recv_and_demod.py";
    };
  };
}
