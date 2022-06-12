{ pkgs, config, lib, ... }:
let
  receiver = pkgs.gnuradio-decoder;
  cfg = config.dump-dvb.services.gnuradio;
in
{
  options.dump-dvb.services.gnuradio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''Wether to enable dump-dvb gnuradio reciever'';
    };
    device = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "hackrf=0";
      description = ''Device string to pass to gnuradio'';
    };
    frequency = lib.mkOption {
      type = lib.types.int;
      default = 170795000;
      description = ''Frequency to tune radio to'';
    };
    offset = lib.mkOption {
      type = lib.types.int;
      default = 19550;
      description = ''Offset of the signal from center frequency'';
    };
  };

  config = lib.mkIf config.dump-dvb.services.gnuradio.enable {

    systemd.services."gnuradio" = {
      enable = true;
      wantedBy = [ "multi-user.target" ];

      script = "exec ${receiver}/bin/gnuradio-decoder-cpp ${toString cfg.frequency} ${toString cfg.offset} ${cfg.device} &";

      serviceConfig = {
        Type = "forking";
        User = "gnuradio";
        Restart = "on-failure";
        StartLimitBurst = "2";
        StartLimitIntervalSec = "150s";
      };
    };

    users.groups.gnuradio = { };
    users.users.gnuradio = {
      name = "gnuradio";
      description = "gnu radio service user";
      isSystemUser = true;
      group = "gnuradio";
      extraGroups = [ "plugdev" ];
    };

    security.wrappers.gnuradio-decode = {
      owner = "gnuradio";
      group = "users";
      capabilities = "cap_sys_nice+eip";
      source = "${receiver}/bin/gnuradio-decoder-cpp";
    };

  };
}

