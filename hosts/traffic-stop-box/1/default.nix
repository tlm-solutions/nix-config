{ self, ... }: {
  imports = [
    "${self}/hardware/dell-wyse-3040.nix"
  ];

  TLMS.telegramDecoder.errorCorrection = false;
}
