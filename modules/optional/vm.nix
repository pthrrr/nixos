{ config, pkgs, ... }:

{
  # Enable virtualization
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };
      };
    };
  };

  # Add your user to libvirtd group
  users.users.pthr = {
    extraGroups = [ "libvirtd" "kvm" ];
  };

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    qemu
    OVMF
    swtpm
  ];

  # Enable USB redirection and additional permissions
  security.polkit.enable = true;
  
  # Optional: Enable KVM kernel module
  boot.kernelModules = [ "kvm-intel" "kvm-amd" "vfio-virqfd" ];
  
  # Optional: Improve performance
  boot.kernel.sysctl = {
    "vm.nr_hugepages" = 1024;
  };
}
