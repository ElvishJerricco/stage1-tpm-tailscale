{ config, utils, ... }: let
in {
  boot.initrd = {
    systemd.services.zfs-import-pyromancer.enable = false; # Disable NixOS ZFS support

    systemd.services.import-pyromancer-bare = let
      nvme = "${utils.escapeSystemdPath "/dev/disk/by-id/nvme-Samsung_SSD_960_PRO_1TB_S3EVNX0J801579F-part2"}.device";
    in {
      requiredBy = ["pyromancer-load-key.service"];
      after = [nvme];
      bindsTo = [nvme];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${config.boot.zfs.package}/bin/zpool import -f -N -d /dev/disk/by-id pyromancer";
        RemainAfterExit = true;
      };
    };

    systemd.services.pyromancer-load-key = {
      wantedBy = ["sysroot.mount"];
      before = ["sysroot.mount"];
      unitConfig = {
        RequiresMountsFor = "/keybag";
        DefaultDependencies = false;
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${config.boot.zfs.package}/bin/zfs load-key -L file:///keybag/pyromancer pyromancer/crypt";
        RemainAfterExit = true;
      };
    };
  };
}
