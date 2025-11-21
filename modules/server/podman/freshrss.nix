{ config, pkgs, lib, ... }:
let
  stripNL = s: builtins.replaceStrings ["\n"] [""] s;
  domain = builtins.replaceStrings ["\n"] [""] (builtins.readFile config.age.secrets.domain.path);
  
  # Define your RSS feeds in OPML format
  feedsOpml = pkgs.writeText "feeds.opml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <opml version="2.0">
      <head>
        <title>My RSS Feeds</title>
      </head>
      <body>
        <outline text="Tech News" title="Tech News">
          <outline type="rss" text="Hacker News" title="Hacker News" xmlUrl="https://news.ycombinator.com/rss" htmlUrl="https://news.ycombinator.com/"/>
          <outline type="rss" text="Ars Technica" title="Ars Technica" xmlUrl="https://feeds.arstechnica.com/arstechnica/index" htmlUrl="https://arstechnica.com/"/>
        </outline>
        <outline text="NixOS" title="NixOS">
          <outline type="rss" text="NixOS Discourse" title="NixOS Discourse" xmlUrl="https://discourse.nixos.org/posts.rss" htmlUrl="https://discourse.nixos.org/"/>
        </outline>
      </body>
    </opml>
  '';
in
{
  age.secrets.domain = {
    file = ../../../secrets/domain.age;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    
    containers = {
      freshrss = {
        image = "freshrss/freshrss:latest";
        
        ports = [
          "127.0.0.1:8082:80"
        ];
        
        environment = {
          CRON_MIN = "*/15";
          TZ = "Europe/Berlin";
        };
        
        volumes = [
          "freshrss-data:/var/www/FreshRSS/data"
          "freshrss-extensions:/var/www/FreshRSS/extensions"
          # Mount the OPML file
          "${feedsOpml}:/var/www/FreshRSS/data/feeds.opml:ro"
        ];
        
        extraOptions = [
          "--pull=always"
        ];
      };
    };
  };
}
