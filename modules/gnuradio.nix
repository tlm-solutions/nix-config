/*
  This file contains the configuration for the gnuradio sdr decoding pipeline
*/

{ pkgs, config, lib, ... }: {
  systemd = {
    services."gnu-radio" = {
      enable = true;
      wantedBy = [ "multi-user.target" ];

      script = ''
        ${pkgs.gnuradio-decode}/bin/recv_and_demod.py
      '';

      serviceConfig = {
        Forking = true;
        User = "gnuradio";
        Restart = "always";
      };
    };
  };

  users.users.gnu-radio = {
    name = "gnuradio";
    description = "gnu radio service user";
    isNormalUser = true;
  };
}
