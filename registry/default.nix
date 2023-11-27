{
  data-hoarder = import ./data-hoarder // {
    wireguardPublicKey = "WDvCObJ0WgCCZ0ORV2q4sdXblBd8pOPZBmeWr97yphY=";
    hostName = "data-hoarder";
    wgAddr4 = "10.13.37.1";
    publicWireguardEndpoint = {
      host = "endpoint.tlm.solutions";
      port = 51820;
    };
  };
  staging-data-hoarder = import ./data-hoarder // {
    hostName = "staging-data-hoarder";
    wgAddr4 = "10.13.37.5";
    wireguardPublicKey = "48hc7DVnUh2DHYhrxrNtNzj05MRecJO52j2niPImvkU=";
    publicWireguardEndpoint = null;
  };
  traffic-stop-box = import ./traffic-stop-box;
  notice-me-senpai = {
    hostName = "notice-me-senpai";
    wgAddr4 = "10.13.37.200";
    wireguardPublicKey = "z2E9TjL9nn0uuLmyQexqddE6g8peB5ENyf0LxpMolD4=";
    publicWireguardEndpoint = null;
    port-loki = 3100;
  };
  uranus = {
    hostName = "uranus";
    wgAddr4 = "10.13.37.9";
    wireguardPublicKey = "KwCG5CWPdNmrjEOYJYD2w0yhzoWpYHrjGbstdT5+pFk=";
    publicWireguardEndpoint = null;
  };
  tram-borzoi = {
    hostName = "tram-borzoi";
    wgAddr4 = "10.13.37.8";
    wireguardPublicKey = "wCW+r5kAaIarvZUWf4KsJNetyHobP0nNy5QOhqmsCCs=";
    publicWireguardEndpoint = null;
    postgres = {
      host = "127.0.0.1";
      port = 5432;
      passwordFile = "/run/secrets/postgres-borzoi-pw";
      user = "borzoi";
      database = "borzoi";
    };
    port-borzoi = {
      host = "0.0.0.0";
      port = 8080;
    };
  };
}
