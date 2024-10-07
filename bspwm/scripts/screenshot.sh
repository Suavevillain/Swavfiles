#!/bin/bash

# Directory to save screenshots
SCREENSHOT_DIR=~/Pictures/Screenshots

# Create directory if it doesn't exist
mkdir -p $SCREENSHOT_DIR

# Filename format: screenshot-YYYY-MM-DD_HH-MM-SS.png
FILENAME=$SCREENSHOT_DIR/screenshot-$(date '+%Y-%m-%d_%H-%M-%S').png

# Take screenshot with options
case "$1" in
    full)
        scrot $FILENAME
        ;;
    window)
        scrot -u $FILENAME
        ;;
    area)
        scrot -s $FILENAME
        ;;
    *)
        echo "Usage: $0 {full|window|area}"
        exit 1
        ;;
esac

# Notify the user
dunstify -u low "Screenshot taken" "Saved to $FILENAME"

