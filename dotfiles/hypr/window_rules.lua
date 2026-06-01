local apps = require("apps")

-- Floating dialogs / portals
hl.window_rule({ match = { class = "^(rofi)$" }, float = true }) -- app launcher
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true }) -- audio control
hl.window_rule({ match = { class = "^()$", title = "^(Picture in picture)$" }, float = true }) -- generic pip
hl.window_rule({ match = { class = "^(brave.*)$", title = "^(Save File)$" }, float = true }) -- brave save dialog
hl.window_rule({ match = { class = "^(brave.*)$", title = "^(Open File)$" }, float = true }) -- brave open dialog
hl.window_rule({ match = { class = "^(LibreWolf)$", title = "^(Picture-in-Picture)$" }, float = true }) -- librewolf pip
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true }) -- bluetooth manager
hl.window_rule({ match = { class = "^(xdg-desktop-portal-gtk)$" }, float = true }) -- gtk portal
hl.window_rule({ match = { class = "^(xdg-desktop-portal-kde)$" }, float = true }) -- kde portal
hl.window_rule({ match = { class = "^(xdg-desktop-portal-hyprland)$" }, float = true }) -- hyprland portal
hl.window_rule({ match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" }, float = true }) -- polkit auth popup
hl.window_rule({ match = { class = "^(CachyOSHello)$" }, float = true }) -- cachyos welcome app
hl.window_rule({ match = { class = "^(zenity)$" }, float = true }) -- gtk dialog utility
hl.window_rule({ match = { class = "^()$", title = "^(Steam - Self Updater)$" }, float = true }) -- steam updater popup

-- Steam / games
hl.window_rule({
	match = { class = "^(steam_app_0)$", title = "^(World of Warcraft)$" },
	float = true,
	monitor = "HDMI-A-1",
}) -- WoW on main monitor
hl.window_rule({
	match = { class = "^(steam_app_0)$" },
	float = true,
	monitor = "DP-1",
}) -- other steam_app_0 on DP-1
hl.window_rule({
	match = { class = "^(steam_app_.*)$" },
	monitor = "DP-1",
	center = true,
}) -- all steam games on DP-1
hl.window_rule({
	match = { class = "^(steam)$", title = "^(Sign in to Steam)$" },
	float = true,
	monitor = "DP-1",
	center = true,
}) -- steam login on DP-1
hl.window_rule({
	match = { title = "^(Return Of Reckoning)$" },
	float = true,
	monitor = "DP-1",
	center = true,
}) -- RoR on DP-1

-- Opacity
hl.window_rule({ match = { class = "^(Thunar)$" }, opacity = "0.92" }) -- file manager
hl.window_rule({ match = { class = "^(Nautilus)$" }, opacity = "0.92" }) -- file manager
hl.window_rule({ match = { class = apps.discord.class }, opacity = "0.96" }) -- discord
hl.window_rule({ match = { class = "^(armcord)$" }, opacity = "0.96" }) -- armcord
hl.window_rule({ match = { class = "^(webcord)$" }, opacity = "0.96" }) -- webcord
hl.window_rule({ match = { class = apps.telegram.class }, opacity = "0.95" }) -- telegram
hl.window_rule({ match = { title = "QQ" }, opacity = "0.95" }) -- QQ

-- Picture-in-picture / floating media
hl.window_rule({
	match = { title = "^(Picture-in-Picture)$" },
	float = true,
	size = { 960, 540 },
	move = { "monitor_w*0.25", "monitor_h*0.25" },
}) -- generic pip
hl.window_rule({
	match = { class = "^(imv)$" },
	float = true,
	size = { 960, 540 },
	move = { "monitor_w*0.25", "monitor_h*0.25" },
}) -- image viewer
hl.window_rule({
	match = { class = "^(mpv)$" },
	float = true,
	size = { 960, 540 },
	move = { "monitor_w*0.25", "monitor_h*0.25" },
}) -- video player
hl.window_rule({
	match = { class = "^(danmufloat)$" },
	float = true,
	size = { 960, 540 },
	move = { "monitor_w*0.25", "monitor_h*0.25" },
	pin = true,
	rounding = 5,
}) -- danmu overlay
hl.window_rule({
	match = { class = "^(termfloat)$" },
	float = true,
	size = { 960, 540 },
	move = { "monitor_w*0.25", "monitor_h*0.25" },
	rounding = 5,
}) -- floating terminal
hl.window_rule({
	match = { class = "^(nemo)$" },
	float = true,
	size = { 960, 540 },
	move = { "monitor_w*0.25", "monitor_h*0.25" },
}) -- file manager
hl.window_rule({
	match = { class = "^(ncmpcpp)$" },
	float = true,
	size = { 960, 540 },
	move = { "monitor_w*0.25", "monitor_h*0.25" },
}) -- music player

-- Animations
hl.window_rule({ match = { class = "^(kitty)$" }, animation = "slide right" }) -- kitty terminal
hl.window_rule({ match = { class = "^(alacritty)$" }, animation = "slide right" }) -- alacritty terminal

-- No blur
hl.window_rule({ match = { class = apps.browser.class }, no_blur = true }) -- browser (performance)
hl.window_rule({ match = { class = "^(waybar)$" }, no_blur = true }) -- waybar (handled via layer rule instead)

-- Layer rules
hl.layer_rule({ match = { namespace = "waybar" }, blur = false }) -- blur waybar background
