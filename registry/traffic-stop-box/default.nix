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
  "2" = {
    wireguardPublicKey = "4TUQCToGNhjsCgV9elYE/91Vd/RvMgvMXtF/1Dzlvxo=";
    hostName = "traffic-stop-box-2";
    r09-receiver = { frequency = 153850000; offset = 20000; device = ""; RF = 14; IF = 32; BB = 42; }; # chemnitz
    wgAddr4 = "10.13.37.102";
    telegramDecoderConfig = ./config_2.json;
    publicWireguardEndpoint = null;
  };
  "3" = {
    wireguardPublicKey = "w3AT3EahW1sCK8ZsR7sDTcQj1McXYeWx7fnfQFA7i3o=";
    hostName = "traffic-stop-box-3";
    r09-receiver = { frequency = 170795000; offset = 19400; device = ""; RF = 14; IF = 32; BB = 42; }; # dresden unused
    wgAddr4 = "10.13.37.103";
    telegramDecoderConfig = ./config_3.json;
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
  # number 5 is missing
  "6" = {
    wireguardPublicKey = "NuLDNmxuHHzDXJSIOPSoihEhLWjARRtavuQvWirNR2I=";
    hostName = "traffic-stop-box-6";
    r09-receiver = { frequency = 150827500; offset = 19550; device = ""; RF = 14; IF = 32; BB = 42; }; # warpzone münster
    wgAddr4 = "10.13.37.106";
    telegramDecoderConfig = ./config_6.json;
    publicWireguardEndpoint = null;
  };
  "7" = {
    wireguardPublicKey = "sMsdY7dSjlYeIFMqjkh4pJ/ftAYXlyRuxDGbdnGLpEQ=";
    hostName = "traffic-stop-box-7";
    r09-receiver = { frequency = 150827500; offset = 19550; device = ""; RF = 14; IF = 32; BB = 42; }; # drehturm aachen
    wgAddr4 = "10.13.37.107";
    telegramDecoderConfig = ./config_7.json;
    publicWireguardEndpoint = null;
  };
  # Hannover Bredero Hochhaus City
  "8" = {
    wireguardPublicKey = "dL9JGsBhaTOmXgGEH/N/GCHbQgVHEjBvIMaRtCsHBHw=";
    hostName = "traffic-stop-box-8";
    r09-receiver = { frequency = 150890000; offset = 20000; device = ""; RF = 14; IF = 32; BB = 42; }; # Hannover Bredero Hochhaus City
    wgAddr4 = "10.13.37.108";
    arch = "aarch64-linux";
    monitoring = false;
    telegramDecoderConfig = ./config_8.json;
    publicWireguardEndpoint = null;
  };
  # Hannover Bredero Hochhaus Wider Area
  "9" = {
    wireguardPublicKey = "j2hGr2rVv7T9kJE15c2IFWjmk0dXuJPev2BXiHZUKk8=";
    hostName = "traffic-stop-box-9";
    r09-receiver = { frequency = 152830000; offset = 20000; device = ""; RF = 14; IF = 32; BB = 42; }; # Hannover Bredero Hochaus Umland
    wgAddr4 = "10.13.37.109";
    arch = "aarch64-linux";
    monitoring = false;
    telegramDecoderConfig = ./config_9.json;
    publicWireguardEndpoint = null;
  };
  "10" = {
    wireguardPublicKey = "dL9JGsBhaTOmXgGEH/N/GCHbQgVHEjBvIMaRtCsHBHw=";
    hostName = "traffic-stop-box-10";
    r09-receiver = { frequency = 153850000; offset = 20000; device = ""; RF = 14; IF = 32; BB = 42; }; # CLT
    wgAddr4 = "10.13.37.110";
    telegramDecoderConfig = ./config_10.json;
    publicWireguardEndpoint = null;
  };
}
