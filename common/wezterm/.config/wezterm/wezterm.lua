local wezterm = require 'wezterm'
local plugins = require 'plugins'

local keys = { }
local act = wezterm.action
local function map(key, cmd, modKey)
	table.insert(keys, {
		key = key,
		mods = modKey,
		action = cmd,
	})
end

local function mapCtr(key, cmd)
	map(key, cmd, 'CTRL')
end

-- ALT + number to activate that tab
for i = 1, 8 do
	map(tostring(i), wezterm.action { ActivateTab = i - 1 }, 'ALT')
end

mapCtr('O', 'ShowLauncher')
mapCtr('Y', act{CopyTo = 'Clipboard'})
map('Backspace', act { ClearScrollback = 'ScrollbackOnly' }, 'CTRL|SHIFT') -- leave one page
mapCtr('|', act { ClearScrollback = 'ScrollbackAndViewport' })
map('Enter', 'SpawnWindow', 'CTRL|SHIFT')
mapCtr('~', 'ShowDebugOverlay')
-- Pane
mapCtr('?', act { SplitVertical = { domain = 'CurrentPaneDomain' } })
mapCtr(':', act { SplitHorizontal = { domain = 'CurrentPaneDomain' } })
mapCtr('W', act { CloseCurrentPane = { confirm = false } })
mapCtr('M', 'TogglePaneZoomState') -- maximalize
mapCtr('H', act { ActivatePaneDirection = 'Left' })
mapCtr('L', act { ActivatePaneDirection = 'Right' })
mapCtr('N', act { ActivatePaneDirection = 'Down' })
mapCtr('P', act { ActivatePaneDirection = 'Up' })
-- Tabs
map('Tab', act { ActivateTabRelative = 1 }, 'CTRL|SHIFT') -- vim używa c-tab
mapCtr('I', act { ActivateTabRelative = 1 })
mapCtr('J', act { ScrollByLine = 1 })
mapCtr('K', act { ScrollByLine = -1 })
mapCtr('D', act { ScrollByPage = 1 })
mapCtr('U', act { ScrollByPage = -1 })
-- Custom Actions
mapCtr('E', wezterm.action { EmitEvent = 'trigger-vim-with-scrollback' })
map('F1', wezterm.action { EmitEvent = 'toggle-ligatures'}, 'ALT' ) -- don't work maybe cinfig is stronger
map('F2', wezterm.action { EmitEvent = 'toggle-opacity'}, 'ALT' )
map('F3', wezterm.action { EmitEvent = 'open-file-manager'}, 'ALT' )
map('F7', wezterm.action { Search = { Regex = 'ERROR' } }, 'ALT')
--disable key
map('Enter', 'DisableDefaultAssignment', 'ALT')
-- Must be in the end 
return {
	color_scheme = 'Dracula',
	-- color_scheme = "Tomorrow",
	default_cursor_style = 'SteadyBar', -- the best in vim
	font_size = 11,
	font = wezterm.font_with_fallback(
		{ 'SauceCodePro Nerd Font Mono', 'FiraCode Nerd Font Mono' },
		{ weight = 'DemiLight' }
	),
	hide_tab_bar_if_only_one_tab = true,
	scrollback_lines = 10000,
	harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }, -- Disable Ligatures, can by set as toggle

	mouse_bindings = {
		-- Alt-Middle click pastes from the clipboard selection
		-- NOTE: Must be last to overwrite the existing Alt-Middle binding done by permute_any_or_no_mods.
		{
			mods = 'ALT',
			event = { Down = { streak = 1, button = 'Middle' } },
			action = wezterm.action { PasteFrom = 'Clipboard' },
		},
	},

	launch_menu = {
		{
			args = { 'btm' },
		},
		{
			label = 'note',
			args = { 'nvim' },
			cwd = wezterm.home_dir .. '/Documents/notebook',
		},
		{
			label = 'tor',
			args = { 'rtorrent' },
		},
	},
	inactive_pane_hsb = {
		saturation = 0.8,
		brightness = 0.7,
	},
	window_close_confirmation = 'NeverPrompt',
	enable_wayland = false,
	-- freetype_load_target = "HorizontalLcd", -- freetype_load_target = "Light",
	warn_about_missing_glyphs = false,
	keys = keys,
	-- TODO after setting
	-- automatically_reload_config = false,
	check_for_updates = true,
}

-- TODO
-- moje callbacki/i hooki przenieść do innego modułu
-- ogarnąć otwrcie url w przeglądarce
-- w vifm małe flickery i jak się przegląda obrazki to traci układ
-- jak sesje w mux? ustawić coś w ssh?
