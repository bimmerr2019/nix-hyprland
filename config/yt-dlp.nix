{pkgs, ...}: {
  home.packages = with pkgs; [
    yt-dlp
  ];
  programs.yt-dlp = {
    enable = true;
    extraConfig = ''
      # Save all videos under YouTube directory in your home directory
      -o ~/Videos/youtube/%(title)s.%(ext)s
      #--proxy socks5://127.0.0.1:20170
      --no-mtime
    '';
  };
}
