final: prev: {
  signal-desktop = prev.signal-desktop.overrideAttrs (oldAttrs: rec {
    version = "7.22.2";
    src = prev.fetchurl {
      url = "https://updates.signal.org/desktop/apt/pool/s/signal-desktop/signal-desktop_${version}_amd64.deb";
      sha256 = "sha256-QqAE0+NZfEFjoH2VNJ5ZJMVPk/L//ugr3FyPZnL7n4Q=";
    };
  });
}
