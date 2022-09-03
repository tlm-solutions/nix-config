{ pkgs, config, lib, ... }: 
let
  documentation-package = pkgs.stdenv.mkDerivation {
    pname = "dvb-dump-docs";
    version = "0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "dump-dvb";
      repo = "documentation";
      rev = "4c6a265ef894a57da94b753e7e5464c143ed2a53"; #TODO: use tag
      sha256 = "sha256-5JV2JYS2QEyB0cewIOLl7iqpcagyCP/expnExyi5E/Q=";
    };

    nativeBuildInputs = with pkgs; [ mdbook mdbook-mermaid ];

    patchPhase =  ''
      cp ${pkgs.options-docs} src/chapter_2_3_nixos_options.md
    '';

    buildPhase = ''
      ${pkgs.mdbook-mermaid}/bin/mdbook-mermaid install
      ${pkgs.mdbook}/bin/mdbook build
    '';

    installPhase  = ''
      mkdir -p $out/bin/
      cp -r book/* $out/bin/
    '';

    meta = with lib; {
      description = "Documentation for DVB-Dump project";
      homepage = "https://github.com/dump-dvb/documentation";
    };
  };
in {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "docs.${config.dump-dvb.domain}" = {
          enableACME = true;
          forceSSL = true;
          locations = {
            "/" = {
              root = "${documentation-package}/bin/";
              index = "index.html";
            };
          };
        };
      };
    };
  };
}
