{ pkgs, packages, bind-ip ? "0.0.0.0", bind-port ? 8080, ... }:
let
  miniconda-alpine-dockerhub = pkgs.dockerTools.pullImage {
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
  fromImage = miniconda-alpine-dockerhub;
  runAsRoot =
    let
      entrypoint = pkgs.writeScriptBin "entrypoint.sh" ''
        #!/bin/bash
        conda install ${packages} \
                      jupyterlab

        jupyter-lab --ip=${bind-ip} --port=${toString bind-port} --no-browser --allow-root
      '';
    in
    ''
      #!${pkgs.runtimeShell}
      mkdir -p /workdir
      cp ${entrypoint}/bin/entrypoint.sh /entrypoint.sh
    '';
  config = {
    WorkingDir = "/workdir";
    Entrypoint = "/entrypoint.sh";
  };
}
