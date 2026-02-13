{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    helix
    btop
    git
    python315
    tree
    neofetch
    
    cups
    cups-filters            # Important for PDF rendering
    ghostscript           # PostScript/PDF interpreter
    system-config-printer  # GUI tool for printer management

    # gstreamer
    # Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
    gst_all_1.gstreamer
    # Common plugins like "filesrc" to combine within e.g. gst-launch
    gst_all_1.gst-plugins-base
    # Specialized plugins separated by quality
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    # Plugins to reuse ffmpeg to play almost every video format
    gst_all_1.gst-libav
    # Support the Video Audio (Hardware) Acceleration API
    gst_all_1.gst-vaapi
  ];

  # Disable XTerm
  services.xserver.excludePackages = with pkgs; [ 
    xterm 
  ];
}
