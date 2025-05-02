local wezterm = require("wezterm")

local is_darwin = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil
local is_windows = wezterm.target_triple:find("windows") ~= nil
local config = {}

config.adjust_window_size_when_changing_font_size = false
config.font = wezterm.font_with_fallback({
	{ family = "RecMonoCasual Nerd Font Mono", weight = 400 },
	{ family = "Symbols Nerd Font Mono", weight = 400 },
})
config.font_size = 16.0
config.font_rules = {
	{
		italic = true,
		font = wezterm.font_with_fallback({
			{ family = "Recursive", weight = 400, italic = true },
			{ family = "RecMonoCasual Nerd Font Mono", weight = 400, italic = true },
			{ family = "Symbols Nerd Font Mono", weight = 400, italic = true },
		}),
	},
}
config.enable_tab_bar = false
if not is_linux then
	config.color_scheme = "Astrodark"
else
	config.color_scheme = "Dark+"
end
if is_linux then
	config.enable_wayland = true
end
if is_darwin then
	config.macos_window_background_blur = 80
	config.window_background_opacity = 0.85
end
if is_windows then
	config.window_background_opacity = 0.85
	config.win32_system_backdrop = "Acrylic"
end
config.front_end = "WebGpu"

return config
