#!/bin/luajit
local HELP = [[
Utils for 
List of the options:
	parameter → {active-window, region, monitor-[1/2]} - default active-window
	--menu -m show rofi with available actions
	--output -o → {file, clipboard} - default file
	--quality -q → {1 to 10}
	--help -h → show help

Examples:
screenshot.lua active-window -o=clipboard q=9

-- dependency: rofi, xclip, maim
-- TODO: choose monitor with resolution label
]]

local DIR= os.getenv('HOME') .. "/Pictures/Screens"
local stat, _, err = run('mkdir -p ' .. DIR, 'Can not create ' .. DIR)
assert(stat, err)
local STAMP = os.date('%y-%m-%dT%H%M%S')

-- parse arguments and flags
local args = cliparse(arg, 'target')
local target = 'active-window'
local output = 'file'
local quality
-- arguments
if args.target then
	target = args.target[1]
end
-- flags
if args.output or args.o then
	output = args.output or args.o
	output = output[1]
end
if args.quality or args.q then
	quality = args.quality or args.q
	quality = quality[1]
end

local function errorMsg(msg)
	log(msg, 'ERROR')
	notifyError(msg)
end

local function getPartialPath(active)
	local windowName = ''
	if active then
		local stat, name, err = run('xdotool getactivewindow getwindowname', "Can't get windowname")
		assert(stat, err)
		windowName = name[1].. '-'
	end
	return DIR .. '/' .. windowName .. STAMP
end

local function getActiveWindowId()
	local stat, windowNameId, err = run('xdotool getactivewindow', "Can't get windowname Id")
	assert(stat, err)
	return windowNameId[1] .. ' '
end

local function getMonitor(nr)
	local stat, monitor, err = run("xrandr --listactivemonitors | grep '+' | awk '{print $4, $3}' | awk -F'[x/+* ]' 'NR==" .. nr .. " {print $2\"x\"$4\"+\"$6\"+\"$7}'", "Can't get windowname Id")
	assert(stat, err)
	return monitor[1] .. ' '
end
-- DISPLAYS=$(xrandr --listactivemonitors | grep '+' | awk '{print $4, $3}' | awk -F'[x/+* ]' '{print $1,$2"x"$4"+"$6"+"$7}')

local cases = {
	["active-window"] = ' -i ' .. getActiveWindowId() ..  getPartialPath(true),
	['region'] = ' -s '  ..  getPartialPath() .. 'S',
	['monitor1'] = ' -g ' .. getMonitor(1) .. getPartialPath(),
	['monitor2'] = ' -g ' .. getMonitor(2) .. getPartialPath(),
}
local function takeScreen()
	local cmd = switch(cases, target)
	if quality then
		cmd =  ' -m ' .. quality .. ' ' .. cmd .. 'Q'
	end
	local stat, err
	run('sleep 0.5')
	if output=='file' then
		-- stat, _, err = run('maim  ' .. cmd .. 'sc.png', "Can't take screenshot")
		stat, _, err = run('maim -f webp ' .. cmd .. 'sc.webp', "Can't take screenshot")
	else -- clipboard doesn't work with webp
		-- can't combine with selection 
		-- error handling doesn't work
		stat, _, err = run('maim -i $(xdotool getactivewindow) | xclip -selection clipboard -t image/png', "Can't take screenshot to clipboard")
	end
	if stat then
		local split = split(cmd, '/')
		notify('Took screen ' ..  split[#split])
	else
		errorMsg(err)
	end
end

if args.help or args.h then
	print(HELP)
end

if args.menu or args.m then
	local keysFun = {
		['Alt-q'] = {'quality', function() quality = 10  end,}
	}
	local rofiOptions = {prompt = 'screenshot', width = '25ch', keys = keysFun}
	target, keybind = rofiMenu(cases, rofiOptions )
	output, keybind2 = rofiMenu({'file', 'clipboard'}, rofiOptions )
	keybind = keybind or keybind2

	if keysFun[keybind] then 
		keysFun[keybind][2]()
	end
end
takeScreen()

