{
  config,
  lib,
  pkgs,
  ...
}: {
  home.activation = {
    createDirectories = lib.hm.dag.entryAfter ["writeBoundary"] ''
      createDirIfNeeded() {
        echo "Checking $1"
        if [ -L "$1" ]; then
          echo "Symlink exists for $1. Skipping."
        elif [ -d "$1" ]; then
          echo "Directory $1 already exists. Skipping."
        elif [ -e "$1" ]; then
          echo "Warning: $1 exists but is not a directory or symlink. Skipping."
        else
          echo "Creating directory: $1"
          mkdir -p "$1"
          echo "Created directory: $1"
        fi
      }

      createDirIfNeeded "${config.home.homeDirectory}/Nextcloud-prox"
      createDirIfNeeded "${config.home.homeDirectory}/Nextcloud-private"
      createDirIfNeeded "${config.home.homeDirectory}/Nextcloud-public"
      createDirIfNeeded "${config.home.homeDirectory}/Nextcloud-onyx"
      createDirIfNeeded "${config.home.homeDirectory}/Sparrow"
      createDirIfNeeded "${config.home.homeDirectory}/Cloud"
      createDirIfNeeded "${config.home.homeDirectory}/Eclipse"
      createDirIfNeeded "${config.home.homeDirectory}/Encrypted-Cloud"
      createDirIfNeeded "${config.home.homeDirectory}/Movies"
      createDirIfNeeded "${config.home.homeDirectory}/Movies2"
      createDirIfNeeded "${config.home.homeDirectory}/Movies4"

      # Handle Videos directory
      if [ -L "${config.home.homeDirectory}/Videos" ]; then
        echo "Symlink exists for Videos. Skipping directory creation."
      else
        createDirIfNeeded "${config.home.homeDirectory}/Videos"
        createDirIfNeeded "${config.home.homeDirectory}/Videos/youtube"
      fi
    '';
  };
}
