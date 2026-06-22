{ config, pkgs, lib, ... }:

let
  stripNL   = s: builtins.replaceStrings ["\n"] [""] s;
  username1 = stripNL (builtins.readFile config.age.secrets.username1.path);
  username2 = stripNL (builtins.readFile config.age.secrets.username2.path);
in
{
  # secrets
  age.secrets.username1.file = ../../secrets/username1.age;
  age.secrets.username2.file = ../../secrets/username2.age;

  age.secrets.password1 = { file = ../../secrets/password1.age; owner = "media"; mode = "0400"; };
  age.secrets.password2 = { file = ../../secrets/password2.age; owner = "media"; mode = "0400"; };

  # cache directories (history + thumbnails)
  systemd.tmpfiles.rules = [
    "d /var/lib/media/copyparty       0750 media media -"
    "d /var/lib/media/copyparty/hist  0750 media media -"
  ];

  # Copyparty service
  services.copyparty = {
    enable = true;

    # Run as media user
    user = "media";
    group = "media";

    settings = {
      # --- Netzwerk ---
      i = "0.0.0.0";
      p = 3210;
      # j = 1;             # CPU-Kerne für uploads/downloads (0=alle, default: 1)
      # s-tbody = 60;      # socket timeout body (default: 128, 60 für schnelle Server)
      iobuf = 524288;       # I/O buffer-size (default: 262144, höher für ZFS)
      no-reload = true;

      # --- Datenbank & Indexing ---
      hist = "/var/lib/media/copyparty/hist";
      # dbpath = "";        # DB separat von hist ablegen (default: wie hist)
      e2d = true;           # dedup database / file search / upload-undo
      # e2ds = true;        # scan writable folders beim Start (setzt e2d)
      # e2dsa = true;       # scan ALLE folders beim Start (setzt e2ds)
      hash-mt = 4;          # multi-threaded hashing (default: numCores wenn ≤5)
      # dbd = "wal";        # DB durability profile (default: wal)
      # db-act = 10;        # reindex erst N sek nach letztem DB-write (default: 10)
      # re-maxage = 0;      # rescan filesystem alle N sek (0=aus, default: 0)
      # no-dirsz = false;   # ordnergrößen nicht rekursiv berechnen (default: false)
      # srch-time = 45;     # search deadline in sek (default: 45)
      # srch-hits = 7999;   # max search results (default: 7999)

      # --- Metadata / Tags ---
      e2t = true;           # multimedia metadata index
      e2ts = true;          # scan neue Dateien für metadata beim Start
      e2tsr = true;         # full metadata rescan beim Start
      # mtag-to = 60;       # FFprobe tag-scan timeout in sek (default: 60)
      # mtag-mt = 4;        # CPU-Kerne für tag scanning (default: numCores)

      # --- Thumbnails ---
      th-size = "192x154";  # thumbnail-Auflösung (default: 320x256)
      th-mt = 2;            # parallele Thumbnail-Worker (default: numCores)
      # th-crop = "y";      # thumbnails auf 4:3 croppen (default: y)
      # th-qv = 40;         # webp/jpg thumbnail quality 10-90 (default: 40)
      # th-qvx = 64;        # jxl thumbnail quality 10-90 (default: 64)
      # th-convt = 60;      # bild-convert timeout in sek (default: 60)
      # ac-convt = 150;     # audio-convert timeout in sek (default: 150)
      # th-clean = 43200;   # thumbnail cleanup interval in sek (default: 43200 = 12h)
      # th-maxage = 604800; # max thumbnail alter in sek (default: 604800 = 7d)
      # no-vthumb = false;  # video thumbnails deaktivieren
      # no-athumb = false;  # audio spectrograms deaktivieren

      # --- Uploads ---
      # unpost = 43200;     # upload-undo Zeitfenster in sek (default: 43200 = 12h)
      # u2ts = "c";         # timestamps: c=client-mtime, u=upload-time (default: c)
      df = 50;              # min. freier Speicher in GiB, Uploads ablehnen (ZFS braucht Luft)
      # snap-wri = 300;     # upload-state snapshot alle N sek (default: 300)
      # snap-drop = 1440;   # unfertige uploads vergessen nach N min (default: 1440 = 24h)
      # dotpart = false;    # unfertige uploads als dotfiles verstecken
      # dedup = false;      # symlink-basierte dedup (default: false)
      # no-dupe = false;    # duplikate beim upload ablehnen (default: false)
      # magic = false;      # filetype-detection für namenlose uploads (default: false)
      # turbo = 0;          # turbo-mode: 0=default-off, 2=on (default: 0)
      # chmod-f = "";       # unix permissions neue Dateien, z.B. "644" (default: OS)
      # chmod-d = "755";    # unix permissions neue Ordner (default: 755)

      # --- Protokolle (alle default: aus) ---
      # ftp = 0;            # FTP server port (z.B. 3921)
      # sftp = 0;           # SFTP server port (z.B. 3922)
      # smb = false;        # SMB server (unsicher, nicht empfohlen)
      # daw = false;        # WebDAV full write support

      # --- Sicherheit ---
      # usernames = false;  # username + passwort statt nur passwort (default: false)
      # ban-pw = "9,3600,86400"; # pw-bruteforce: N fails in M sek → ban für S sek

      # --- Logging ---
      # q = "";             # quiet: weniger log-output
      # lo = "";            # log to file (path)

      # --- Sonstiges ---
      # rss = false;        # RSS feeds aktivieren (default: false)
      # cachectl = "no-cache"; # Cache-Control header (default: no-cache)
    };

    accounts.${username1}.passwordFile = config.age.secrets.password1.path;
    accounts.${username2}.passwordFile = config.age.secrets.password2.path;

    volumes = {
      # Main user directories
      "/${username1}" = {
        path   = "/data/users/${username1}";
        access = { A = username1; };
      };

      "/${username2}" = {
        path   = "/data/users/${username2}";
        access = { 
          rwmd = username2;
          rA = username1;
        };
      };

      # Photo directories
      "/${username1}-photos" = {
        path   = "/data/fotos/${username1}";
        access = { A = username1; };
      };

      "/${username2}-photos" = {
        path   = "/data/fotos/${username2}";
        access = { 
          rwmd = username2;
          rA = username1;
        };
      };

      "/papa-photos" = {
        path   = "/data/fotos/papa";
        access = { A = username1; };
      };

      # papa data
      "/papa" = {
        path   = "/data/users/papa";
        access = { A = username1; };
      };
    };

    openFilesLimit = 8192;
  };

  # Fix file permissions for group collaboration + add ffmpeg for video transcoding
  systemd.services.copyparty = {
    path = [ pkgs.ffmpeg-headless ];
    serviceConfig = {
      UMask = lib.mkForce "0002";  # Creates files as 644 instead of 600
    };
  };
}
