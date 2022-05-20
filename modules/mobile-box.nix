{ pkgs, config, lib, ... }:
let
  file = ../configs/mobile_box.json;
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

        script = "exec ${pkgs.telegram-decoder}/bin/telegram-decode --config ${file} --server http://127.0.0.1:8080 &";

        serviceConfig = {
          Type = "forking";
          User = "telegram-decoder";
          Restart = "on-failure";
          StartLimitBurst = "2";
          StartLimitIntervalSec = "150s";
        };
      };
      "data-accumulator" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = ''
          exec ${pkgs.data-accumulator}/bin/data-accumulator --host 0.0.0.0 --port 8080&
        '';

        environment = {
          "CSV_FILE" = "/var/lib/data-accumulator/formatted.csv";
        };

        serviceConfig = {
          Type = "forking";
          User = "data-accumulator";
          Restart = "on-failure";
          StartLimitBurst = "2";
          StartLimitIntervalSec = "150s";
        };
      };
      "wartrammer" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = ''
          exec ${pkgs.wartrammer-backend}/bin/wartrammer-40k --port 7680
        '';

        serviceConfig = {
          Type = "forking";
          User = "wartrammer";
          Restart = "on-failure";
          StartLimitBurst = "2";
          StartLimitIntervalSec = "150s";
        };
        
      };
      "start-wifi-hotspot" = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
        };
        script = ''
          ${pkgs.linux-router}/bin/lnxrouter --ap wlp0s20ul dump-dvb -g 10.3.141.1 -p trolling-dvb
        '';
      };
    };
  };
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "wartrammer" = {
          locations = {
            "/" = {
              root = "${pkgs.wartrammer-frontend}/bin/";
              index = "index.html";
            };
            "/api" = {
              proxyPass = "http://127.0.0.1:7680";
            };
          };
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    usbutils
    hackrf
    iw
    tcpdump
  ];

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
    data-accumulator = {
      name = "data-accumulator";
      description = "";
      isNormalUser = true;
    };
    wartrammer = {
      name = "wartrammer";
      description = "";
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
