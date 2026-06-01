hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user import-environment")
	hl.exec_cmd("dbus-update-activation-environment --systemd")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP") -- needed for xdg-desktop-portal
	hl.exec_cmd("swayidle -w timeout 300 'swaylock -f -c 000000' before-sleep 'swaylock -f -c 000000'") -- idle/lock screen
	hl.exec_cmd("hyprpaper") -- wallpaper
	hl.exec_cmd("waybar -c .config/waybar/config.jsonc") -- status bar
	hl.exec_cmd("fcitx5 -d") -- input method
	hl.exec_cmd("mako") -- notification daemon
	hl.exec_cmd("nm-applet --indicator") -- network manager tray
	hl.exec_cmd(
		"bash -c 'mkfifo /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob && tail -f /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob | wob'"
	) -- volume/brightness overlay bar
	hl.exec_cmd("systemctl --user start hyprpolkitagent") -- polkit authentication agent
end)
