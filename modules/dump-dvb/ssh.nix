{ lib, config, ... }: {
  options.dump-dvb = {
    installSSHKeys = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''If the machine belongs to dump-dvb and we need all of our private keys on it'';
    };
  };

  config = lib.mkIf config.dump-dvb.installSSHKeys {
    users.users.root = {
      openssh.authorizedKeys.keyFiles = [
        ../../keys/ssh/revol-xut
        ../../keys/ssh/oxa
        ../../keys/ssh/oxa1
        ../../keys/ssh/marenz1
        ../../keys/ssh/marenz2
        ../../keys/ssh/astro
      ];
    };
    services.openssh = {
      permitRootLogin = "prohibit-password";
      passwordAuthentication = false;
    };
  };
}

