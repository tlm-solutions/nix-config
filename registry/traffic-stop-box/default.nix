{
  # Barkhausen Bau
  "0" = {
    wireguardPublicKey = "qyStvzZdoqcjJJQckw4ZwvsQUa+8TBWtnsRxURqanno=";
    hostName = "traffic-stop-box-0";
    r09-receiver = { frequency = 170790000; offset = 20000; device = ""; RF = 0; IF = 0; BB = 32; }; # dresden - barkhausen
    wgAddr4 = "10.13.37.100";
    arch = "x86_64-linux";
    monitoring = true;
    telegramDecoderConfig = ./config_0.json;
    publicWireguardEndpoint = null;
  };
  # Zentralwerk
  "1" = {
    wireguardPublicKey = "dOPobdvfphx0EHmU7dd5ihslFzZi17XgRDQLMIUYa1w=";
    hostName = "traffic-stop-box-1";
    r09-receiver = { frequency = 170790000; offset = 20000; device = ""; RF = 14; IF = 32; BB = 42; }; # dresden - zentralwerk
    wgAddr4 = "10.13.37.101";
    arch = "x86_64-linux";
    monitoring = true;
    telegramDecoderConfig = ./config_1.json;
    publicWireguardEndpoint = null;
  };
  # Wundstr. 9
  "4" = {
    wireguardPublicKey = "B0wPH0jUxaatRncHMkgDEQ+DzvlbTBrVJY4etxqQgG8=";
    hostName = "traffic-stop-box-4";
    r09-receiver = { frequency = 170790000; offset = 20000; device = ""; RF = 14; IF = 32; BB = 42; }; # dresden Wundstr. 9
    wgAddr4 = "10.13.37.104";
    arch = "x86_64-linux";
    monitoring = true;
    telegramDecoderConfig = ./config_4.json;
    publicWireguardEndpoint = null;
  };
}
