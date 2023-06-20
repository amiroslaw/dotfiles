local wezterm = require 'wezterm'

function scandir(directory)
	local t = {}
	local success, filename = wezterm.run_child_process { 'ls', '-1', directory }
	for i, filename in ipairs(wezterm.split_by_newlines(filename)) do
		t[i] = directory .. filename
	end
	return t
end

return {
	wezterm.on('trigger-vim-with-scrollback', function(window, pane)
		-- pane:get_logical_lines_as_text([nlines])
		-- scrollback_rows the total number of lines in the scrollback and viewport - all text (set in scrollback_lines)
		-- physical_top the top of the physical non-scrollback screen expressed as a stable index.
		local dimensions = pane:get_dimensions()
		local scrollback = pane:get_lines_as_text(dimensions.scrollback_rows) -- empty or physical_top? will copy only visible pane
		local name = os.tmpname()
		local f = io.open(name, 'w+')
		f:write(scrollback)
		f:flush()
		f:close()
		window:perform_action(
			wezterm.action { SpawnCommandInNewTab = {
				args = { 'nvim', name },
			} },
			pane
		)
		wezterm.sleep_ms(1000)
		os.remove(name)
	end),

	wezterm.on('toggle-ligatures', function(win, pane)
		local overrides = win:get_config_overrides() or {}
		if not overrides.harfbuzz_features then
			overrides.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
		else
			overrides.harfbuzz_features = nil
		end
		win:set_config_overrides(overrides)
	end),

	wezterm.on('toggle-opacity', function(win, pane)
		local overrides = win:get_config_overrides() or {}
		if not overrides.window_background_opacity or overrides.window_background_opacity < 1.0 then
			overrides.window_background_opacity = 1.0
		else
			overrides.window_background_opacity = 0.8
		end
		win:set_config_overrides(overrides)
	end),

	wezterm.on('open-file-manager', function(win, pane)
		local f = io.popen '/bin/hostname'
		local hostname = f:read '*a' or ''
		f:close()
		local hostname = hostname:gsub('%s+', '')

		local curentDir = pane:get_current_working_dir()
		local dirPath = curentDir:gsub('file://' .. hostname, '')
		local success, stdout, stderr = wezterm.run_child_process { 'xdg-open', dirPath }
	end),

	wezterm.on('user-var-changed', function(window, pane, name, value)
		local overrides = window:get_config_overrides() or {}
		if name == "ZEN_MODE" then
			local incremental = value:find("+")
			local number_value = tonumber(value)
			if incremental ~= nil then
				while (number_value > 0) do
					window:perform_action(wezterm.action.IncreaseFontSize, pane)
					number_value = number_value - 1
				end
				overrides.enable_tab_bar = false
			elseif number_value < 0 then
				window:perform_action(wezterm.action.ResetFontSize, pane)
				overrides.font_size = nil
				overrides.enable_tab_bar = true
			else
				overrides.font_size = number_value
				overrides.enable_tab_bar = false
			end
		end
		window:set_config_overrides(overrides)
	end),

	getColorscheme = function(dark, light, hour)
		if not light then
			return dark
		end
		local hour = hour and hour or 18
		local currentHour = tonumber(os.date '%H')
		if currentHour > 5 and currentHour < hour then
			return light
		else
			return dark
		end
	end,

	getRandomBg = function(bgPath)
		local bgDir = scandir(bgPath)
		local randomBgNr = math.random(#bgDir)
		return bgDir[randomBgNr]
	end,

	openUrl = wezterm.action {
		QuickSelectArgs = {
			label = 'open url',
			patterns = {
				'https?://\\S+',
			},
			action = wezterm.action_callback(function(window, pane)
				wezterm.open_with(window:get_selection_text_for_pane(pane))
			end),
		},
	},
}
