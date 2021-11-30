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
	local f = io.popen ("/bin/hostname")
	local hostname = f:read("*a") or ""
	f:close()
	local hostname = hostname:gsub("%s+", "")

	local curentDir = pane:get_current_working_dir() 
	local dirPath = curentDir:gsub("file://" .. hostname, "")
	local success, stdout, stderr = wezterm.run_child_process({"xdg-open", dirPath })
end),
}
return actions
