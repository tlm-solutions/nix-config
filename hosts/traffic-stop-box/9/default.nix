{ self, ... }: {
  imports = [
    "${self}/hardware/rpi-3b-4b.nix"
  ];

  services.openssh.extraConfig = ''
    PubkeyAcceptedKeyTypes sk-ecdsa-sha2-nistp256@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,ssh-rsa,rsa-sha2-256,rsa-sha2-512
  '';
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJO/8PRzEqW20vnADv5xJrV5AlQ9bS8251AyQACyFMz+ dumbdvb_clarity"
  ];

  deployment-TLMS.net.wg.publicKey = "j2hGr2rVv7T9kJE15c2IFWjmk0dXuJPev2BXiHZUKk8=";
}
