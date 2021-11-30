local wezterm = require 'wezterm'

actions = {

wezterm.on('trigger-vim-with-scrollback', function(window, pane)
	local scrollback = pane:get_lines_as_text()
	local name = os.tmpname()
	local f = io.open(name, 'w+')
	f:write(scrollback)
	f:flush()
	f:close()
	window:perform_action(
		wezterm.action { SpawnCommandInNewWindow = {
			args = { 'nvim', name },
		} },
		pane
	)
	wezterm.sleep_ms(1000)
	os.remove(name)
end),

wezterm.on("toggle-ligatures", function(win, pane)
	local overrides = win:get_config_overrides() or {}
	if not overrides.harfbuzz_features then
		overrides.harfbuzz_features = {"calt=0", "clig=0", "liga=0"}
	else
		overrides.harfbuzz_features = nil
	end
	win:set_config_overrides(overrides)
end),

wezterm.on("toggle-opacity", function(win, pane)
  local overrides = win:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 0.5;
  else
    overrides.window_background_opacity = nil
  end
  win:set_config_overrides(overrides)
end),

wezterm.on('open-file-manager', function(win, pane)
	local delimeter = '/home'
	local curentDir = pane:get_current_working_dir() .. delimeter
	local split = {}
	for match in curentDir:gmatch('(.-)'.. delimeter) do
		table.insert(split, match)
	end
	table.remove(split, 1)
	local dirPath = table.concat(split)

	local success, stdout, stderr = wezterm.run_child_process({"xdg-open", delimeter .. dirPath })
end),
}
return actions
