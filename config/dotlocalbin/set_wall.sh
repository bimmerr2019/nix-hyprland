#!/usr/bin/env bash

set -e

# Path to the current wallpaper file
CURRENT_WALLPAPER_FILE="$HOME/.current_wallpaper"

# Path to the Nix configuration file
NIX_CONFIG_FILE="$HOME/zaneyos/hosts/${HOST}/config.nix"

# Path to the Hyprland configuration file
HYPRLAND_CONFIG_FILE="$HOME/zaneyos/config/hyprland.nix"

# Check if the current wallpaper file exists
if [ ! -f "$CURRENT_WALLPAPER_FILE" ]; then
    echo "Current wallpaper file not found!"
    exit 1
fi

# Read the current wallpaper path
CURRENT_WALLPAPER=$(cat "$CURRENT_WALLPAPER_FILE")

# Extract just the filename from the path
WALLPAPER_FILENAME=$(basename "$CURRENT_WALLPAPER")

echo "Current wallpaper filename: $WALLPAPER_FILENAME"

# Update config.nix
WALLPAPER_LINE=$(grep "image = ../../config/wallpapers/" "$NIX_CONFIG_FILE")

if [ -n "$WALLPAPER_LINE" ]; then
    echo "Found wallpaper line in config.nix: $WALLPAPER_LINE"
    
    # Update the Nix configuration file
    sed -i "s|image = ../../config/wallpapers/.*\.[^;]*;|image = ../../config/wallpapers/$WALLPAPER_FILENAME;|" "$NIX_CONFIG_FILE"
    
    # Verify the change
    NEW_WALLPAPER_LINE=$(grep "image = ../../config/wallpapers/" "$NIX_CONFIG_FILE")
    echo "Updated wallpaper line in config.nix: $NEW_WALLPAPER_LINE"
    
    if [ "$NEW_WALLPAPER_LINE" != "$WALLPAPER_LINE" ]; then
        echo "config.nix updated successfully!"
    else
        echo "Failed to update config.nix. The line remains unchanged."
        exit 1
    fi
else
    echo "Wallpaper line not found in $NIX_CONFIG_FILE"
    exit 1
fi

# Update hyprland.nix
HYPRLAND_WALLPAPER_LINE=$(grep "exec-once = pkill swww || true; swww init && swww img " "$HYPRLAND_CONFIG_FILE")

if [ -n "$HYPRLAND_WALLPAPER_LINE" ]; then
    echo "Found wallpaper line in hyprland.nix: $HYPRLAND_WALLPAPER_LINE"
    
    # Update the Hyprland configuration file
    sed -i "/exec-once = pkill swww || true; swww init && swww img/c\          exec-once = pkill swww || true; swww init && swww img /home/\${username}/Pictures/Wallpapers/$WALLPAPER_FILENAME" "$HYPRLAND_CONFIG_FILE"
    
    # Verify the change
    NEW_HYPRLAND_WALLPAPER_LINE=$(grep "exec-once = pkill swww || true; swww init && swww img " "$HYPRLAND_CONFIG_FILE")
    echo "Updated wallpaper line in hyprland.nix: $NEW_HYPRLAND_WALLPAPER_LINE"
    
    if [ "$NEW_HYPRLAND_WALLPAPER_LINE" != "$HYPRLAND_WALLPAPER_LINE" ]; then
        echo "hyprland.nix updated successfully!"
    else
        echo "Failed to update hyprland.nix. The line remains unchanged."
        exit 1
    fi
else
    echo "Wallpaper line not found in $HYPRLAND_CONFIG_FILE"
    exit 1
fi

echo "New wallpaper: $WALLPAPER_FILENAME"
echo "Please rebuild your Nix configuration to apply changes."
nh os switch --hostname ${HOST} ${HOME}/zaneyos
