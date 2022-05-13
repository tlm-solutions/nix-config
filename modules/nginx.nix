{ pkgs, config, lib, ... }: {
  security.acme.acceptTerms = true;
  security.acme.email = "dump-dvb@protonmail.com";
  services.nginx = {
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    commonHttpConfig = ''
      # Enable CSP for your services.
      #add_header Content-Security-Policy "script-src 'self'; object-src 'none'; base-uri 'none';" always;

      # Minimize information leaked to other domains
        add_header 'Referrer-Policy' 'origin-when-cross-origin';

      # Disable embedding as a frame
        add_header X-Frame-Options DENY;

      # Prevent injection of code in other mime types (XSS Attacks)
        add_header X-Content-Type-Options nosniff;

      # Enable XSS protection of the browser.
      # May be unnecessary when CSP is configured properly (see above)
        add_header X-XSS-Protection "1; mode=block";
    '';
  };
}
