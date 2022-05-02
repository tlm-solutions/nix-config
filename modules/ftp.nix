{pkgs, lib, ...} : {

  services = {
    vsftpd = {
      enable = true;
      localUsers = false;
      localRoot = "/var/lib/data-accumulator";
    };
  };

}
