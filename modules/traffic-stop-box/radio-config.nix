{ config, lib, self, registry, ... }:
let

  file = with config.deployment-TLMS; "${self}/hosts/traffic-stop-box/${toString systemNumber}/config_${toString systemNumber}.json";
in
{
  TLMS.gnuradio = {
    enable = true;
  } // registry.gnuradio;

  TLMS.telegramDecoder = {
    enable = true;
    server = [ "http://10.13.37.1:8080" "http://10.13.37.5:8080" "http://10.13.37.7:8080" ];
    configFile = file;
    authTokenFile = config.sops.secrets.telegram-decoder-token.path;
  };
}
