{ config, lib, ... }: {
  TLMS.bureaucrat.log_level = lib.mkForce "debug";
  TLMS.chemo.log_level = lib.mkForce "debug";
  TLMS.datacare.log_level = lib.mkForce "debug";
  TLMS.dataAccumulator.log_level = lib.mkForce "debug";
  TLMS.lizard.logLevel = lib.mkForce "debug";
  TLMS.trekkie.logLevel = lib.mkForce "debug";
}
