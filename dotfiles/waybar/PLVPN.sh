#!/bin/bash

CONFIG="PolandVPN.ovpn"
CONFIG_PATH="$HOME/.openvpn/$CONFIG" # adjust if config is elsewhere
PIDFILE="/tmp/openvpn_${CONFIG}.pid"

is_running() {
  [[ -f "$PIDFILE" ]] && ps -p "$(cat "$PIDFILE")" >/dev/null 2>&1
}

toggle_vpn() {
  if is_running; then
    disconnect_vpn
  else
    connect_vpn
  fi
}

print_status() {
  if is_running; then
    echo "✅ $CONFIG"
  else
    echo "❌ $CONFIG"
  fi
}

connect_vpn() {
  if is_running; then
    echo "OpenVPN ($CONFIG) is already running."
    print_status
    exit 0
  fi
  echo "Starting OpenVPN with config $CONFIG..."
  sudo /usr/bin/openvpn --config "$CONFIG_PATH" --daemon --writepid "$PIDFILE"
  sleep 1
  print_status
}

disconnect_vpn() {
  if is_running; then
    echo "Stopping OpenVPN ($CONFIG)..."
    sudo /home/overload/.config/waybar/kill-openvpn.sh $PIDFILE
    sudo rm -f "$PIDFILE"
    echo "❌ $CONFIG"
  else
    echo "OpenVPN is not running."
  fi
}

case "$1" in
toggle)
  toggle_vpn
  ;;
status)
  print_status
  ;;
connect)
  connect_vpn
  ;;
disconnect)
  disconnect_vpn
  ;;
*)
  echo "Usage: $0 {connect|disconnect|toggle|status}"
  ;;
esac
