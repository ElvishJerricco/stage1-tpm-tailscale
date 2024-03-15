{ config, pkgs, ... }: {
  boot.initrd = {
    systemd.enable = true;
    kernelModules = ["tpm_crb"];
    availableKernelModules = ["ext4" "igb"];
    systemd.emergencyAccess = config.users.users.root.hashedPassword;
    systemd.network = config.systemd.network;
    network.ssh = {
      enable = true;
      ignoreEmptyHostKeys = true;
    };
    systemd.contents = {
      "/etc/fstab".text = ''
        /dev/mapper/tpm2bag /tpm2bag ext4 defaults 0 2
        /tpm2bag/var/lib/tailscale /var/lib/tailscale none bind,x-systemd.requires-mounts-for=/tpm2bag/var/lib/tailscale
        # nofail so it doesn't order before local-fs.target and therefore systemd-tmpfiles-setup
        /dev/mapper/keybag /keybag ext4 defaults,nofail,x-systemd.device-timeout=0,ro 0 2
      '';
      "/etc/tmpfiles.d/50-ssh-host-keys.conf".text = ''
        C /etc/ssh/ssh_host_ed25519_key 0600 - - - /tpm2bag/etc/ssh/ssh_host_ed25519_key
        C /etc/ssh/ssh_host_rsa_key 0600 - - - /tpm2bag/etc/ssh/ssh_host_rsa_key
      '';
    };
    systemd.services.systemd-tmpfiles-setup.before = ["sshd.service"];
    luks.devices.keybag = {
      device = "/dev/disk/by-uuid/4d518c17-da13-49a0-a003-ec183f36b03c";
      crypttabExtraOpts = ["tpm2-device=auto" "nofail"];
    };
    luks.devices.tpm2bag = {
      device = "/dev/disk/by-uuid/71667743-d8fe-49ad-ad86-3809351607f0";
      crypttabExtraOpts = ["tpm2-device=auto"];
    };
  };

  environment.systemPackages = [pkgs.sbctl];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
}
