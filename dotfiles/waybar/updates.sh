#!/usr/bin/env bash
CACHE=/tmp/waybar-updates-cache
FLAKE_LOCK="/etc/nixos/flake.lock"

if [ -f "$FLAKE_LOCK" ]; then
    age=$(( $(date +%s) - $(stat -c '%Y' "$FLAKE_LOCK") ))
    days=$((age / 86400))
    hours=$(( (age % 86400) / 3600 ))
    
    if [ $days -gt 30 ]; then
        class="critical"
        text="$days d"
        tooltip="Flake lock is $days days old — needs updating!"
    elif [ $days -gt 7 ]; then
        class="high"
        text="$days d"
        tooltip="Flake lock is $days days old"
    elif [ $days -gt 0 ]; then
        class="medium"
        text="$days d"
        tooltip="Flake lock is $days days old"
    elif [ $hours -gt 12 ]; then
        class="low"
        text="$hours h"
        tooltip="Flake lock is $hours hours old"
    else
        class="low"
        text="✓"
        tooltip="System updated recently ($hours h ago)"
    fi
else
    class="low"
    text="?"
    tooltip="No flake lock found at $FLAKE_LOCK"
fi

result="{\"text\":\"$text\",\"class\":\"$class\",\"tooltip\":\"$tooltip\"}"
echo "$result" > "$CACHE"
pkill -RTMIN+8 waybar 2>/dev/null || true
