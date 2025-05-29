{
  imports = [
    ./applications.nix
    # ./../gaming.nix         is host specifig, imported in hosts/desktop,laptop/configuration.nix
    ./house-keeping.nix
    ./mouse.nix
    ./samba.nix
    ./users.nix
  ];
}