{ self, ... }: {
  imports = [
    "${self}/hardware/dell-wyse-3040.nix"
  ];

  deployment-dvb.net.wg.publicKey = "dOPobdvfphx0EHmU7dd5ihslFzZi17XgRDQLMIUYa1w=";
}
