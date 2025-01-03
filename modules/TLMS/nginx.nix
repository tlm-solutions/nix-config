{ config, ... }:
let
  headers = ''
    # Permissions Policy - gps only
    add_header Permissions-Policy "geolocation=()";

    # Minimize information leaked to other domains
    add_header 'Referrer-Policy' 'origin-when-cross-origin';

    # Disable embedding as a frame
    add_header X-Frame-Options DENY;

    # Prevent injection of code in other mime types (XSS Attacks)
    add_header X-Content-Type-Options nosniff;

    # Enable XSS protection of the browser.
    # May be unnecessary when CSP is configured properly (see above)
    add_header X-XSS-Protection "1; mode=block";

    # STS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
  '';
in
{
  # Open firewall HTTP and HTTPS if nginx is enabled
  networking.firewall.allowedTCPPorts = if config.services.nginx.enable then [ 80 443 ] else [];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "TLMS@protonmail.com";
  services.nginx = {
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    commonHttpConfig = headers;
  };
}
