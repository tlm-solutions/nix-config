{ self, ... }: {
  imports = [
    "${self}/hardware/dell-wyse-3040.nix"
  ];

  deployment-dvb.net.wg.publicKey = "qyStvzZdoqcjJJQckw4ZwvsQUa+8TBWtnsRxURqanno=";
}
