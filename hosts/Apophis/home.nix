{
  pkgs,
  lib,
  username,
  config,
  host,
  ...
}:
let
  inherit (import ./variables.nix) gitUsername gitEmail;
  myAliases = import ../../config/myAliases.txt;

  scriptContent = builtins.readFile ../../config/scripts.sh;
  scriptFile = pkgs.writeText "shell-functions.sh" scriptContent;

  # Modify this path if necessary to point to the correct location
  scriptDir = ../../config/dotlocalbin;

  # Read the directory contents
  scriptFiles = builtins.attrNames (builtins.readDir scriptDir);

  # Generate the script file entries
  scriptFileEntries = builtins.listToAttrs (map
    (name: {
      name = ".local/bin/${name}";
      value = {
        source = builtins.toPath "${scriptDir}/${name}";
        executable = true;
      };
    })
    scriptFiles);
  nsxiv-fullscreen = pkgs.callPackage ./nsxiv-wrapper.nix {};
  mbsyncExtraConfig = builtins.readFile ../../config/mbsync-config.txt;
in
{
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "23.11";

  # Import Program Configurations
  imports = [
    ../../config/emoji.nix
    ../../config/fastfetch
    ../../config/hyprland.nix
    ../../config/yt-dlp.nix
    ../../config/neovim.nix
    ../../config/tmux_new.nix
    ../../config/qutebrowser.nix
    ../../config/hn.nix
    ../../config/empty-dirs.nix
    ../../config/yazi.nix
    ../../config/plotbtc.nix
    ../../config/nostrudel.nix
    ../../config/rofi/rofi.nix
    ../../config/rofi/config-emoji.nix
    ../../config/rofi/config-long.nix
    ../../config/swaync.nix
    ../../config/waybar.nix
    ../../config/wlogout.nix
    ../../config/fastfetch
  ];

  # Place Files Inside Home Directory
  home.file = scriptFileEntries // {
    ".ssh/config".source = ../../config/ssh_config;
    "Pictures/Wallpapers" = {
      source = ../../config/wallpapers;
      recursive = true;
    };
    ".config/wlogout/icons" = {
      source = ../../config/wlogout;
      recursive = true;
    };
    ".face.icon".source = ../../config/face.jpg;
    ".config/face.jpg".source = ../../config/face.jpg;
    ".config/swappy/config".text = ''
      [Default]
      save_dir=/home/${username}/Pictures/Screenshots
      save_filename_format=swappy-%Y%m%d-%H%M%S.png
      show_panel=false
      line_size=5
      text_size=20
      text_font=Ubuntu
      paint_mode=brush
      early_exit=true
      fill_shape=false
    '';
  ".ollama/config".text = ''
    {
      "gpu": true
    }
  '';
  # hyprland calls this on startup:
    ".local/bin/restart-nextcloud-client.sh" = {
      text = ''
        #!/bin/sh
        sleep 30
        systemctl --user restart nextcloud-client.service
      '';
      executable = true;
    };
  };



  services.udiskie.enable = true;
  services.udiskie.tray = "always";

  # Ensure the ~/.config/Yubico directory exists
  home.activation = {
    createYubicoConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG /home/${username}/.config/Yubico
    '';
  };

  # Install & Configure Git
  programs.git = {
    enable = true;
    userName = "${gitUsername}";
    userEmail = "${gitEmail}";
  };

  programs.mbsync = {
    enable = true;
    extraConfig = mbsyncExtraConfig;
  };

  # Create XDG Dirs
  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html"=["qutebrowser.desktop"];
      "x-scheme-handler/http"=["qutebrowser.desktop"];
      "x-scheme-handler/https"=["qutebrowser.desktop"];
      "x-scheme-handler/about"=["qutebrowser.desktop"];
      "x-scheme-handler/unknown"=["qutebrowser.desktop"];
      "text/x-shellscript"=["nvim.desktop"];
      "text/x-script.python"=["nvim.desktop"];
      "application/pdf"=["org.pwmt.zathura-pdf-mupdf.desktop"];
      "application/epub+zip"=["org.pwmt.zathura-pdf-mupdf.desktop"];
      "image/jpeg"=["nsxiv-fullscreen.desktop"];
      "image/png"=["nsxiv-fullscreen.desktop"];
      "text/plain" = ["nvim.desktop"];
      "text/markdown" = ["nvim.desktop"];
      "text/x-python" = ["nvim.desktop"];
      # Add more text-based MIME types as needed
    };
  };
  xdg.desktopEntries.nsxiv-fullscreen = {
    name = "NSXIV Fullscreen";
    genericName = "Image Viewer";
    exec = "${nsxiv-fullscreen}/bin/nsxiv-fullscreen %F";
    icon = "nsxiv";
    terminal = false;
    categories = [ "Graphics" "Viewer" ];
    mimeType = [ "image/bmp" "image/gif" "image/jpeg" "image/jpg" "image/png" "image/tiff" "image/x-bmp" "image/x-portable-anymap" "image/x-portable-bitmap" "image/x-portable-graymap" "image/x-tga" "image/x-xpixmap" ];
  };
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    comment = "Edit text files";
    exec = "nvim %F";
    icon = "nvim";
    mimeType = [
      "text/english"
      "text/x-makefile"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-java"
      "text/x-moc"
      "text/x-pascal"
      "text/x-tcl"
      "text/x-tex"
      "application/x-shellscript"
      "text/x-c"
      "text/x-c++"
      "text/plain"
      "text/x-markdown"
      "text/x-python"
      # Add more MIME types as needed
    ];
    categories = [ "Utility" "TextEditor" ];
    terminal = true;
    type = "Application";
  };

  xdg.configFile = {
    "mpv/mpv.conf" = {
      text = ''
fs=yes
sid=1
sub-auto=fuzzy
sub-file-paths=subtitles
save-position-on-quit
      '';
    };
    "sc-im/scimrc" = {
      text = ''
set autocalc
set numeric
set numeric_decimal=0
set overlap
set xlsx_readformulas
set ignorecase=1

nnoremap "<LEFT>" "fh"
nnoremap "<RIGHT>" "fl"
nnoremap "<UP>" "fk"
nnoremap "<DOWN>" "fj"
nnoremap "<C-e>" ":cellcolor A0 \"reverse=1 bold=1\"<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>"
nnoremap "K" ":nextsheet <CR>"
nnoremap "J" ":prevsheet <CR>"
nnoremap "/" ":go into\"\"<LEFT>" 

REDEFINE_COLOR "WHITE" 248 248 242
REDEFINE_COLOR "MAGENTA" 255 128 191
#DEFINE_COLOR "comment" 121 112 169
#DEFINE_COLOR "altbackground" 63 63 63
      '';
    };
    "newsboat/urls" = {
      source = ../../config/urls_newsboat;  # Path to your existing CSS file
      target = "newsboat/urls";
    };

    "newsboat/config" = {
      text = ''
show-read-feeds yes
#auto-reload yes

external-url-viewer "urlscan -dc -r 'linkhandler {}'"

proxy-type socks5
proxy 127.0.0.1:20170
use-proxy no

confirm-mark-feed-read no

bind-key j down
bind-key k up
bind-key j next articlelist
bind-key k prev articlelist
bind-key J next-feed articlelist
bind-key K prev-feed articlelist
bind-key G end
bind-key g home
bind-key d pagedown
bind-key u pageup
bind-key l open
bind-key h quit
bind-key a toggle-article-read
bind-key n next-unread
bind-key N prev-unread
bind-key D pb-download
bind-key U show-urls
bind-key x pb-delete

color listnormal cyan default
color listfocus black yellow standout bold
color listnormal_unread blue default
color listfocus_unread yellow default bold
color info red black bold
color article white default bold

browser linkhandler
macro , open-in-browser
macro t set browser "qndl" ; open-in-browser ; set browser linkhandler
macro a set browser "tsp youtube-dl --add-metadata -xic -f bestaudio/best" ; open-in-browser ; set browser linkhandler
macro v set browser "setsid -f mpv" ; open-in-browser ; set browser linkhandler
macro w set browser "lynx" ; open-in-browser ; set browser linkhandler
macro d set browser "dmenuhandler" ; open-in-browser ; set browser linkhandler
macro c set browser "echo %u | xclip -r -sel c" ; open-in-browser ; set browser linkhandler
macro C set browser "youtube-viewer --comments=%u" ; open-in-browser ; set browser linkhandler
macro p set browser "peertubetorrent %u 480" ; open-in-browser ; set browser linkhandler
macro P set browser "peertubetorrent %u 1080" ; open-in-browser ; set browser linkhandler

highlight all "---.*---" yellow
highlight feedlist ".*(0/0))" black
highlight article "(^Feed:.*|^Title:.*|^Author:.*)" cyan default bold
highlight article "(^Link:.*|^Date:.*)" default default
highlight article "https?://[^ ]+" green default
highlight article "^(Title):.*$" blue default
highlight article "\\[[0-9][0-9]*\\]" magenta default bold
highlight article "\\[image\\ [0-9]+\\]" green default bold
highlight article "\\[embedded flash: [0-9][0-9]*\\]" green default bold
highlight article ":.*\\(link\\)$" cyan default
highlight article ":.*\\(image\\)$" blue default
highlight article ":.*\\(embedded flash\\)$" magenta default
      '';
    };
  };
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  # Styling Options
  stylix.targets.yazi.enable = true;
  stylix.targets.waybar.enable = false;
  stylix.targets.rofi.enable = false;
  stylix.targets.hyprland.enable = false;
  stylix.targets.tmux.enable = true;
  gtk = {
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
    platformTheme.name = "gtk3";
  };


  # Scripts
  home.packages = with pkgs; [
    (import ../../scripts/emopicker9000.nix { inherit pkgs; })
    (import ../../scripts/task-waybar.nix { inherit pkgs; })
    (import ../../scripts/squirtle.nix { inherit pkgs; })
    (import ../../scripts/nvidia-offload.nix { inherit pkgs; })
    (import ../../scripts/wallsetter.nix {
      inherit pkgs;
      inherit username;
    })
    (import ../../scripts/web-search.nix { inherit pkgs; })
    (import ../../scripts/rofi-launcher.nix { inherit pkgs; })
    (import ../../scripts/screenshootin.nix { inherit pkgs; })
    (import ../../scripts/list-hypr-bindings.nix {
      inherit pkgs;
      inherit host;
    })
    nsxiv
    nsxiv-fullscreen
    zsh-completions
  ];

  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
          };
        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };


  # Optional: Configure Nextcloud client (let hyprland start it up)
  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  home.sessionVariables = {
    PATH = "$HOME/.local/bin:$PATH";
    DISABLE_AUTO_TITLE = "true";
    SUDO_EDITOR = "${pkgs.neovim}/bin/nvim";
    #EDITOR = "${pkgs.neovim}/bin/nvim";
    VISUAL = "${pkgs.neovim}/bin/nvim";
    PDFVIEWER = "${pkgs.zathura}/bin/zathura";
    TERMINAL = "${pkgs.kitty}/bin/kitty";
    TERMINAL_PROG = "${pkgs.kitty}/bin/kitty";
    DEFAULT_BROWSER = "${pkgs.qutebrowser}/bin/qutebrowser";
    BROWSER = "${pkgs.qutebrowser}/bin/qutebrowser";
    HISTSIZE = 1000000;
    SAVEHIST = 1000000;
    SYSTEMD_PAGER = "${pkgs.neovim}/bin/nvim";
    BAT_THEME = "Monokai Extended Origin";
  };

  programs = {
    zoxide.enable = true;
    gh.enable = true;
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
      defaultOptions = [
        "--margin=15%"
        "--border=rounded"
        "--bind=ctrl-j:down,ctrl-k:up"
      ];
      fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
      fileWidgetOptions = ["--preview" "'bat -n --color=always --line-range :500 {}'"];
      changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
      changeDirWidgetOptions = ["--preview" "'eza --tree --color=always {} | head -200'"];
    };
    kitty = {
      enable = true;
      package = pkgs.kitty;
      settings = {
        scrollback_lines = 2000;
        wheel_scroll_min_lines = 1;
        window_padding_width = 4;
        confirm_os_window_close = 0;
        # background_opacity = lib.mkForce "0.85";
      };
      extraConfig = ''
        font_size 22.0
        tab_bar_style fade
        tab_fade 1
        active_tab_font_style   bold
        inactive_tab_font_style bold
        map alt+u open_url_with_hints
      '';
    };
     oh-my-posh = {
            enable = true;
            useTheme = "illusi0n";
            package = pkgs.oh-my-posh;
            enableZshIntegration = true;
     };
     # starship = {
     #        enable = true;
     #        package = pkgs.starship;
     # };
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      shellAliases = myAliases;
      oh-my-zsh = {
        enable = true;
        plugins = ["git"];
        #this theme is overridden by oh-my-posh, just leaving it here in case you remove oh-my-posh
        theme = "agnoster";
      };
      initExtra = ''
         if [ -f "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" ]; then
           . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
         fi
         source ${scriptFile}
         # Add zsh-completions to fpath
         fpath+=${pkgs.zsh-completions}/share/zsh/site-functions
         # PROMPT=" ◉ %U%F{magenta}%n%f%u@%U%F{blue}%m%f%u:%F{yellow}%~%f %F{green}→%f "
         bindkey -r '^l'
         bindkey -r '^g'
         bindkey -s '^G' $'clear\r'
         eval "$(fzf --zsh)"
         # bindkey '^J' down-line-or-history
         # bindkey '^K' up-line-or-history
      '';
    };
    bash = {
      enable = true;
      enableCompletion = true;
      profileExtra = ''
        #if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        #  exec Hyprland
        #fi
      '';
      initExtra = ''
        fastfetch
        if [ -f $HOME/.bashrc-personal ]; then
          source $HOME/.bashrc-personal
        fi
      '';
      shellAliases = {
        fr = "nh os switch --hostname ${host} /home/${username}/zaneyos";
        fu = "nh os switch --hostname ${host} --update /home/${username}/zaneyos";
        zu = "sh <(curl -L https://gitlab.com/Zaney/zaneyos/-/raw/main/install-zaneyos.sh)";
        ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
        v = "nvim";
        cat = "bat";
        ls = "eza --icons";
        ll = "eza -lh --icons --grid --group-directories-first";
        la = "eza -lah --icons --grid --group-directories-first";
        ".." = "cd ..";
      };
    };
    home-manager.enable = true;
    hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 10;
          hide_cursor = true;
          no_fade_in = false;
        };
        background = [
          {
            path = "/home/${username}/Pictures/Wallpapers/0001.jpg";
            blur_passes = 3;
            blur_size = 8;
          }
        ];
        image = [
          {
            path = "/home/${username}/.config/face.jpg";
            size = 350;
            border_size = 4;
            border_color = "rgb(0C96F9)";
            rounding = -1; # Negative means circle
            position = "0, 200";
            halign = "center";
            valign = "center";
          }
        ];
        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(CFE6F4)";
            inner_color = "rgb(657DC2)";
            outer_color = "rgb(0D0E15)";
            outline_thickness = 5;
            placeholder_text = "Password...";
            shadow_passes = 2;
          }
        ];
      };
    };
  };
}
