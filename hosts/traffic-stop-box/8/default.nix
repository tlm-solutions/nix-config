{ self, ... }: {
  imports = [
    "${self}/hardware/dell-wyse-3040.nix"
  ];

  services.openssh.extraConfig = ''
    PubkeyAcceptedKeyTypes sk-ecdsa-sha2-nistp256@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,ssh-rsa,rsa-sha2-256,rsa-sha2-512
  '';
  users.users.root.openssh.authorizedKeys.keys = [
  ];

  deployment-dvb.net.wg.publicKey = "dL9JGsBhaTOmXgGEH/N/GCHbQgVHEjBvIMaRtCsHBHw=";
}
