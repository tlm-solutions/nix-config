{ self, ... }: {
  imports = [
    "${self}/hardware/dell-wyse-3040.nix"
  ];

  deployment-TLMS.net.wg.publicKey = "4TUQCToGNhjsCgV9elYE/91Vd/RvMgvMXtF/1Dzlvxo=";
}
