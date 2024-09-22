#!/usr/bin/env bash

DIR1="/run/media/$USER/Movies/"
DIR2="$HOME/Videos/youtube/"

FIND_CMD="find \"$DIR1\" \"$DIR2\" -type f \( -iname \"*.mp4\" -o -iname \"*.mkv\" -o -iname \"*.avi\" -o -iname \"*.webm\" \)"
FIND_CMD1="$FIND_CMD -printf '%P\n'"
FIND_CMD2="$FIND_CMD -print0"

# Combine the directories in the find command
choice="$(eval "$FIND_CMD1" | fzf --prompt 'Launch: ' --border=rounded  --margin=15% --color=dark --height=100% --layout=reverse --header=' Movies ' --info=hidden --header-first )"

[ -z "$choice" ] && exit 0

# Define an array to store full paths
declare -a movie_paths

# Populate the array with full paths
while IFS= read -r -d '' movie; do
    movie_paths+=("$movie")
done < <(eval "$FIND_CMD2")

# Get the full path based on the selected choice
selected_path=""
for path in "${movie_paths[@]}"; do
    if [[ "$path" == *"$choice" ]]; then
        selected_path="$path"
        break
    fi
done

# Check if a valid path was found
if [ -z "$selected_path" ]; then
    echo "Error: Unable to find the selected movie path."
    exit 1
fi

# Execute mpv with the selected path
#exec pypr toggle movies
exec mpv "$selected_path"
