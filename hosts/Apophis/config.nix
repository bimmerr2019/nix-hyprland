{
  config,
  pkgs,
  inputs,
  lib,
  host,
  username,
  options,
  ...
}:
let
  inherit (import ./variables.nix) keyboardLayout;
  pythonConfigs = import ../../config/python.nix { inherit pkgs; };
  myPython = pythonConfigs.basePython;
in
{
  imports = [
    ./hardware.nix
    ./users.nix
    ./qtodotxt.nix
    # ../../modules/amd-drivers.nix
    ../../modules/nvidia-drivers.nix
    # ../../modules/nvidia-prime-drivers.nix
    # ../../modules/intel-drivers.nix
    ../../modules/vm-guest-services.nix
    ../../modules/local-hardware-clock.nix
  ];

  boot = {
    # Kernel
    kernelPackages = pkgs.linuxPackages_zen;
    # This is for OBS Virtual Cam Support
    # kernelModules = [ "v4l2loopback" ];
    # extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    # # Needed For Some Steam Games
    # kernel.sysctl = {
    #   "vm.max_map_count" = 2147483642;
    # };
    # Bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    blacklistedKernelModules = [ "nouveau" ];
    # Make /tmp a tmpfs
    # tmp = {
    #   useTmpfs = false;
    #   tmpfsSize = "30%";
    # };
    # Appimage Support
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
    # plymouth.enable = true;
  };

  # LUKS encryption
 # boot.initrd.luks.devices = {
 #   crypted = {
 #     device = "/dev/disk/by-uuid/48781bd8-267a-4417-a4a3-be84bd59ac5b";
 #     preLVM = true;
 #     allowDiscards = true;
 #   };
 # };

#Put appImages in the /opt diretory:
  # Create /opt/appimages directory
  system.activationScripts = {
    createAppImageDir = ''
      mkdir -p /opt/appimages
      chown root:users /opt/appimages
      chmod 775 /opt/appimages
    '';
  };

  # Add this section to set the permissions for the tuigreet cache directory
  system.activationScripts.tuigreet-permissions = ''
    mkdir -p /var/cache/tuigreet
    chmod 777 /var/cache/tuigreet
  '';

  # Styling Options
  stylix = {
    enable = true;
    image = builtins.fetchurl {
      url = "file://${toString ../../config/wallpapers/0169.jpg}";
      sha256 = "sha256:00vm1zblizklx7bvsmmrrzmk7qmgln4xkrgalk6dmdbg8jdsgpjn"; # Leave empty first, Nix will tell you the correct hash
    };
    # base16Scheme = {
    #   base00 = "232136";
    #   base01 = "2a273f";
    #   base02 = "393552";
    #   base03 = "6e6a86";
    #   base04 = "908caa";
    #   base05 = "e0def4";
    #   base06 = "e0def4";
    #   base07 = "56526e";
    #   base08 = "eb6f92";
    #   base09 = "f6c177";
    #   base0A = "ea9a97";
    #   base0B = "3e8fb0";
    #   base0C = "9ccfd8";
    #   base0D = "c4a7e7";
    #   base0E = "f6c177";
    #   base0F = "56526e";
    # };
    polarity = "dark";
    opacity.terminal = 0.8;
    cursor.package = pkgs.bibata-cursors;
    cursor.name = "Bibata-Modern-Ice";
    # cursor.package = pkgs.banana-cursor;
    # cursor.name = "Banana";
    cursor.size = 48;
    fonts = {
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 22;
        terminal = 22;
        desktop = 22;
        popups = 22;
      };
    };
  };

  # Extra Module Options
  # drivers.amdgpu.enable = false;
   drivers.nvidia.enable = true;
   # drivers.nvidia-prime = {
   #    enable = true;
   #    intelBusID = "PCI:0:2:0";
   #    nvidiaBusID = "PCI:1:0:0";
   # };
  # drivers.intel.enable = true;
  vm.guest-services.enable = false;
  # local.hardware-clock.enable = false;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = host;
  networking.timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];

  # Set your time zone.
  time.timeZone = "America/Phoenix";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs = {
    ecryptfs = {
      enable = true;
    };
    proxychains = {
      enable = true;
      proxyDNS = true;
      localnet = "127.0.0.0/255.0.0.0";
      quietMode = true;
      chain.type = "strict";
      tcpReadTimeOut = 15000;
      remoteDNSSubnet = 224;
      tcpConnectTimeOut = 8000;
      proxies.nekoray =
        {
          enable = true;
          type = "socks5";
          host = "127.0.0.1";
          port = 2080;
        };
    };
    starship = {
      enable = true;
      settings = {
        add_newline = false;
        buf = {
          symbol = " ";
        };
        c = {
          symbol = " ";
        };
        directory = {
          read_only = " 󰌾";
        };
        docker_context = {
          symbol = " ";
        };
        fossil_branch = {
          symbol = " ";
        };
        git_branch = {
          symbol = " ";
        };
        golang = {
          symbol = " ";
        };
        hg_branch = {
          symbol = " ";
        };
        hostname = {
          ssh_symbol = " ";
        };
        lua = {
          symbol = " ";
        };
        memory_usage = {
          symbol = "󰍛 ";
        };
        meson = {
          symbol = "󰔷 ";
        };
        nim = {
          symbol = "󰆥 ";
        };
        nix_shell = {
          symbol = " ";
        };
        nodejs = {
          symbol = " ";
        };
        ocaml = {
          symbol = " ";
        };
        package = {
          symbol = "󰏗 ";
        };
        python = {
          symbol = " ";
        };
        rust = {
          symbol = " ";
        };
        swift = {
          symbol = " ";
        };
        zig = {
          symbol = " ";
        };
      };
    };
    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    virt-manager.enable = true;
    # steam = {
    #   enable = true;
    #   gamescopeSession.enable = true;
    #   remotePlay.openFirewall = true;
    #   dedicatedServer.openFirewall = true;
    # };
    # thunar = {
    #   enable = true;
    #   plugins = with pkgs.xfce; [
    #     thunar-archive-plugin
    #     thunar-volman
    #   ];
    # };
  };

  nixpkgs.overlays = [
    (import ../../config/overlays.nix)
  ];

  nixpkgs.config.allowUnfree = true;

  users = {
    mutableUsers = true;
  };

  documentation.man.generateCaches = false;
  documentation.man.enable = true;
  documentation.man.man-db.enable = true;

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    killall
    eza
    git
    cmatrix
    lolcat
    htop
    wofi
    groff
    brave
    udiskie
    pyprland
    alacritty
    zathura
    fd
    libvirt
    parted
    cryptsetup
    lxqt.lxqt-policykit
    lm_sensors
    unzip
    unrar
    libnotify
    obs-studio
    nyx
    v4l-utils
    ydotool
    duf
    ncdu
    wl-clipboard
    pciutils
    ffmpeg
    calibre
    nvtopPackages.full
    nb
    socat
    cowsay
    ripgrep
    ripgrep-all
    lshw
    bat
    pkg-config
    meson
    hyprpicker
    ninja
    brightnessctl
    virt-viewer
    virt-manager
    sshfs
    ncmpcpp
    mpc-cli
    lazygit
    swappy
    appimage-run
    networkmanagerapplet
    nmap
    whois
    unar
    dig
    pulsemixer
    mkvtoolnix-cli
    hplip
    yad
    inxi
    playerctl
    nh
    nixfmt-rfc-style
    discord
    swww
    grim
    slurp
    file-roller
    swaynotificationcenter
    imv
    mpv
    pavucontrol
    tree
    # neovide
    greetd.tuigreet
    sl
    newsboat
    signal-desktop
    # session-desktop-appimage
    # simplex-chat-desktop

    #phone (flash the phone and get adb so can send files):
    android-udev-rules
    android-tools


    # neomutt and related progs:
    neomutt
    isync
    msmtp
    mypy ruff
    mutt-wizard pass notmuch imagemagick w3m lynx abook

    # Yubikey
    gnupg
    yubikey-personalization
    yubikey-manager
    pcsclite
    pcsctools
    pam_u2f
    keepassxc

    # random stuff i found in my arch computer.
    proxychains
    ecryptfs
    openssl
    untrunc-anthwlock
    conda
    qbittorrent
    nfs-utils
    screenkey
    tlrc
    tor-browser-bundle-bin
    torsocks
    trash-cli
    xdotool
    zsh-completions
    nix-zsh-completions
    myPython
    nwg-look
    libreoffice
    wireguard-tools
    nekoray
    floorp
    rclone
    syncthing
    yubioath-flutter
    poppler_utils
    tealdeer
    zenity

    # Basic build tools
    gnumake
    gcc
    binutils
    qrencode
    freetube
    
    # Additional common build tools
    pkg-config
    cmake

  # Optionally, add a convenient way to run AppImages
    (writeShellScriptBin "run-appimage" ''
      ${appimage-run}/bin/appimage-run /opt/appimages/$1
    '')

    (writeShellScriptBin "tmux-restore" ''
      ${pkgs.tmux}/bin/tmux start-server
      ${pkgs.tmux}/bin/tmux new-session -d
      ${pkgs.tmux}/bin/tmux run-shell "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh"
      ${pkgs.tmux}/bin/tmux attach-session -t 0
    '')

    (writeScriptBin "music-layout" ''
      #!${pkgs.bash}/bin/bash
      
      # Create new window or use existing one
      tmux new-window -n music || tmux select-window -t music
      
      # Split the window vertically into 3 panes
      tmux split-window -v
      tmux split-window -h
      
      # Select and run command in each pane
      tmux select-pane -t 0
      tmux send-keys "ncmpcpp -s media_library" C-m
      
      tmux select-pane -t 1
      tmux send-keys "ncmpcpp -s playlist_editor" C-m
      
      tmux select-pane -t 2
      tmux send-keys "ncmpcpp -s playlist" C-m
    '')

