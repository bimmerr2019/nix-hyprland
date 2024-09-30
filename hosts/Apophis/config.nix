{
  config,
  pkgs,
  lib,
  host,
  username,
  options,
  ...
}:
let
  inherit (import ./variables.nix) keyboardLayout;
  myPython = pkgs.python39.withPackages (ps: with ps; [
    requests
    pyquery
    python-dateutil
    pyqt5
    pyqtwebengine
    # Add any other packages you need
  ]);
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
    image = ../../config/wallpapers/0262.jpg;
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
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };

  # Extra Module Options
  # drivers.amdgpu.enable = false;
   drivers.nvidia.enable = false;
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
  time.timeZone = "Asia/Shanghai";

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
    firefox.enable = false;
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

  nixpkgs.config.allowUnfree = true;

  users = {
    mutableUsers = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    killall
    eza
    git
    cmatrix
    lolcat
    htop
    brave
    udiskie
    pyprland
    alacritty
    zathura
    fd
    libvirt
    lxqt.lxqt-policykit
    lm_sensors
    unzip
    unrar
    libnotify
    v4l-utils
    ydotool
    duf
    ncdu
    wl-clipboard
    pciutils
    ffmpeg
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
    neovide
    greetd.tuigreet
    sl
    newsboat
    calibre
    signal-desktop

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
    qbittorrent-qt5
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

  # Optionally, add a convenient way to run AppImages
    (writeShellScriptBin "run-appimage" ''
      ${appimage-run}/bin/appimage-run /opt/appimages/$1
    '')
  # Add a desktop file for each appimage here:
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
      noto-fonts-cjk
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
    invidious = {
       enable = true;
       port = 3000;
       settings = lib.mkForce {
         check_tables = true;
         db = {
           dbname = "invidious";
           host = "";
           password = "";
           port = 3000;
           user = "invidious";
         };
         host_binding = "0.0.0.0";
         default_user_preferences = {
           locale = "en-US";
           region = "US";
         };
         captions = [
           "English"
           "English (auto-generated)"
         ];
      };
    };
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
      drivers = [
        # pkgs.hplipWithPlugin
      ];
    };
    gnome.gnome-keyring.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    ipp-usb.enable = true;
    syncthing = {
      enable = false;
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
    before = [ "open-webui.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.podman}/bin/podman pull ghcr.io/open-webui/open-webui:main";
      RemainAfterExit = true;
    };
  };

  systemd.services.open-webui = {
    description = "Open WebUI";
    after = [ "network.target" "pull-open-webui.service" "podman.socket" ];
    requires = [ "pull-open-webui.service" "podman.socket" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStartPre = [
        "${pkgs.podman}/bin/podman stop -i open-webui || true"
        "${pkgs.podman}/bin/podman rm -f open-webui || true"
      ];
      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --rm \
          --network=host \
          -v open-webui:/app/backend/data \
          -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
          --name open-webui \
          ghcr.io/open-webui/open-webui:main
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop open-webui";
      ExecStopPost = "${pkgs.podman}/bin/podman rm open-webui";
      TimeoutStartSec = "20m";
      Restart = "always";
      Type = "simple";
    };
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
