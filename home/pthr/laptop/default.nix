{ pkgs, config, lib, ... }:

let
  sharedConfig = import ./../home.nix { inherit pkgs config lib; };
in
{
  imports = [ sharedConfig ];

  # Laptop-specific packages
  home.packages = with pkgs; sharedConfig.home.packages ++ [
    # Blender with CUDA + NVIDIA PRIME offload (dGPU for viewport + Cycles)
    (symlinkJoin {
      name = "blender-nvidia";
      paths = [ (blender.override { cudaSupport = true; }) ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/blender \
          --set __NV_PRIME_RENDER_OFFLOAD 1 \
          --set __GLX_VENDOR_LIBRARY_NAME nvidia
      '';
    })
    bitwig-studio5
    arduino
    arduino-ota
    cmatrix
  ];
}
