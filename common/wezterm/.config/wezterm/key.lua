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

local function mapCtr(key, cmd)
	map(key, cmd, 'CTRL')
end

-- ALT + number to activate that tab
for i = 1, 8 do
	map(tostring(i), wezterm.action { ActivateTab = i - 1 }, 'ALT')
end
mapCtr('Y', act { CopyTo = 'Clipboard' })
map('Backspace', act { ClearScrollback = 'ScrollbackOnly' }, 'CTRL|SHIFT') -- leave one page
mapCtr('|', act { ClearScrollback = 'ScrollbackAndViewport' })
map('Enter', 'SpawnWindow', 'CTRL|SHIFT')
-- Scroll
mapCtr('J', act { ScrollByLine = 1 })
mapCtr('K', act { ScrollByLine = -1 })
mapCtr('D', act { ScrollByPage = 1 })
mapCtr('U', act { ScrollByPage = -1 })
-- Pane
mapCtr('?', act { SplitVertical = { domain = 'CurrentPaneDomain' } })
mapCtr(':', act { SplitHorizontal = { domain = 'CurrentPaneDomain' } })
mapCtr('W', act { CloseCurrentPane = { confirm = false } })
mapCtr('M', 'TogglePaneZoomState') -- maximalize
mapCtr('N', act { ActivatePaneDirection = 'Next' })
mapCtr('P', act { ActivatePaneDirection = 'Prev' })
-- mapCtr('N', act { ActivatePaneDirection = 'Down' })
-- Tabs
mapCtr('A', act { SpawnTab = 'CurrentPaneDomain' })
mapCtr('H', act { ActivateTabRelative = -1 })
mapCtr('L', act { ActivateTabRelative = 1 })
map('Tab', act { ActivateTabRelative = 1 }, 'CTRL|SHIFT') -- vim używa c-tab
-- Modes X,Space, O, I, E
mapCtr('~', 'ShowDebugOverlay')
mapCtr('O', 'ShowLauncher')
-- Custom Actions
mapCtr('E', wezterm.action { EmitEvent = 'trigger-vim-with-scrollback' })
mapCtr('I', plugins.openUrl)
map('F1', wezterm.action { EmitEvent = 'toggle-ligatures' }, 'ALT') -- don't work maybe cinfig is stronger
map('F2', wezterm.action { EmitEvent = 'toggle-opacity' }, 'ALT')
map('F3', wezterm.action { EmitEvent = 'open-file-manager' }, 'ALT')
map('F7', wezterm.action { Search = { Regex = 'ERROR' } }, 'ALT')
--disable key
map('Enter', 'DisableDefaultAssignment', 'ALT')
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
}
