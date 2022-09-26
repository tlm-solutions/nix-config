{ pkgs, lib, stdenv, mdbook-mermaid, mdbook, options-docs, fetchFromGitHub }:
stdenv.mkDerivation {
  pname = "dvb-dump-docs";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "dump-dvb";
    repo = "documentation";
    rev = "8393cd4a965aa6b75f3e0fff6f82ba1365515290"; #TODO: use tag
    sha256 = "sha256-HppCT0UfshDxm3UNXACilpHTdvtjFs2vqpH8vbLmHTg=";
  };

  nativeBuildInputs = [ mdbook mdbook-mermaid ];

  patchPhase = ''
    cp ${options-docs} src/chapter_5_3_nixos_options.md
  '';

  buildPhase = ''
    ${mdbook-mermaid}/bin/mdbook-mermaid install
    ${mdbook}/bin/mdbook build
  '';

  installPhase = ''
    mkdir -p $out/bin/
    cp -r book/* $out/bin/
  '';

  meta = with lib; {
    description = "Documentation for DVB-Dump project";
    homepage = "https://github.com/dump-dvb/documentation";
  };
}
