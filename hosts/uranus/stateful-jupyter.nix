{ pkgs, config, lib, ... }:
let
  jupyterUsers = [
    {
      username = "0xa";
      userPasswordFile = config.sops.secrets.hashed-password-0xa.path;
      isAdmin = true;
    }
    {
      username = "tassilo";
      userPasswordFile = config.sops.secrets.hashed-password-tassilo.path;
      isAdmin = true;
    }
    {
      username = "marenz";
      userPasswordFile = config.sops.secrets.hashed-password-marenz.path;
      isAdmin = true;
    }
  ];

  # move the secrets to the volume
  secret-setup = (lib.strings.concatStringsSep "\n" (builtins.map (u: "cp --force --dereference ${u.userPasswordFile} /var/lib/pw/") jupyterUsers));
in
{
  sops.secrets = {
    hashed-password-0xa = { };
    hashed-password-tassilo = { };
    hashed-password-marenz = { };
  };

  virtualisation.docker = {
    enable = true;
    # automatic selection by docker
    storageDriver = null;
  };

  # user to run the thing
  # jupyterlab container
  virtualisation.oci-containers = {
    backend = "docker";
    containers."jupyterlab-stateful" = {
      autoStart = true;
      ports = [ "8080:8080" ];
      volumes = [
        "/var/lib/jupyter-volume:/workdir"
        "/var/lib/root-home:/root"
        "/var/lib/pw:/pw"
        "/var/lib/users-home:/home"
      ];
      imageFile =
        let
          packages = lib.concatStringsSep " " [
            # alphabetically `:sort`ed plz
            "bitstring"
            "geojson"
            "matplotlib"
            "numpy"
            "pandas"
            "pip"
            "psycopg"
            "scipy"
            "seaborn"
          ];
        in
        (import ./jupyter-container.nix {
          inherit pkgs lib jupyterUsers packages;
        });
      image = "stateful-jupyterlab";
    };
  };

  systemd.services = {
    setup-docker-pws = {
      description = "copy the user passwords to docker volume";
      wantedBy = [ "jupyterlab-stateful.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = secret-setup;
    };
    docker-jupyterlab-stateful = {
      after = [ "setup-docker-pws.service" ];
      requires = [ "setup-docker-pws.service" ];
    };
  };

}
