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

  # Remove the setupOrUpdateNostrudel from home.activation

  home.file.".local/bin/setup-nostrudel" = {
    text = ''
      #!/bin/sh
      set -e

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
        ${pkgs.git}/bin/git pull https://github.com/hzrd149/nostrudel.git || {
          echo "Git pull failed. Removing directory and cloning again."
          cd ..
          rm -rf nostrudel
          ${pkgs.git}/bin/git clone https://github.com/hzrd149/nostrudel.git
        }
      else
        echo "Setting up nostrudel for the first time..."
        ${pkgs.git}/bin/git clone https://github.com/hzrd149/nostrudel.git "$HOME/nostrudel"
      fi
      cd "$HOME/nostrudel"
      
      export PATH="${nodejs}/bin:${pnpm}/bin:$PATH"
      export NPM_CONFIG_FETCH_TIMEOUT=300000

      max_retries=3
      for i in $(seq 1 $max_retries); do
        if ${pnpm}/bin/pnpm install --frozen-lockfile; then
          echo "pnpm install successful"
          break
        else
          if [ $i -eq $max_retries ]; then
            echo "pnpm install failed after $max_retries attempts"
            exit 1
          else
            echo "pnpm install failed, retrying in 10 seconds..."
            sleep 10
          fi
        fi
      done
    '';
    executable = true;
  };

  home.file.".local/bin/nostr" = {
    text = ''
      #!/bin/sh
      cd $HOME/nostrudel && ${pnpm}/bin/pnpm dev
    '';
    executable = true;
  };

  home.file.".npmrc".text = ''
    fetch-timeout=300000
  '';
}
