local wezterm = require 'wezterm'
local plugins = require 'plugins'

-- some keybinding works only in a new pane key_map_preference = "Mapped"

local keys = {}
local act = wezterm.action
local function map(key, cmd, modKey)
	table.insert(keys, {
		key = key,
		mods = modKey,
		action = cmd,
	})
end

local function mapCS(key, cmd)
	map(key, cmd, 'CTRL|SHIFT')
end

-- ALT + number to activate that tab
for i = 1, 8 do
	map(tostring(i), wezterm.action { ActivateTab = i - 1 }, 'ALT')
end
mapCS('y', act { CopyTo = 'Clipboard' })
map('q', act { ClearScrollback = 'ScrollbackOnly' }, 'CTRL') -- leave one page
mapCS('Backspace', act { ClearScrollback = 'ScrollbackOnly' }) -- leave one page
mapCS('q', act { ClearScrollback = 'ScrollbackAndViewport' })
mapCS('\\', act { ClearScrollback = 'ScrollbackAndViewport' })
mapCS('r', 'SpawnWindow')
mapCS('Enter', 'SpawnWindow') -- stopped work in new version
-- Scroll
mapCS('j', act { ScrollByLine = 1 })
mapCS('k', act { ScrollByLine = -1 })
mapCS('d', act { ScrollByPage = 1 })
mapCS('u', act { ScrollByPage = -1 })
-- Pane
mapCS('?', act { SplitVertical = { domain = 'CurrentPaneDomain' } })
mapCS(':', act { SplitHorizontal = { domain = 'CurrentPaneDomain' } })
mapCS('w', act { CloseCurrentPane = { confirm = false } })
mapCS('m', 'TogglePaneZoomState') -- maximalize
mapCS('n', act { ActivatePaneDirection = 'Next' })
mapCS('p', act { ActivatePaneDirection = 'Prev' })
-- mapCS('N', act { ActivatePaneDirection = 'Down' })
-- Tabs
mapCS('a', act { SpawnTab = 'CurrentPaneDomain' })
mapCS('h', act { ActivateTabRelative = -1 })
mapCS('l', act { ActivateTabRelative = 1 })
mapCS('Tab', act { ActivateTabRelative = 1 })
-- Modes X,Space, O, U, E
-- mapCS('o', 'ShowLauncher')
mapCS('o', wezterm.action{ShowLauncherArgs={flags="FUZZY|LAUNCH_MENU_ITEMS"}})
map('F1', wezterm.action{ShowLauncherArgs={flags="FUZZY|KEY_ASSIGNMENTS"}}, 'ALT')
-- Custom Actions
mapCS('e', wezterm.action { EmitEvent = 'trigger-vim-with-scrollback' })
mapCS('s', plugins.openUrl)
map('F2', wezterm.action { EmitEvent = 'toggle-opacity' }, 'ALT')
map('F3', wezterm.action { EmitEvent = 'open-file-manager' }, 'ALT')
map('F4', wezterm.action { EmitEvent = 'toggle-ligatures' }, 'ALT') -- don't work 
map('F7', wezterm.action { Search = { Regex = 'ERROR' } }, 'ALT')
map('F12', 'ShowDebugOverlay', 'ALT')
--disable key
map('Enter', 'DisableDefaultAssignment', 'ALT')
-- key table don't work
-- map('m', wezterm.action{ ActivateKeyTable={ name="activate_pane", timeout_milliseconds=1000, replace_current=true, one_shot=true} }, "LEADER")

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
	leader = {key="a", mods="CTRL", timeout_milliseconds=1000},
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
