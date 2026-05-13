# Virtual 7.1 surround via HRTF spatializer for headphones
# Uses PipeWire's native SOFA-based spatializer with the ARI HRTF dataset
# Creates a "Spatial Sink" that games/apps can output to for directional audio
{ pkgs, ... }:

let
  # ARI (Acoustics Research Institute, Austrian Academy of Sciences) HRTF dataset
  # Subject NH724 - commonly used reference, same as PipeWire's example config
  hrtfSofa = pkgs.fetchurl {
    name = "hrtf-b-nh724.sofa";
    url = "https://sofacoustics.org/data/database/ari/hrtf%20b_nh724.sofa";
    sha256 = "146kcmbmq2r5237bl0kwmr0k914gw5dp6gnixb95bqg6pnr11f92";
  };
in
{
  # Use configPackages to write raw SPA-JSON (PipeWire uses dotted keys,
  # not nested JSON objects — extraConfig.pipewire serializes incorrectly)
  services.pipewire.configPackages = [
    (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/99-spatial-sink.conf" ''
      context.modules = [
        { name = libpipewire-module-filter-chain
          flags = [ nofail ]
          args = {
            node.description = "Spatial Sink (HRTF 7.1)"
            media.name       = "Spatial Sink (HRTF 7.1)"
            filter.graph = {
              nodes = [
                # Front Left (30° left)
                {
                  type  = sofa
                  label = spatializer
                  name  = spFL
                  config = {
                    filename = "${hrtfSofa}"
                    gain     = 0.5
                  }
                  control = {
                    Azimuth   = 30.0
                    Elevation = 0.0
                    Radius    = 3.0
                  }
                }
                # Front Right (30° right)
                {
                  type  = sofa
                  label = spatializer
                  name  = spFR
                  config = {
                    filename = "${hrtfSofa}"
                    gain     = 0.5
                  }
                  control = {
                    Azimuth   = 330.0
                    Elevation = 0.0
                    Radius    = 3.0
                  }
                }
                # Front Center
                {
                  type  = sofa
                  label = spatializer
                  name  = spFC
                  config = {
                    filename = "${hrtfSofa}"
                    gain     = 0.5
                  }
                  control = {
                    Azimuth   = 0.0
                    Elevation = 0.0
                    Radius    = 3.0
                  }
                }
                # Rear Left (150°)
                {
                  type  = sofa
                  label = spatializer
                  name  = spRL
                  config = {
                    filename = "${hrtfSofa}"
                    gain     = 0.5
                  }
                  control = {
                    Azimuth   = 150.0
                    Elevation = 0.0
                    Radius    = 3.0
                  }
                }
                # Rear Right (210°)
                {
                  type  = sofa
                  label = spatializer
                  name  = spRR
                  config = {
                    filename = "${hrtfSofa}"
                    gain     = 0.5
                  }
                  control = {
                    Azimuth   = 210.0
                    Elevation = 0.0
                    Radius    = 3.0
                  }
                }
                # Side Left (90°)
                {
                  type  = sofa
                  label = spatializer
                  name  = spSL
                  config = {
                    filename = "${hrtfSofa}"
                    gain     = 0.5
                  }
                  control = {
                    Azimuth   = 90.0
                    Elevation = 0.0
                    Radius    = 3.0
                  }
                }
                # Side Right (270°)
                {
                  type  = sofa
                  label = spatializer
                  name  = spSR
                  config = {
                    filename = "${hrtfSofa}"
                    gain     = 0.5
                  }
                  control = {
                    Azimuth   = 270.0
                    Elevation = 0.0
                    Radius    = 3.0
                  }
                }
                # LFE (subwoofer, below listener)
                {
                  type  = sofa
                  label = spatializer
                  name  = spLFE
                  config = {
                    filename = "${hrtfSofa}"
                    gain     = 0.5
                  }
                  control = {
                    Azimuth   = 0.0
                    Elevation = -60.0
                    Radius    = 3.0
                  }
                }
                # Mixers for final L/R output
                { type = builtin  label = mixer  name = mixL }
                { type = builtin  label = mixer  name = mixR }
              ]
              links = [
                { output = "spFL:Out L"   input = "mixL:In 1" }
                { output = "spFL:Out R"   input = "mixR:In 1" }
                { output = "spFR:Out L"   input = "mixL:In 2" }
                { output = "spFR:Out R"   input = "mixR:In 2" }
                { output = "spFC:Out L"   input = "mixL:In 3" }
                { output = "spFC:Out R"   input = "mixR:In 3" }
                { output = "spRL:Out L"   input = "mixL:In 4" }
                { output = "spRL:Out R"   input = "mixR:In 4" }
                { output = "spRR:Out L"   input = "mixL:In 5" }
                { output = "spRR:Out R"   input = "mixR:In 5" }
                { output = "spSL:Out L"   input = "mixL:In 6" }
                { output = "spSL:Out R"   input = "mixR:In 6" }
                { output = "spSR:Out L"   input = "mixL:In 7" }
                { output = "spSR:Out R"   input = "mixR:In 7" }
                { output = "spLFE:Out L"  input = "mixL:In 8" }
                { output = "spLFE:Out R"  input = "mixR:In 8" }
              ]
              inputs  = [ "spFL:In" "spFR:In" "spFC:In" "spLFE:In" "spRL:In" "spRR:In" "spSL:In" "spSR:In" ]
              outputs = [ "mixL:Out" "mixR:Out" ]
            }
            capture.props = {
              node.name      = "effect_input.spatial-sink"
              media.class    = Audio/Sink
              audio.channels = 8
              audio.position = [ FL FR FC LFE RL RR SL SR ]
            }
            playback.props = {
              node.name      = "effect_output.spatial-sink"
              node.passive   = true
              audio.channels = 2
              audio.position = [ FL FR ]
            }
          }
        }
      ]
    '')
  ];
}
