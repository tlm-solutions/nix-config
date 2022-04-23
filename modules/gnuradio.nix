/*
  This file contains the configuration for the gnuradio sdr decoding pipeline
*/

{ pkgs, config, lib, ... }: {
  systemd = {
    services = {
      "gnuradio" = {
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

      "telegram-decoder" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = ''
          ${pkgs.telegram-decode}/bin/decode_telegrams.py
        '';

        serviceConfig = {
          Forking = true;
          User = "telegram-decoder";
          Restart = "always";
        };
      };
    };
  };

  # user accounts for systemd units
  users.users = {
    gnu-radio = {
      name = "gnuradio";
      description = "gnu radio service user";
      isNormalUser = true;
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
      capabilities = "cap_sys_nice";
      source = "${pkgs.gnuradio-decode}/bin/recv_and_demod.py";
    };
  };
}
