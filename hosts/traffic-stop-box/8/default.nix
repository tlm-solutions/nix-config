{ self, ... }: {
  imports = [
    "${self}/hardware/rpi-3b-4b.nix"
  ];

  services.openssh.extraConfig = ''
    PubkeyAcceptedKeyTypes sk-ecdsa-sha2-nistp256@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,ssh-rsa,rsa-sha2-256,rsa-sha2-512
  '';
  users.users.root.openssh.authorizedKeys.keys = [
  ];

  deployment-TLMS.net.wg.publicKey = "YEkJ43iA1nAXeY1jv49Q6mWzuT3ZIAac+I6B6abvpmg=";
}
