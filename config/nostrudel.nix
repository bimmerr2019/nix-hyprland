{ pkgs, lib, ... }:
let
  nodejs = pkgs.nodejs_20;
  pnpm = pkgs.nodePackages.pnpm;
in
{
  home.packages = with pkgs; [
    nodejs
    pnpm
    go
  ];

  home.activation = {
    setupOrUpdateNostrudel = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Wait for network connectivity
      max_attempts=30
      attempt=0
      while ! ${pkgs.curl}/bin/curl -s https://github.com > /dev/null; do
        attempt=$((attempt+1))
        if [ $attempt -ge $max_attempts ]; then
          echo "Failed to establish network connection after $max_attempts attempts."
          exit 1
        fi
        echo "Waiting for network connection... (attempt $attempt/$max_attempts)"
        sleep 5
      done

      if [ -d "$HOME/nostrudel" ]; then
        echo "Updating existing nostrudel installation..."
        cd "$HOME/nostrudel"
        ${pkgs.git}/bin/git pull https://github.com/hzrd149/nostrudel.git
      else
        echo "Setting up nostrudel for the first time..."
        ${pkgs.git}/bin/git clone https://github.com/hzrd149/nostrudel.git "$HOME/nostrudel"
      fi
      cd "$HOME/nostrudel"
      
      # Use pnpm to install dependencies
      export PATH="${nodejs}/bin:${pnpm}/bin:$PATH"
      ${pnpm}/bin/pnpm install --frozen-lockfile
    '';
  };

  home.file.".local/bin/nostr" = {
    text = ''
      #!/bin/sh
      cd $HOME/nostrudel && ${pnpm}/bin/pnpm dev
    '';
    executable = true;
  };

}
