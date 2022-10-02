{ self, ... }: {
  imports = [
    "${self}/hardware/dell-wyse-3040.nix"
  ];

  services.openssh.extraConfig = ''
    PubkeyAcceptedKeyTypes sk-ecdsa-sha2-nistp256@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,ssh-rsa,rsa-sha2-256,rsa-sha2-512
  '';
  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com aaaagnnrlxnzac1lzdi1nte5qg9wzw5zc2guy29taaaaili3ylty7fwvohtwx8511v+gbtlzzmuv505fi1pj53v6aaaabhnzado="
    "sk-ssh-ed25519@openssh.com aaaagnnrlxnzac1lzdi1nte5qg9wzw5zc2guy29taaaaipzbd00cbfpxzuc8eb6sljaafnf1hgs6vci1rzcncyocaaaabhnzado="
  ];

  deployment-dvb.net.wg.publicKey = "sMsdY7dSjlYeIFMqjkh4pJ/ftAYXlyRuxDGbdnGLpEQ=";
}
