{ self, ... }: {
  imports = [
    "${self}/hardware/dell-wyse-3040.nix"
  ];

  deployment-TLMS.net.wg.publicKey = "dL9JGsBhaTOmXgGEH/N/GCHbQgVHEjBvIMaRtCsHBHw=";
}
