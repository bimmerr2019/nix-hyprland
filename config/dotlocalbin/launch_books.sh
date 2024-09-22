#!/usr/bin/env bash

DIR1="$HOME/Downloads/"
DIR2="$HOME/Nextcloud-public/textbooks/"

FIND_CMD="find \"$DIR1\" \"$DIR2\" -type f \( -iname \"*.pdf\" -o -iname \"*.epub\" \)"
FIND_CMD1="$FIND_CMD -printf '%P\n'"
FIND_CMD2="$FIND_CMD -print0"

# Combine the directories in the find command
choice="$(eval "$FIND_CMD1" | fzf --prompt 'Launch: ' --border=rounded  --margin=15% --color=dark --height=100% --layout=reverse --header=' Books ' --info=hidden --header-first )"

[ -z "$choice" ] && exit 0

# Define an array to store full paths
declare -a book_paths

# Populate the array with full paths
while IFS= read -r -d '' book; do
    book_paths+=("$book")
done < <(eval "$FIND_CMD2")

# Get the full path based on the selected choice
selected_path=""
for path in "${book_paths[@]}"; do
    if [[ "$path" == *"$choice" ]]; then
        selected_path="$path"
        break
    fi
done

# Check if a valid path was found
if [ -z "$selected_path" ]; then
    echo "Error: Unable to find the selected book path."
    exit 1
fi

# Execute mpv with the selected path
#exec pypr toggle books
exec zathura "$selected_path"
