/*
  This file contains the configuration for the gnuradio sdr decoding pipeline
*/

{ pkgs, config, lib, ... }:
let
  file = ../configs + "/config_${toString config.dvb-dump.systemNumber}.json";

in
{
  systemd = {
    services = {
      "gnuradio" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = "exec ${pkgs.gnuradio-decode}/bin/recv_and_demod.py &";

        serviceConfig = {
          Type = "forking";
          User = "gnuradio";
          Restart = "on-failure";
          StartLimitBurst = "2";
          StartLimitIntervalSec = "150s";
        };
      };

      "telegram-decoder" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = "exec ${pkgs.telegram-decoder}/bin/telegram-decode --config ${file} --server http://10.13.37.1:8080 &";

        serviceConfig = {
          Type = "forking";
          User = "telegram-decoder";
          Restart = "on-failure";
          StartLimitBurst = "2";
          StartLimitIntervalSec = "150s";
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
