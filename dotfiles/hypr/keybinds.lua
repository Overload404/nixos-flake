local main_mod = "SUPER"
local apps = require("apps")

-- Apps
hl.bind(main_mod .. " + RETURN", hl.dsp.exec_cmd(apps.terminal.cmd))
hl.bind(main_mod .. " + A", hl.dsp.exec_cmd(apps.chat_ai.cmd, { workspace = 6 }))
hl.bind(main_mod .. " + SHIFT + A", hl.dsp.exec_cmd("~/.config/hypr/scripts/q_chat_with_dir.sh", { workspace = 6 }))
hl.bind(main_mod .. " + B", hl.dsp.exec_cmd(apps.browser.cmd, { workspace = 5 }))
hl.bind(main_mod .. " + D", hl.dsp.exec_cmd(apps.discord.cmd, { workspace = 4 }))
hl.bind(main_mod .. " + G", hl.dsp.exec_cmd(apps.telegram.cmd, { workspace = 4 }))
hl.bind(main_mod .. " + SPACE", hl.dsp.exec_cmd(apps.launcher.cmd))
hl.bind(main_mod .. " + SHIFT + SPACE", hl.dsp.exec_cmd(apps.launcher.cmd .. " -S run"))
hl.bind(main_mod .. " + SHIFT + P", hl.dsp.exec_cmd("gnome-calculator"))
hl.bind(main_mod .. " + O", hl.dsp.exec_cmd("killall -SIGUSR2 waybar"))
-- hl.bind(main_mod .. " + SHIFT + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/rotate_monitor.sh"))
hl.bind(
	"CTRL + ALT + L",
	hl.dsp.exec_cmd("swaylock -C <(cat ~/.config/swaylock/config ~/.config/swaylock/themes/$swaylock_theme)")
)

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot_area"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot_full"))

-- Window management
hl.bind(main_mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(main_mod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(main_mod .. " + V", hl.dsp.window.float())
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen())
hl.bind(main_mod .. " + Y", hl.dsp.window.pin())
hl.bind(main_mod .. " + T", hl.dsp.layout("togglesplit"))
hl.bind(main_mod .. " + U", hl.dsp.group.toggle())
hl.bind(main_mod .. " + Tab", hl.dsp.group.next())
hl.bind(main_mod .. " + M", function()
	hl.config({ general = { layout = "master" } })
end)

-- Gaps
hl.bind(
	main_mod .. " + SHIFT + G",
	hl.dsp.exec_cmd('hyprctl --batch "keyword general:gaps_out 5;keyword general:gaps_in 3"')
)
hl.bind(
	main_mod .. " + CTRL + G",
	hl.dsp.exec_cmd('hyprctl --batch "keyword general:gaps_out 0;keyword general:gaps_in 0"')
)

-- Volume
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("pamixer -ud 3 && pamixer --get-volume > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob"),
	{ repeating = true }
)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("pamixer -ui 3 && pamixer --get-volume > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob"),
	{ repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd(
		"amixer sset Master toggle | sed -En '/\\[on\\]/ s/.*\\[([0-9]+)%\\].*/\\1/ p; /\\[off\\]/ s/.*/0/p' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob"
	)
)

-- Playback
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"))

-- Focus
hl.bind(main_mod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(main_mod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(main_mod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(main_mod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Switch workspaces
for i = 1, 10 do
	local key = i == 10 and "0" or tostring(i)
	hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(main_mod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
	hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind(main_mod .. " + period", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + comma", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(main_mod .. " + slash", hl.dsp.focus({ workspace = "previous" }))

-- Special workspace
hl.bind(main_mod .. " + minus", hl.dsp.window.move({ workspace = "special" }))
hl.bind(main_mod .. " + equal", hl.dsp.workspace.toggle_special(""))

-- Move windows
hl.bind(main_mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(main_mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind(main_mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(main_mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(main_mod .. " + CTRL + H", hl.dsp.window.move({ workspace = "-1", follow = true }))
hl.bind(main_mod .. " + CTRL + L", hl.dsp.window.move({ workspace = "+1", follow = true }))

-- Mouse scroll workspace switch
hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse window move/resize
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize submap
hl.bind(main_mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
	hl.bind("right", hl.dsp.window.resize({ x = 15, y = 0, relative = true }), { repeating = true })
	hl.bind("left", hl.dsp.window.resize({ x = -15, y = 0, relative = true }), { repeating = true })
	hl.bind("up", hl.dsp.window.resize({ x = 0, y = -15, relative = true }), { repeating = true })
	hl.bind("down", hl.dsp.window.resize({ x = 0, y = 15, relative = true }), { repeating = true })
	hl.bind("l", hl.dsp.window.resize({ x = 15, y = 0, relative = true }), { repeating = true })
	hl.bind("h", hl.dsp.window.resize({ x = -15, y = 0, relative = true }), { repeating = true })
	hl.bind("k", hl.dsp.window.resize({ x = 0, y = -15, relative = true }), { repeating = true })
	hl.bind("j", hl.dsp.window.resize({ x = 0, y = 15, relative = true }), { repeating = true })
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Resize without submap
hl.bind("CTRL + SHIFT + left", hl.dsp.window.resize({ x = -15, y = 0, relative = true }))
hl.bind("CTRL + SHIFT + right", hl.dsp.window.resize({ x = 15, y = 0, relative = true }))
hl.bind("CTRL + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -15, relative = true }))
hl.bind("CTRL + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 15, relative = true }))
hl.bind("CTRL + SHIFT + h", hl.dsp.window.resize({ x = -15, y = 0, relative = true }))
hl.bind("CTRL + SHIFT + l", hl.dsp.window.resize({ x = 15, y = 0, relative = true }))
hl.bind("CTRL + SHIFT + k", hl.dsp.window.resize({ x = 0, y = -15, relative = true }))
hl.bind("CTRL + SHIFT + j", hl.dsp.window.resize({ x = 0, y = 15, relative = true }))
