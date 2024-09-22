{ writeShellScriptBin, nsxiv }:

writeShellScriptBin "nsxiv-fullscreen" ''
  echo "Starting nsxiv-fullscreen script" >> /tmp/nsxiv-debug.log
  ${nsxiv}/bin/nsxiv -f -z 100 "$@" &
  echo "nsxiv command executed" >> /tmp/nsxiv-debug.log
  sleep 0.5
  echo "Attempting to focus nsxiv window" >> /tmp/nsxiv-debug.log
  hyprctl dispatch focuswindow nsxiv
  echo "Attempting to fullscreen" >> /tmp/nsxiv-debug.log
  hyprctl dispatch fullscreen 1
  echo "Script completed" >> /tmp/nsxiv-debug.log
''
