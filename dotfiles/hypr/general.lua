hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 2,
		border_size = 2,
		col = {
			active_border = "rgba(b8bb26cc)",
			inactive_border = "rgba(665c5499)",
		},
		layout = "dwindle",
	},

	decoration = {
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		fullscreen_opacity = 1.0,
		rounding = 0,
		blur = {
			enabled = true,
			size = 15,
			passes = 5,
			new_optimizations = true,
			xray = true,
			ignore_opacity = false,
		},
		shadow = {
			enabled = false,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		dim_inactive = false,
		dim_strength = 0.25,
	},

	dwindle = {
		force_split = 0,
		special_scale_factor = 0.8,
		split_width_multiplier = 1.0,
		use_active_for_splits = true,
		preserve_split = true,
	},

	master = {
		new_status = "master",
		special_scale_factor = 0.8,
	},

	misc = {
		disable_hyprland_logo = true,
		always_follow_on_dnd = true,
		layers_hog_keyboard_focus = true,
		animate_manual_resizes = false,
		enable_swallow = true,
		swallow_regex = "",
		focus_on_activate = true,
	},

	input = {
		kb_layout = "us,ua",
		kb_options = "grp:alt_shift_toggle",
		follow_mouse = 2,
		float_switch_override_focus = 2,
	},

	binds = {
		workspace_back_and_forth = true,
		allow_workspace_cycles = true,
		window_direction_monitor_fallback = true,
	},
})
