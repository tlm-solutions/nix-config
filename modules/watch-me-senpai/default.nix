{pkgs, config, lib, ...}: {
  imports = [
    ../dump-dvb/base.nix
  ];

  sops.defaultSopsFile = ../../secrets/watch-me-senpai/secrets.yaml;
  deployment-dvb.net = {
    wg = {
      addr4 = "10.13.37.6";
      prefix4 = 24;
      privateKeyFile = config.sops.secrets.wg-seckey.path;
      publicKey = "aNd+oXT3Im3cA0EqK+xL+MRjIx4l7qcXZk+Pe2vmRS8=";
    };

  };

  deployment-dvb.domain = "dvb.solutions";
}
