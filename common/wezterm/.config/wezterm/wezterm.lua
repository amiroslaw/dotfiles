local wezterm = require 'wezterm'
local plugins = require 'plugins'
local bindings = require 'key'

local launch_menu = {
	{
		args = { 'btm' },
	},
	{
		args = { 'bmenu' },
	},
	{
		label = 'music',
		args = { 'mpd', '&&', 'ncmpcpp', '&&', 'mpc', 'update' },
	},
	{
		label = 'note',
		args = { 'nvim' },
		cwd = wezterm.home_dir .. '/Documents/notebook',
	},
	{
		label = 'tor',
		args = { 'screen', '-x', 'tor' },
	},
}
return { -- Must be in the end
	color_scheme = plugins.getColorscheme 'Dracula',
	default_cursor_style = 'SteadyBar', -- the best in vim
	font_size = 11,
	font = wezterm.font_with_fallback(
		{ 'SauceCodePro Nerd Font Mono', 'FiraCode Nerd Font Mono' },
		{ weight = 'Regular' }
	),
	hide_tab_bar_if_only_one_tab = true,
	scrollback_lines = 10000,
	harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }, -- Disable Ligatures, can by set as toggle

	window_background_opacity = 0.8,
	inactive_pane_hsb = {
		saturation = 0.8,
		brightness = 0.7,
	},
	window_padding = {
		left = '0.2cell',
		right = '1cell', -- needed when scrollbar is enabled
		top = '0.2cell',
		bottom = '0.2cell',
	},
	use_fancy_tab_bar = false,
	enable_scroll_bar = true,
	window_close_confirmation = 'NeverPrompt',
	enable_wayland = false,
	freetype_load_target = 'HorizontalLcd', -- freetype_load_target = "Light",
	warn_about_missing_glyphs = false,
	keys = bindings.keys,
	mouse_bindings = bindings.mouse_bindings,
	launch_menu = launch_menu,
	check_for_updates = false,
	automatically_reload_config = false,
	-- window_background_image = plugins.getRandomBg(wezterm.config_dir .. '/bg/'), -- higher RAM usage, don't use big pictures
	-- window_background_image_hsb = { brightness = 0.14, },
}

