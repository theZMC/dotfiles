local wezterm = require("wezterm")

local is_darwin = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil
local is_windows = wezterm.target_triple:find("windows") ~= nil
local config = wezterm.config_builder()

config.adjust_window_size_when_changing_font_size = false
config.max_fps = 120
config.font = wezterm.font_with_fallback({
	{
		family = "RecMonoCasual Nerd Font Mono",
		weight = 400,
		harfbuzz_features = {
			"calt",
		},
	},
})
config.font_size = 16.0
config.enable_tab_bar = false
if not is_linux then
	config.color_scheme = "astrodark"
else
	config.color_scheme = "Dark+"
end

if is_linux then
	config.window_background_opacity = 0.95
	if config.kde_window_background_blur ~= nil then
		-- Enable background blur for KDE Plasma (only works on nightly)
		config.kde_window_background_blur = true
	end
end
if is_darwin then
	config.macos_window_background_blur = 80
	config.window_background_opacity = 0.85
end
if is_windows then
	config.window_background_opacity = 0.85
	config.win32_system_backdrop = "Acrylic"
end

return config
