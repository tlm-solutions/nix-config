{ lib, stdenv, mdbook-mermaid, mdbook, documentation-src, options-docs, fetchFromGitHub }:
stdenv.mkDerivation {
  pname = "dvb-dump-docs";
  version = "0.1.0";

  src = documentation-src;

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
    homepage = "https://github.com/TLMS/documentation";
  };
}
