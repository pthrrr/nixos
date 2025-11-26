{ config, pkgs, ... }:

{
  # Enable virtualization
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;  # TPM support for Windows 11
      };
    };
    spiceUSBRedirection.enable = true;  # Enable USB redirection
  };

  # Add your user to necessary groups
  users.users.pthr.extraGroups = [ "libvirtd" "kvm" ];

  # Install VM management tools
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    usbredir  # Required for USB redirection
    virtio-win
    win-spice
  ];

  # Enable polkit for USB access permissions
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if (action.id == "org.libvirt.unix.manage" &&
            subject.isInGroup("libvirtd")) {
                return polkit.Result.YES;
        }
    });
  '';

  # Enable SPICE guest agent service
  services.spice-vdagentd.enable = true;
}
