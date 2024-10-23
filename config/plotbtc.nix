{
  config,
  pkgs,
  lib,
  ...
}: {
  home.activation = {
    cloneAndUpdateRepo = lib.hm.dag.entryAfter ["writeBoundary"] ''
      REPO_URL="https://github.com/bimmerr2019/plotbtc.git"
      REPO_DIR="$HOME/plotbtc"

      # Function to check network connectivity
      check_network() {
        ${pkgs.curl}/bin/curl -s --connect-timeout 5 https://github.com > /dev/null
      }

      # Wait for network connectivity
      max_attempts=30
      attempt=0
      while ! check_network; do
        attempt=$((attempt+1))
        if [ $attempt -ge $max_attempts ]; then
          echo "Failed to establish network connection after $max_attempts attempts."
          exit 1
        fi
        echo "Waiting for network connection... (attempt $attempt/$max_attempts)"
        sleep 5
      done

      if [ ! -d "$REPO_DIR" ]; then
        echo "Cloning repository for the first time..."
        if ! ${pkgs.git}/bin/git clone "$REPO_URL" "$REPO_DIR"; then
          echo "Failed to clone repository."
          exit 1
        fi
      else
        echo "Updating existing repository..."
        cd "$REPO_DIR"
        if ! ${pkgs.git}/bin/git pull; then
          echo "Failed to update repository."
          exit 1
        fi
      fi

      echo "Repository setup/update completed successfully."
    '';
  };
}
