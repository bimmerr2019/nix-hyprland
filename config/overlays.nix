final: prev: {
  calibre = prev.calibre.overrideAttrs (oldAttrs: {
    doCheck = false;
    doInstallCheck = false;
    checkPhase = "true";
    installCheckPhase = "true";
  });

  signal-desktop = prev.stdenv.mkDerivation rec {
    pname = "signal-desktop";
    version = "7.32.0";

    src = prev.fetchurl {
      url = "https://updates.signal.org/desktop/apt/pool/s/signal-desktop/signal-desktop_${version}_amd64.deb";
      sha256 = "1skwlzggm7h6iqahi21v9ip5b0z5f5iq73fmsgsnb52y4zd766vc";
    };

    nativeBuildInputs = with prev; [
      dpkg
      makeWrapper
      wrapGAppsHook
      autoPatchelfHook
    ];

    buildInputs = with prev; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libnotify
      libpulseaudio
      libsecret
      libuuid
      libxkbcommon
      mesa
      nspr
      nss
      pango
      systemd
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libxcb
      xorg.libxshmfence
      zlib
    ];

    runtimeDependencies = with prev; [
      (lib.getLib systemd)
      libnotify
      libpulseaudio
      libsecret
    ];

    unpackPhase = ''
      dpkg-deb -x $src .
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      cp -R opt/Signal $out/lib/Signal
      
      mkdir -p $out/bin
      makeWrapper $out/lib/Signal/signal-desktop $out/bin/signal-desktop \
        --prefix PATH : ${prev.lib.makeBinPath [ prev.xdg-utils ]} \
        --prefix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath buildInputs} \
        --set NIXOS_OZONE_WL 1

      mkdir -p $out/share
      cp -R usr/share/applications $out/share
      cp -R usr/share/icons $out/share

      # Fix the desktop file
      substituteInPlace $out/share/applications/signal-desktop.desktop \
        --replace "/opt/Signal/signal-desktop" "$out/bin/signal-desktop"

      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Private messaging from your desktop";
      homepage = "https://signal.org/";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ ];
      platforms = [ "x86_64-linux" ];
    };
  };
}
