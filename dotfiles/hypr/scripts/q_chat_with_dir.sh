#!/bin/bash

# Script to launch Amazon Q chat with directory selection
# Uses wofi to select a directory, then launches Q chat in that directory

# Common directories to choose from
COMMON_DIRS=(
    "$HOME"
    "$HOME/Documents"
    "$HOME/Downloads"
    "$HOME/Projects"
    "$HOME/Code"
    "$HOME/Desktop"
    "$HOME/repos/"
    "/tmp"
    "/"
)

# Add any existing directories from the common list
AVAILABLE_DIRS=()
for dir in "${COMMON_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        AVAILABLE_DIRS+=("$dir")
    fi
done

# Add current directory if not already in list
if [[ ! " ${AVAILABLE_DIRS[@]} " =~ " $(pwd) " ]]; then
    AVAILABLE_DIRS+=("$(pwd)")
fi

# Use wofi to select directory
SELECTED_DIR=$(printf '%s\n' "${AVAILABLE_DIRS[@]}" | wofi --dmenu --prompt "Select directory for Q chat:")

# If a directory was selected, launch Q chat there
if [ -n "$SELECTED_DIR" ] && [ -d "$SELECTED_DIR" ]; then
    # Launch alacritty with Q chat in the selected directory
    alacritty --working-directory "$SELECTED_DIR" -e q chat &
else
    # Fallback: launch file manager to browse and select directory
    BROWSE_DIR=$(zenity --file-selection --directory --title="Select directory for Q chat" 2>/dev/null)
    if [ -n "$BROWSE_DIR" ] && [ -d "$BROWSE_DIR" ]; then
        alacritty --working-directory "$BROWSE_DIR" -e q chat &
    fi
fi
