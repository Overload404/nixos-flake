#!/bin/bash

# Define Vendor IDs
NVIDIA_VENDOR="0x10de"
AMD_VENDOR="0x1002"

# Check for actual hardware in sysfs
if grep -q "$NVIDIA_VENDOR" /sys/class/pci_bus/*/device/*/vendor 2>/dev/null && command -v nvidia-smi &>/dev/null; then
  # --- NVIDIA Logic ---
  # Check if nvidia-smi actually talks to a card
  vram=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null)

  if [ $? -eq 0 ]; then
    used=$(echo "$vram" | awk -F ',' '{print $1}' | tr -d '[:space:]')
    total=$(echo "$vram" | awk -F ',' '{print $2}' | tr -d '[:space:]')
    vendor="NVIDIA"
  fi

elif grep -q "$AMD_VENDOR" /sys/class/pci_bus/*/device/*/vendor 2>/dev/null; then
  # --- AMD Logic ---
  # Find which card is the AMD one
  GPU_PATH=$(grep -l "$AMD_VENDOR" /sys/class/drm/card*/device/vendor | head -n 1 | xargs dirname)

  if [ -f "$GPU_PATH/mem_info_vram_used" ]; then
    used_bytes=$(cat "$GPU_PATH/mem_info_vram_used")
    total_bytes=$(cat "$GPU_PATH/mem_info_vram_total")

    used=$((used_bytes / 1024 / 1024))
    total=$((total_bytes / 1024 / 1024))
    vendor="AMD"
  fi
fi

# Convert to GiB with 2 decimal places
used_gib=$(awk "BEGIN {printf \"%.2f\", $used/1024}")
total_gib=$(awk "BEGIN {printf \"%.2f\", $total/1024}")

percent=$((100 * used / total))

if [ "$percent" -gt 90 ]; then
  class="critical"
elif [ "$percent" -gt 70 ]; then
  class="warning"
else
  class="normal"
fi

# Updated echo
echo "{\"text\": \" ${used_gib}/${total_gib}GiB\", \"tooltip\": \"${vendor} VRAM: ${percent}%\", \"class\": \"${class}\"}"
#
# # Final Output
# if [ -n "$used" ] && [ -n "$total" ]; then
#   echo "{\"text\": \"\uf83e ${used} / ${total}MiB\", \"tooltip\": \"${vendor} VRAM Usage\"}"
# else
#   echo "{\"text\": \"\uf83e GPU Offline\", \"tooltip\": \"No active GPU detected\"}"
# fi
