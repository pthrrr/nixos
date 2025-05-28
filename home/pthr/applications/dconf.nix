{ config, pkgs, ... }:
{
  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false; # enables user extensions
        enabled-extensions = [
          # Put UUIDs of extensions that you want to enable here.
          # If the extension you want to enable is packaged in nixpkgs,
          # you can easily get its UUID by accessing its extensionUuid
          # field (look at the following example).
          #pkgs.gnomeExtensions.gsconnect.extensionUuid
          
          # Alternatively, you can manually pass UUID as a string.  
          "blur-my-shell@aunetx"
          "pop-shell@system76.com"
        ];
      };

      # Configure individual extensions
      "org/gnome/shell/extensions/blur-my-shell" = {
        #brightness = 0.75;
        #noise-amount = 0;
      };

      "org/gnome/shell/extensions/pop-shell" = {
        tile-by-default = true;
        hint-color-rgba = "rgba(126, 186, 228, 1)";
      };
    };
  };
}