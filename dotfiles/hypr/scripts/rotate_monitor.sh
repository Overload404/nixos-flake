#!/bin/bash

MONITOR="HDMI-A-1"
ROTATION_FILE="/tmp/hypr_rotation_state"

if [ ! -f "$ROTATION_FILE" ]; then
  echo "1" >"$ROTATION_FILE"
fi

CURRENT=$(cat "$ROTATION_FILE")

if [ "$CURRENT" == "0" ]; then
  hyprctl eval 'hl.monitor({output = "HDMI-A-1", mode = "3840x2160@60", position = "0x-1960", scale = "1.0", transform = 1, supports_wide_color = 1,supports_hdr = 1,})'
  echo "1" >"$ROTATION_FILE"
else
  hyprctl eval 'hl.monitor({output = "HDMI-A-1", mode = "2560x1440@60", position = "0x0", scale = "1.0", transform = 0, supports_wide_color = 1,supports_hdr = 1,})'
  echo "0" >"$ROTATION_FILE"
fi
