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
      useradd-string = (user: is-admin: ''
        set +x # don't leak the hashed password
        echo "creating user ${user}"
        useradd \
        -m \
        ${if is-admin then "-G ${jupyterAdminGroup}" else ""} \
        -p $(cat /pw/hashed-password-${user}) \
        ${user} \
        && chown -R ${user}:${jupyterAdminGroup} /home/${user} \
        && ln --force -s /workdir /home/${user}/shared-workdir
        set -x
      '');

      create-all-users-script = (lib.strings.concatStringsSep "\n" (builtins.map (u: (useradd-string u.username u.isAdmin)) jupyterUsers));
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
        chown root:${jupyterAdminGroup} /workdir
        chmod -R g+rwx /workdir

        # create all the users
        ${create-all-users-script}

        # install the python environ
        conda install -c conda-forge mamba

        mamba install -c conda-forge ${packages} \
                         jupyterlab \
                         jupyterhub


        # off to the races
        jupyterhub --ip=${bind-ip} --port=${toString bind-port} -f /jupyterhub-config.py
      '';
    in
    ''
      #!${pkgs.runtimeShell}
      mkdir -p /workdir

      # make temp store for pw hashes
      mkdir -p /pw

      cp ${jupyterhub-config} /jupyterhub-config.py
      cp ${entrypoint}/bin/entrypoint.sh /entrypoint.sh
    '';
  config = {
    WorkingDir = "/workdir";
    Entrypoint = "/entrypoint.sh";
  };
}
