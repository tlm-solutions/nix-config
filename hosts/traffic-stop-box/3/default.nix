{ self, ... }: {
  imports = [
    "${self}/hardware/rpi-3b-4b.nix"
  ];

  deployment-dvb.net.wg.publicKey = "w3AT3EahW1sCK8ZsR7sDTcQj1McXYeWx7fnfQFA7i3o=";
}
