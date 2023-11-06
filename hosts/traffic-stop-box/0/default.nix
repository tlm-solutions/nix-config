{ self, ... }: {
  imports = [
    "${self}/hardware/dell-wyse-3040.nix"
  ];

  deployment-TLMS.net.wg.publicKey = "qyStvzZdoqcjJJQckw4ZwvsQUa+8TBWtnsRxURqanno=";

  TLMS.telegramDecoder.errorCorrection = false;
}
