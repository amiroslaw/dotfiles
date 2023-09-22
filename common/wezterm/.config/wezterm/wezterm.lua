local wezterm = require 'wezterm'
local plugins = require 'plugins'
local bindings = require 'key'

local launch_menu = {
	{
		args = { 'btop' },
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
	default_cursor_style = 'SteadyBar', -- the best in vim
	font_size = plugins.hostConfig {{'pc', 12}, {'laptop', 11}}, 
	font = wezterm.font_with_fallback(
		{ 'FiraCode Nerd Font Mono', 'SauceCodePro Nerd Font Mono',},
		{ weight = 'Regular' } -- { weight = 'Medium' }
	),
	hide_tab_bar_if_only_one_tab = true,
	scrollback_lines = 10000,
	harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }, -- Disable Ligatures, can by set as toggle

	window_background_opacity = 1.0,
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
	default_workspace = "main",
	color_scheme = plugins.getColorscheme 'Poimandres Storm',
	use_fancy_tab_bar = false,
	enable_scroll_bar = true,
	window_close_confirmation = 'NeverPrompt',
	enable_wayland = false,
	freetype_load_target = 'HorizontalLcd', -- freetype_load_target = "Light",
	warn_about_missing_glyphs = false,
	launch_menu = launch_menu,
	check_for_updates = false,
	key_map_preference = "Mapped",
	keys = bindings.keys,
	leader = bindings.leader,
	mouse_bindings = bindings.mouse_bindings,
	automatically_reload_config = false,
	key_tables = bindings.key_tables,
	-- 'kanagawabones', 'Dracula (Official)'
	-- https://wezfurlong.org/wezterm/colorschemes/d/index.html
	-- disable_default_key_bindings = true,
	-- window_background_image = plugins.getRandomBg(wezterm.config_dir .. '/bg/'), -- higher RAM usage, don't use big pictures
	-- window_background_image_hsb = { brightness = 0.14, },
	-- unix_domains = {
 --    {
 --      name = 'top',
 --    },
 --  },
}

