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
    imageDigest = "sha256:6a66425f001f739d4778dd732e020afeb06175f49478fafc3ec673658d61550b";
    sha256 = "sha256-/0P12tK+Z9eng448m+TMaUOtucUxrPos8iAeqbOvIP4=";
    finalImageTag = "24.11.1-0";
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
        ${if is-admin then "-g ${jupyterAdminGroup}" else ""} \
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
        c.Authenticator.allowed_users = {'marenz', 'oxa', 'tassilo'}
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
        chown -R root:${jupyterAdminGroup} /workdir
        chmod -R g+rwx /workdir

        # create all the users
        ${create-all-users-script}

        # install the python environ
        conda install -c conda-forge mamba

        mamba install -c conda-forge ${packages} \
                         jupyterlab \
                         jupyterhub

        # upgrading the db
        jupyterhub upgrade-db

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
