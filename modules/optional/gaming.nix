{ config, pkgs, ... }:

{
  # Gaming-related packages
  environment.systemPackages = with pkgs; [
    mangohud
    mangojuice
    vkbasalt
  ];

  # XDG Desktop Portal für Wayland Screen Capture (Steam Remote Play)
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  # Enable Steam services
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;

    package = pkgs.steam.override {
      extraEnv = {
        # Steam Remote Play: PipeWire-basiertes Screen Capture unter Wayland
        STEAM_ENABLE_PIPEWIRE_SCREEN_CAPTURE = "1";

        # Performance Overlay
        MANGOHUD = "1";
        MANGOHUD_CONFIG = "read_cfg,no_display";

        # GameMode Integration
        GAMEMODERUN = "1";

        # DirectX Raytracing via VKD3D-Proton
        VKD3D_CONFIG = "dxr,dxr11";

        # Shader-Caching
        PROTON_LOCAL_SHADER_CACHE = "1";
        DXVK_STATE_CACHE = "1";

        # ntsync replaces esync/fsync with in-kernel NT synchronization
        PROTON_USE_NTSYNC = "1";
        PROTON_NO_ESYNC = "1";
        PROTON_NO_FSYNC = "1";

        # AMD Anti-Lag via Mesa Vulkan layer (reduces input latency)
        ENABLE_LAYER_MESA_ANTI_LAG = "1";

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
    };
  };
}
