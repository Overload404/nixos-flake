#!/usr/bin/env bash
CACHE=/tmp/waybar-updates-cache
if [ -f "$CACHE" ]; then
    cat "$CACHE"
else
    echo '{"text":"?","class":"low","tooltip":"Checking for updates...","percentage":"0"}'
fi
