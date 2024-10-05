local wezterm = require("wezterm")
return {
	font = wezterm.font({ family = "RecMonoCasual Nerd Font Mono", weight = 400 }),
	font_size = 16.0,
	font_rules = {
		{
			italic = true,
			font = wezterm.font_with_fallback({
				{ family = "Recursive", weight = 400, italic = true },
				{ family = "RecMonoCasual Nerd Font Mono", weight = 400, italic = true },
			}),
		},
	},
	enable_tab_bar = false,
	enable_wayland = true,
	color_scheme = "Astrodark",
	window_background_opacity = 0.85,
	macos_window_background_blur = 80,
	win32_system_backdrop = "Acrylic",
	front_end = "WebGpu",
}