# Wireguard control:
    (writeScriptBin "wg-toggle" ''
      #!${stdenv.shell}
      WG_DIR="/etc/nixos/wireguard"

      # Check if running as root
      if [ "$(id -u)" -ne 0 ]; then
        exec sudo "$0" "$@"
      fi

      # Check if wireguard directory exists
      if [ ! -d "$WG_DIR" ]; then
        echo "Error: Wireguard directory ($WG_DIR) does not exist."
        echo "Please create the directory and add your configuration files."
        exit 1
      fi

      # Check if directory is empty (no .conf files)
      if [ -z "$(find "$WG_DIR" -name "*.conf" 2>/dev/null)" ]; then
        echo "Error: No Wireguard configuration files found in $WG_DIR"
        echo "Please add your .conf files to the directory."
        exit 1
      fi

      # Function to get current running interface (if any)
      get_running_interface() {
        wg show interfaces 2>/dev/null
      }

      # If WireGuard is running, just turn it off
      RUNNING_INTERFACE=$(get_running_interface)
      if [ -n "$RUNNING_INTERFACE" ]; then
        CONFIG="$WG_DIR/$RUNNING_INTERFACE.conf"
        wg-quick down "$CONFIG"
        echo "WireGuard disconnected"
        exit 0
      fi

      # If we get here, WireGuard is not running, so show the menu
      echo "Select WireGuard configuration to activate:"
      
      # Create array of config files
      configs=()
      while IFS= read -r -d $'\0' file; do
        configs+=("$file")
      done < <(find "$WG_DIR" -name "*.conf" -print0 | sort -z)

      # Display menu
      i=1
      for config in "''${configs[@]}"; do
        filename=$(basename "$config" .conf)
        echo "$i) $filename"
        ((i++))
      done

      # Get user choice
      read -p "Enter number (1-$((i-1))): " choice

      # Validate input
      if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt $((i-1)) ]; then
        echo "Invalid selection"
        exit 1
      fi

      # Convert choice to array index (0-based)
      ((choice--))
      
      # Get selected config file
      selected_config="''${configs[$choice]}"
      
      # Extract interface name from filename
      INTERFACE=$(basename "$selected_config" .conf)
      
      # Activate the selected configuration
      wg-quick up "$selected_config"
      echo "WireGuard connected using $INTERFACE"
    '')

  # Add a desktop file for each appimage here:
    (makeDesktopItem {
      name = "Nunchuk";
      desktopName = "Nunchuk";
      exec = "${pkgs.appimage-run}/bin/appimage-run /opt/appimages/nunchuk-linux-1.9.39.AppImage";
      icon = ""; # Leave empty if there's no icon
      comment = "Nunchuk Application";
      categories = [ "Utility" ];
      terminal = false;
    })
    (makeDesktopItem {
      name = "Session";
      desktopName = "Session";
      exec = "${pkgs.appimage-run}/bin/appimage-run /opt/appimages/session-desktop-linux-x86_64-1.14.2.AppImage";
      icon = ""; # Leave empty if there's no icon
      comment = "Session Application";
      categories = [ "Utility" ];
      terminal = false;
    })
    (makeDesktopItem {
      name = "SimpleX";
      desktopName = "SimpleX";
      exec = "${pkgs.appimage-run}/bin/appimage-run /opt/appimages/simplex-desktop-x86_64.AppImage";
      icon = ""; # Leave empty if there's no icon
      comment = "SimpleX Application";
      categories = [ "Utility" ];
      terminal = false;
    })
    (makeDesktopItem {
      name = "LMStudio";
      desktopName = "LM Studio";
      exec = "${pkgs.appimage-run}/bin/appimage-run /opt/appimages/LM_Studio-0.3.2.AppImage";
      icon = ""; # Leave empty if there's no icon
      comment = "LM Studio Application";
      categories = [ "Utility" ];
      terminal = false;
    })
    (makeDesktopItem {
      name = "Logseq";
      desktopName = "Logseq";
      exec = "${pkgs.appimage-run}/bin/appimage-run /opt/appimages/Logseq-linux-x64-0.10.9.AppImage";
      icon = ""; # Leave empty if there's no icon
      comment = "Logseq Application";
      categories = [ "Utility" ];
      terminal = false;
    })
  ];

  environment.sessionVariables = {
    PYTHONPATH = "${myPython}/${myPython.sitePackages}";
  };

  #touch yubikey for sudo
  security.pam.services.sudo = {
    u2fAuth = true;
  };

  #yubikey stuff:
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts-emoji
      noto-fonts-cjk-sans
      font-awesome
      # symbola
      material-icons
    ];
  };

  environment.variables = {
    ZANEYOS_VERSION = "2.2";
    ZANEYOS = "true";
  };

  # Extra Portal Configuration
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # Enable scanner support if your printer has scanning capabilities
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };

  # Services to start
  services = {
    xserver = {
      enable = false;
      xkb = {
        layout = "${keyboardLayout}";
        variant = "";
      };
    };
    # Enable ollama
    ollama = {
      enable = true;
      port = 11434;
      # Add these lines to ensure GPU support
    };
    # Enable Invidious
    # invidious = {
    #    enable = true;
    #    port = 3000;
    #    settings = lib.mkForce {
    #      check_tables = true;
    #      db = {
    #        dbname = "invidious";
    #        host = "";
    #        password = "";
    #        port = 3000;
    #        user = "invidious";
    #      };
    #      host_binding = "0.0.0.0";
    #      default_user_preferences = {
    #        locale = "en-US";
    #        region = "US";
    #      };
    #      captions = [
    #        "English"
    #        "English (auto-generated)"
    #      ];
    #   };
    # };
    greetd = {
      enable = true;
      vt = 3;
      settings = {
        default_session = {
          # Wayland Desktop Manager is installed only for user ryan via home-manager!
          user = username;
          # .wayland-session is a script generated by home-manager, which links to the current wayland compositor(sway/hyprland or others).
          # with such a vendor-no-locking script, we can switch to another wayland compositor without modifying greetd's config here.
          # command = "$HOME/.wayland-session"; # start a wayland session directly without a login manager
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --cmd Hyprland"; # start Hyprland with a TUI login manager
        };
      };
    };
    # smartd = {
    #   enable = false;
    #   autodetect = true;
    # };
    libinput.enable = true;
    fstrim.enable = true;
    gvfs.enable = true;
    openssh.enable = true;
    # flatpak.enable = false;
    printing = {
      enable = true;
      drivers = [ pkgs.hplip pkgs.hplipWithPlugin ];
      browsing = true;
      defaultShared = true;
      # Add CUPS admin rights
      allowFrom = [ "all" ];
      listenAddresses = [ "*:631" ];
    };
    gnome.gnome-keyring.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = true;
    syncthing = {
      enable = true;
      user = "${username}";
      dataDir = "/home/${username}";
      configDir = "/home/${username}/.config/syncthing";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    rpcbind.enable = false;
    nfs.server.enable = false;
  };
  virtualisation.oci-containers.containers = {
    open-webui = {
      image = "ghcr.io/open-webui/open-webui:main";
      autoStart = false;
    };
  };

systemd.services.pull-open-webui = {
  description = "Pull Open WebUI Docker image";
  after = [ "network-online.target" ];
  wants = [ "network-online.target" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = ''
      ${pkgs.bash}/bin/bash -c '\
        if ! ${pkgs.podman}/bin/podman image exists ghcr.io/open-webui/open-webui:main; then \
          ${pkgs.podman}/bin/podman pull ghcr.io/open-webui/open-webui:main; \
        fi'
    '';
    RemainAfterExit = true;
    TimeoutStartSec = "30";
    StartLimitIntervalSec = "300";  # 5 minutes, changed from StartLimitInterval
    StartLimitBurst = "3";
    FailureAction = "none";
    SuccessAction = "none";
  };
};

systemd.services.open-webui = {
  description = "Open WebUI";
  after = [ "network.target" "podman.socket" ];  # Remove pull-open-webui.service from after
  requires = [ "podman.socket" ];  # Remove pull-open-webui.service from requires
  wants = [ "pull-open-webui.service" ];  # Add as a weak dependency instead
  wantedBy = [ "multi-user.target" ];
  # ... rest of the service config
};

  # Ensure podman.socket is enabled
  systemd.sockets.podman = {
    wantedBy = [ "sockets.target" ];
  };
  # systemd.services.flatpak-repo = {
  #   path = [ pkgs.flatpak ];
  #   script = ''
  #     flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  #   '';
  # };
  # hardware.sane = {
  #   enable = true;
  #   extraBackends = [ pkgs.sane-airscan ];
  #   disabledDefaultBackends = [ "escl" ];
  # };

  # Extra Logitech Support
  # hardware.logitech.wireless.enable = false;
  # hardware.logitech.wireless.enableGraphical = false;

  # Bluetooth Support
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;

  # Trying this to get sound working:
  hardware.enableAllFirmware = true;

  # Security / Polkit
  # security.rtkit.enable = true;
  # security.polkit.enable = true;
  # security.polkit.extraConfig = ''
  #   polkit.addRule(function(action, subject) {
  #     if (
  #       subject.isInGroup("users")
  #         && (
  #           action.id == "org.freedesktop.login1.reboot" ||
  #           action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
  #           action.id == "org.freedesktop.login1.power-off" ||
  #           action.id == "org.freedesktop.login1.power-off-multiple-sessions"
  #         )
  #       )
  #     {
  #       return polkit.Result.YES;
  #     }
  #   })
  # '';
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # Optimization settings and garbage collection automation
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Virtualization / Containers
  virtualisation.libvirtd.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Wireguard: UNCOMMENT to have a wireguard tunnel. put the config files in /etc/nixos/wireguard:
# .rw-r--r-- 290 root 30 Sep 08:35  jp-osa-wg-001.conf
# .rw-r--r-- 291 root 30 Sep 08:35  jp-osa-wg-002.conf
# .rw-r--r-- 291 root 30 Sep 08:35  jp-osa-wg-003.conf
# .rw-r--r-- 291 root 30 Sep 08:35  jp-osa-wg-004.conf
# .rw-r--r-- 273 root 30 Sep 08:35  jp-tok-jp2.conf
# .rw-r--r-- 291 root 30 Sep 08:35  jp-tyo-wg-001.conf
# .rw-r--r-- 291 root 30 Sep 08:35  jp-tyo-wg-002.conf
# .rw-r--r-- 291 root 30 Sep 08:35  jp-tyo-wg-201.conf
# .rw-r--r-- 289 root 30 Sep 08:35  jp-tyo-wg-202.conf
# .rw-r--r-- 290 root 30 Sep 08:35  jp-tyo-wg-203.conf
  # networking.wg-quick.interfaces.wg0.configFile = "/etc/nixos/wireguard/jp-tok-jp2.conf";
  # networking.wg-quick.interfaces.wg0.configFile = "/etc/nixos/wireguard/tw-tai-tw1.conf";
  # networking.wg-quick.interfaces.wg0.configFile = "/etc/nixos/wireguard/us-pho-us-az1.conf";

  # OpenGL
  hardware.graphics.enable = true;

  console.keyMap = "${keyboardLayout}";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
