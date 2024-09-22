{ pkgs }:

pkgs.writeShellScriptBin "screenshootin" ''
  case "$1" in
    "full")
      grim - | swappy -f -
      ;;
    "area")
      grim -g "$(slurp)" - | swappy -f -
      ;;
    *)
      echo "Usage: screenshootin [full|area]"
      exit 1
      ;;
  esac
''
