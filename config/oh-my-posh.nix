{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "oh-my-posh";
  version = "23.20.0";

  src = fetchurl {
    url = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v${version}/posh-linux-amd64";
    sha256 = "sha256-H5Wwjy3CaeXfSbucCv5HCkZYK6J8BymDypm0mJeKMz0="; # Replace this with the actual hash
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/oh-my-posh
    chmod +x $out/bin/oh-my-posh
  '';

  meta = with lib; {
    description = "A prompt theme engine for any shell";
    homepage = "https://ohmyposh.dev/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
