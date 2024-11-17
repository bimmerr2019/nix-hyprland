{ pkgs }:

let
  urls = ''
    declare -A URLS
    URLS=(
      ["📹 YouTube"]="https://www.youtube.com/results?search_query="
      ["🌎 SearxNG"]="https://lili2023.dedyn.io/search?q="
      ["🎁 Amazon"]="https://www.amazon.com/s?k="
      ["🐃 Reddit"]="https://www.reddit.com/search/?type=link&cId=4f0baf0f-4c97-4d8d-b199-9d5079664c6f&iId=6583d929-6783-4932-9b45-36898c623ea0&q="
      ["😢 Wikipedia"]="https://en.wikipedia.org/?search="
      ["🏴 Pirate Bay"]="http://thepiratebay.org/search/"
      [" Arch Wiki"]="https://wiki.archlinux.org/title/"
      [" Bitcoin txid"]="https://blockstream.info/tx/"
      ["🔍 Phind"]="http://phind.com/search?q="
      ["🦥 EBay"]="http://ebay.com/sch/"
      ["🦆 Duck Duck Go"]="http://duckduckgo.com/?q="
      ["📚 StackOverflow"]="https://stackoverflow.com/search?s=8c0c0bf1-cb55-4552-80f7-78496b8b952a&q="
      ["💋 Subtitles"]="https://yifysubtitles.ch/search?q="
      [" Nix Packages"]="https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query="
    )
  '';

  fzfScript = ''
    ${urls}
    selection=$(for i in "''${!URLS[@]}"; do
      echo "$i"
    done | ${pkgs.fzf}/bin/fzf --prompt="Select a searcher: " \
                                --height=100% \
                                --layout=reverse \
                                --border \
                                --margin=0,1 \
                                --info=hidden)

    if [ -n "$selection" ]; then
      echo "$selection" > /tmp/web-search-selection
    fi
  '';
in
pkgs.writeShellScriptBin "web-search" ''
    # Use Alacritty with fzf for platform selection
    ${pkgs.alacritty}/bin/alacritty --class floating_fzf \
      -o window.dimensions.columns=40 \
      -o window.dimensions.lines=8 \
      -o window.padding.x=5 \
      -o window.padding.y=5 \
      -o font.size=18.0 \
      -e ${pkgs.bash}/bin/bash -c '${fzfScript}'

    # Read the selection from the temporary file
    if [ -f /tmp/web-search-selection ]; then
      platform=$(cat /tmp/web-search-selection)
      rm /tmp/web-search-selection
    else
      exit 1
    fi

    if [[ -n "$platform" ]]; then
      # Use zenity for query input
      query=$(GDK_BACKEND=x11 ${pkgs.zenity}/bin/zenity --entry --title="What Search term would you like dear?" --text="" --width=400)

      if [[ -n "$query" ]]; then
        ${urls}
        url=''${URLS[$platform]}$query
        ${pkgs.xdg-utils}/bin/xdg-open "$url"
        # Switch to workspace 2 using Hyprland
        ${pkgs.hyprland}/bin/hyprctl dispatch workspace 2
      else
        exit 1
      fi
    else
      exit 1
    fi
''
