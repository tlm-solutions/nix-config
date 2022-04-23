/*
  This file contains the configuration for the gnuradio sdr decoding pipeline
*/

{ pkgs, config, lib }: {
  systemd = {
    services."gnu-radio" = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      script = ''

      '';

      serviceConfig = {
        User = "gnuradio";
        Restart = "always";
      };
    };
  };
  users.users.infoscreen = {
    name = "infoscreen";
    description = "custom user for service infoscreen service";
    isNormalUser = true;
  };
}
