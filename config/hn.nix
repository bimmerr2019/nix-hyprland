{
  pkgs,
  ...
}: let
  hn-text = pkgs.buildGoModule rec {
    pname = "hn-text";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      owner = "piqoni";
      repo = "hn-text";
      rev = "main";
      sha256 = "sha256-YoPdYuNlWrLITyd2XeCOeGy70Ews1rvtOQzYZAQTI+Y=";
    };
    vendorHash = "sha256-ogDJc8TLAs6L6sCUxtd0bCqvMVcIqi2pLnbm1fFbRGE=";

    proxyVendor = true;
    doCheck = false; # Skip tests if they're causing issues
  };
in {
  home.packages = [hn-text];

  home.sessionPath = [
    "$HOME/go/bin"
  ];
}
