local wezterm = require 'wezterm'
local plugins = require 'plugins'

local keys = {}
local act = wezterm.action
local function map(key, cmd, modKey)
	table.insert(keys, {
		key = key,
		mods = modKey,
		action = cmd,
	})
end

local function mapCtrShift(key, cmd)
	map(key, cmd, 'CTRL|SHIFT')
end

-- ALT + number to activate that tab
for i = 1, 8 do
	map(tostring(i), wezterm.action { ActivateTab = i - 1 }, 'ALT')
end
mapCtrShift('y', act { CopyTo = 'Clipboard' })
map('q', act { ClearScrollback = 'ScrollbackOnly' }, 'CTRL') -- leave one page
mapCtrShift('q', act { ClearScrollback = 'ScrollbackAndViewport' })
mapCtrShift('r', 'SpawnWindow')
-- mapCtrShift('Enter', 'SpawnWindow') -- stopped work in new version
-- Scroll
mapCtrShift('j', act { ScrollByLine = 1 })
mapCtrShift('k', act { ScrollByLine = -1 })
mapCtrShift('d', act { ScrollByPage = 1 })
mapCtrShift('u', act { ScrollByPage = -1 })
-- Pane
mapCtrShift('/', act { SplitVertical = { domain = 'CurrentPaneDomain' } })
mapCtrShift(';', act { SplitHorizontal = { domain = 'CurrentPaneDomain' } })
mapCtrShift('w', act { CloseCurrentPane = { confirm = false } })
mapCtrShift('m', 'TogglePaneZoomState') -- maximalize
mapCtrShift('n', act { ActivatePaneDirection = 'Next' })
mapCtrShift('p', act { ActivatePaneDirection = 'Prev' })
-- mapCtrShift('N', act { ActivatePaneDirection = 'Down' })
-- Tabs
mapCtrShift('a', act { SpawnTab = 'CurrentPaneDomain' })
mapCtrShift('h', act { ActivateTabRelative = -1 })
mapCtrShift('l', act { ActivateTabRelative = 1 })
mapCtrShift('Tab', act { ActivateTabRelative = 1 })
-- Modes X,Space, O, U, E
-- mapCtrShift('o', 'ShowLauncher')
mapCtrShift('o', wezterm.action{ShowLauncherArgs={flags="FUZZY|LAUNCH_MENU_ITEMS"}})
map('F1', wezterm.action{ShowLauncherArgs={flags="FUZZY|KEY_ASSIGNMENTS"}}, 'ALT')
-- Custom Actions
mapCtrShift('e', wezterm.action { EmitEvent = 'trigger-vim-with-scrollback' })
mapCtrShift('s', plugins.openUrl)
map('F2', wezterm.action { EmitEvent = 'toggle-opacity' }, 'ALT')
map('F3', wezterm.action { EmitEvent = 'open-file-manager' }, 'ALT')
map('F4', wezterm.action { EmitEvent = 'toggle-ligatures' }, 'ALT') -- don't work 
map('F7', wezterm.action { Search = { Regex = 'ERROR' } }, 'ALT')
map('F12', 'ShowDebugOverlay', 'ALT')
--disable key
map('Enter', 'DisableDefaultAssignment', 'ALT')
-- key table
map('m', wezterm.action{ ActivateKeyTable={ name="activate_pane", timeout_milliseconds=1000, } }, "LEADER")

local mouse_bindings = {
	{ -- Alt-Middle click pastes from the clipboard selection
		-- NOTE: Must be last to overwrite the existing Alt-Middle binding done by permute_any_or_no_mods.
		mods = 'ALT',
		event = { Down = { streak = 1, button = 'Middle' } },
		action = wezterm.action { PasteFrom = 'Clipboard' },
	},
}

return {
	keys = keys,
	mouse_bindings = mouse_bindings,
	leader = {key="i", mods="CTRL|SHIFT"},
	activate_pane = {
      {key="LeftArrow", action=wezterm.action{ActivatePaneDirection="Left"}},
      {key="h", action=wezterm.action{ActivatePaneDirection="Left"}},

      {key="RightArrow", action=wezterm.action{ActivatePaneDirection="Right"}},
      {key="l", action=wezterm.action{ActivatePaneDirection="Right"}},

      {key="UpArrow", action=wezterm.action{ActivatePaneDirection="Up"}},
      {key="k", action=wezterm.action{ActivatePaneDirection="Up"}},

      {key="DownArrow", action=wezterm.action{ActivatePaneDirection="Down"}},
      {key="j", action=wezterm.action{ActivatePaneDirection="Down"}},
    },
}
