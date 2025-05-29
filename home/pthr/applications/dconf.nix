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
          "paperwm@paperwm.github.com"
        ];
      };

      # Configure individual extensions
      "org/gnome/shell/extensions/blur-my-shell" = {
        #brightness = 0.75;
        #noise-amount = 0;
      };

      "/org/gnome/shell/extensions/paperwm" = {
        show-workspace-indicator = true;
        default-focus-mode = 2;
      };
    };
  };
}