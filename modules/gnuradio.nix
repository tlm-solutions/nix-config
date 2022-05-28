/*
  This file contains the configuration for the gnuradio sdr decoding pipeline
*/

{ pkgs, config, lib, ... }:
let
  file = ../configs + "/config_${toString config.dvb-dump.systemNumber}.json";

  receiver_config = [
    { frequency = "170795000"; offset = "19550"; device = "hackrf=0"; } # dresden - barkhausen
    { frequency = "170795000"; offset = "19500"; device = "hackrf=0"; } # dresden - zentralwerk
    { frequency = "153850000"; offset = "20000"; device = ""; } # chemnitz
    { frequency = "170795000"; offset = "19550"; device = "hackrf=0"; } # dresden unused
    { frequency = "170795000"; offset = "19550"; device = "hackrf=0"; } # dresden unused
  ];

  receiver = pkgs.gnuradio-decode.override (lib.elemAt receiver_config config.dvb-dump.systemNumber);
in
{
  systemd = {
    services = {
      "gnuradio" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = "exec ${receiver}/bin/recv_and_demod.py &";

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

        script = "exec ${pkgs.telegram-decoder}/bin/telegram-decode --config ${file} --server http://10.13.37.1:8080 http://10.13.37.5:8080 &";

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
      source = "${receiver}/bin/recv_and_demod.py";
    };
  };
}
