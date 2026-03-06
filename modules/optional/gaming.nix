{ config, pkgs, ... }:

{
  # Gaming-related packages
  environment.systemPackages = with pkgs; [
    mangohud
    mangojuice
    vkbasalt
  ];

  # Enable Steam services
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;

    # Steam-Umgebungsvariablen für AMD RX 7700 XT (RDNA3)
    package = pkgs.steam.override {
      extraEnv = {
        # Performance Overlay
        MANGOHUD = "1";
        MANGOHUD_CONFIG = "read_cfg,no_display";

        # GameMode Integration
        GAMEMODERUN = "1";

        # RADV Vulkan-Treiber erzwingen (besser als AMDVLK für Gaming)
        AMD_VULKAN_ICD = "RADV";

        # DirectX Raytracing Unterstützung via VKD3D-Proton
        VKD3D_CONFIG = "dxr,dxr11";

        # FSR optimiert für RDNA3-Architektur
        PROTON_ADD_CONFIG = "fsr4rdna3";

        # Shader-Caching für schnellere Ladezeiten
        PROTON_LOCAL_SHADER_CACHE = "1";
        MESA_SHADER_CACHE_MAX_SIZE = "16G";
        MESA_GLSL_CACHE_MAX_SIZE = "16G";

        # Vulkan-only Rendering in Wine/Proton
        WINE_VK_VULKAN_ONLY = "1";

        # DLL-Overrides für Spielkompatibilität
        WINEDLLOVERRIDES = "dinput8,dxgi,dsound=n,b";
      };
    };
  };

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };
}
