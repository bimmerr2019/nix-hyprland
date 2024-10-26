{ config, lib, pkgs, ... }:

let
  yaziGlow = pkgs.fetchFromGitHub {
    owner = "Reledia";
    repo = "glow.yazi";
    rev = "master";  # You might want to pin this to a specific commit or tag for stability
    sha256 = "sha256-bqaFqjlQ/VgMdt2VVjEI8cIkA9THjOZDgNspNicxlbc=";  # Replace this with the actual hash
  };
  yaziHexyl = pkgs.fetchFromGitHub {
    owner = "Reledia";
    repo = "hexyl.yazi";
    rev = "master";  # You might want to pin this to a specific commit or tag for stability
    sha256 = "sha256-9rPJcgMYtSY5lYnFQp3bAhaOBdNUkBaN1uMrjen6Z8g=";  # Replace this with the actual hash
  };
  yaziMiller = pkgs.fetchFromGitHub {
    owner = "Reledia";
    repo = "miller.yazi";
    rev = "master";  # You might want to pin this to a specific commit or tag for stability
    sha256 = "sha256-GXZZ/vI52rSw573hoMmspnuzFoBXDLcA0fqjF76CdnY=";  # Replace this with the actual hash
  };
  smartEnterPlugin = pkgs.writeTextFile {
    name = "smart-enter.yazi";
    destination = "/init.lua";
    text = ''
      return {
        entry = function()
          local h = cx.active.current.hovered
          ya.manager_emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
        end,
      }
    '';
  };
in
{
  home.packages = with pkgs; [
    zoxide
    yazi
    ffmpegthumbnailer
    jq
    poppler
    fzf
    imagemagick
    wl-clipboard
    glow
    hexyl
    miller
    sc-im
  ];

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    plugins = {
      glow = yaziGlow;
      hexyl = yaziHexyl;
      miller = yaziMiller;
      "smart-enter" = smartEnterPlugin;
    };
    settings = {
      manager = {
        ratio = [ 1 4 3 ];
        sort_by = "alphabetical";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = false;
        linemode = "mtime";
        show_hidden = true;
        show_symlink = true;
      };
      preview = {
        tab_size = 2;
        max_width = 600;
        max_height = 900;
        cache_dir = "";
        image_filter = "triangle";
        image_quality = 75;
        sixel_fraction = 15;
        ueberzug_scale = 1;
        ueberzug_offset = [ 0 0 0 0 ];
      };
      opener = {
        edit = [
          { run = "$EDITOR \"$@\""; block = true; for = "unix"; }
          { run = "code \"%*\""; orphan = true; for = "windows"; }
        ];
        spread = [
          { run = "sc-im \"$@\""; block = true; for = "unix"; }
          { run = "code \"%*\""; orphan = true; for = "windows"; }
        ];
        open = [
          { run = "xdg-open \"$@\""; desc = "Open"; for = "linux"; }
          { run = "open \"$@\""; desc = "Open"; for = "macos"; }
          { run = "start \"\" \"%1\""; orphan = true; desc = "Open"; for = "windows"; }
        ];
        reveal = [
          { run = "open -R \"$1\""; desc = "Reveal"; for = "macos"; }
          { run = "explorer /select, \"%1\""; orphan = true; desc = "Reveal"; for = "windows"; }
          { run = ''exiv2 "$1"; echo "Press enter to exit"; read''; block = true; desc = "Show EXIF"; for = "unix"; }
        ];
        extract = [
          { run = "unar \"$1\""; desc = "Extract here"; for = "unix"; }
          { run = "unar \"%1\""; desc = "Extract here"; for = "windows"; }
        ];
        play = [
          { run = "mpv \"$@\""; orphan = true; for = "unix"; }
          { run = "mpv \"%1\""; orphan = true; for = "windows"; }
          { run = ''mediainfo "$1"; echo "Press enter to exit"; read''; block = true; desc = "Show media info"; for = "unix"; }
        ];
      };
      open = {
        rules = [
          { name = "*/"; use = [ "edit" "open" "reveal" ]; }
          { mime = "text/*"; use = [ "edit" "reveal" ]; }
          { mime = "image/*"; use = [ "open" "reveal" ]; }
          { mime = "video/*"; use = [ "play" "reveal" ]; }
          { mime = "audio/*"; use = [ "play" "reveal" ]; }
          { mime = "inode/x-empty"; use = [ "edit" "reveal" ]; }
          { mime = "application/json"; use = [ "edit" "reveal" ]; }
          { mime = "*/javascript"; use = [ "edit" "reveal" ]; }
          { mime = "application/zip"; use = [ "extract" "reveal" ]; }
          { mime = "application/gzip"; use = [ "extract" "reveal" ]; }
          { mime = "application/x-tar"; use = [ "extract" "reveal" ]; }
          { mime = "application/x-bzip"; use = [ "extract" "reveal" ]; }
          { mime = "application/x-bzip2"; use = [ "extract" "reveal" ]; }
          { mime = "application/x-7z-compressed"; use = [ "extract" "reveal" ]; }
          { mime = "application/x-rar"; use = [ "extract" "reveal" ]; }
          { mime = "application/xz"; use = [ "extract" "reveal" ]; }
          { mime = "application/x-sc"; use = [ "spread" "reveal" ]; }
          { mime = "*"; use = [ "open" "reveal" ]; }
        ];
      };
      tasks = {
        micro_workers = 10;
        macro_workers = 25;
        bizarre_retry = 5;
        image_alloc = 536870912;  # 512MB
        image_bound = [ 0 0 ];
        suppress_preload = false;
      };
      plugin = {
        preloaders = [
          { mime = "image/vnd.djvu"; run = "noop"; }
          { mime = "image/*"; run = "image"; }
          { mime = "video/*"; run = "video"; }
          { mime = "application/pdf"; run = "pdf"; }
        ];
        previewers = [
          { mime = "text/csv"; run = "miller"; }
          { name = "*.md"; run = "glow"; }
          { name = "*.org"; run = "glow"; }
          { name = "*/"; run = "folder"; sync = true; }
          { mime = "text/*"; run = "code"; }
          { mime = "*/xml"; run = "code"; }
          { mime = "*/javascript"; run = "code"; }
          { mime = "*/x-wine-extension-ini"; run = "code"; }
          { mime = "application/x-sc"; run = "code"; }
          { mime = "application/json"; run = "json"; }
          { mime = "image/vnd.djvu"; run = "noop"; }
          { mime = "image/*"; run = "image"; }
          { mime = "video/*"; run = "video"; }
          { mime = "application/pdf"; run = "pdf"; }
          { mime = "application/zip"; run = "archive"; }
          { mime = "application/gzip"; run = "archive"; }
          { mime = "application/x-tar"; run = "archive"; }
          { mime = "application/x-bzip"; run = "archive"; }
          { mime = "application/x-bzip2"; run = "archive"; }
          { mime = "application/x-7z-compressed"; run = "archive"; }
          { mime = "application/x-rar"; run = "archive"; }
          { mime = "application/xz"; run = "archive"; }
          { name = "*"; run = "hexyl"; }
        ];
      };
      select = {
        open_title = "Open with:";
        open_origin = "hovered";
        open_offset = [ 0 1 50 7 ];
      };
      log = {
        enabled = false;
      };
    };
  };
  # Add this section to link your custom keymap file
  home.file.".config/yazi/keymap.toml".source = ./keymap.toml;
}
