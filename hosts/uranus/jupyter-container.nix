{ pkgs
, lib
, packages
, jupyterUsers
, jupyterAdminGroup ? "uranus-owner"
, bind-ip ? "0.0.0.0"
, bind-port ? 8080
, ...
}:
let
  miniconda-dockerhub = pkgs.dockerTools.pullImage {
    imageName = "continuumio/miniconda3";
    imageDigest = "sha256:a4b665d2075d9bf4b2c5aa896c059439a0baa5538ca67589a673121c31b4c35d";
    sha256 = "sha256-boIAZ8PaPckWLzYYTqrqMEL7HGbyl9grCJrXOpsBMhg=";
    finalImageTag = "23.3.1-0";
    finalImageName = "miniconda";

  };
in
pkgs.dockerTools.buildImage {
  name = "stateful-jupyterlab";
  tag = "latest";
  fromImage = miniconda-dockerhub;
  runAsRoot =
    let
      cont-interpreter = "/bin/bash";
      useradd-string = (user: hashed-pw: is-admin: ''useradd \
                            ${if is-admin then "-G ${jupyterAdminGroup}" else ""} \
                            -p ${hashed-pw} \
                            ${user}'');

      create-all-users-script = pkgs.writeScriptBin "create-users"
        (lib.strings.concatStringsSep "\n" (builtins.map (u: (useradd-string u.username u.hashedPassword u.isAdmin)) jupyterUsers));
        # (lib.foldl
        # (script: u: lib.strings.concatStringsSep "\n" script (useradd-string u.username u.hashedPassword u.isAdmin)) ''''
        # jupyterUsers);

        jupyterhub-config = pkgs.writeText "jupyterhub-config.py" ''
          c = get_config()

          c.PAMAuthenticator.admin_groups = {'${jupyterAdminGroup}'}

          c.Spawner.notebook_dir='/workdir'
          c.Spawner.default_url='/lab'
        '';

      entrypoint = pkgs.writeScriptBin "entrypoint.sh" ''
        #!${cont-interpreter}
        set -ex

        # Update the System
        apt update -y
        apt dist-upgrade -y

        # create jupyter group
        groupadd ${jupyterAdminGroup}

        # create all the users
        ${create-all-users-script}/bin/create-users

        # install the python environ
        conda install -c conda-forge ${packages} \
                         jupyterlab \
                         jupyterhub

        # off to the races
        jupyterhub --ip=${bind-ip} --port=${toString bind-port} -f /jupyterhub-config.py
      '';
    in
    ''
      #!${pkgs.runtimeShell}
      mkdir -p /workdir
      cp ${jupyterhub-config} /jupyterhub-config.py
      cp ${entrypoint}/bin/entrypoint.sh /entrypoint.sh
    '';
  config = {
    WorkingDir = "/workdir";
    Entrypoint = "/entrypoint.sh";
  };
}
