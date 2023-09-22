local wezterm = require 'wezterm'

-- return list of files
local function scandir(directory)
	local t = {}
	local success, filename = wezterm.run_child_process { 'ls', '-1', directory }
	for i, filename in ipairs(wezterm.split_by_newlines(filename)) do
		t[i] = directory .. filename
	end
	return t
end

return {
	-- status in table bar
	wezterm.on('update-right-status', function(window, pane)
	  -- Workspace name
	  local stat = window:active_workspace()
	  local stat_color = "#bb9af7"
	  -- It's a little silly to have workspace name all the time
	  -- Utilize this to display LDR or current key table name
	  if window:active_key_table() then
		stat = window:active_key_table()
		stat_color = "#7dcfff"
	  end
	  if window:leader_is_active() then
		 stat = 'leader ❗'
		stat_color = "#f7768e"
	  end
	  -- Current working directory - doesn't work
	  local basename = function(s)
		local splits ={}
		for token in s:gmatch("([^/]+)") do
		   table.insert(splits, token)
		end
		return splits[#splits]
	  end
	  -- CWD and CMD could be nil (e.g. viewing log using Ctrl-Alt-l). Not a big deal, but check in case
	  local cwd = pane:get_current_working_dir()
	  cwd = cwd and basename(cwd) or ""
	  -- Current command
	  -- local cmd = pane:get_foreground_process_name()
	  -- cmd = cmd and basename(cmd) or ""

	local time = wezterm.strftime '%m-%d %H:%M'

	  window:set_right_status(wezterm.format({
		-- Wezterm has a built-in nerd fonts
		-- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
		{ Foreground = { Color = stat_color } },
		{ Text = "  " },
		{ Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
		{ Foreground = { Color = "#e0af68" } },
		{ Text = " | " },
		{ Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
		-- { Text = " | " },
		-- { Foreground = { Color = "#e0af68" } },
		-- { Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
		"ResetAttributes",
		{ Text = " | " },
		{ Text = wezterm.nerdfonts.md_clock .. "  " .. time },
		{ Text = "  " },
	  }))
	end),

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

	-- dynamic configuration based on hostname, if not exist than it will return value from the first table
	hostConfig = function(configs)
		local hostname = wezterm.hostname()
		for _,config in ipairs(configs) do
			if hostname == configs[1] then
			  return configs[2]
			end
		end
		return configs[1][2]
	end,

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

	-- return path from wezterm's working directory
	getPath = function(dir)
		local hostname = io.popen('hostname'):read('*a'):gsub('\n', '')
		local _, endIndex = dir:find(hostname)
		return dir:sub(endIndex + 1,#dir)
	end,
}
