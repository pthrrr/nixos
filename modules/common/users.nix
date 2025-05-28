{ config, pkgs, ... }:
{
  users.users.pthr = {
    isNormalUser = true;
    description = "pthr";
    extraGroups = [ "networkmanager" "wheel" ];

    # user specific packages
    packages = with pkgs; [
    ];
  };
}
