#!/bin/luajit
local HELP = [[
Utils for 
List of the options:
	parameter → {active-window, region, monitor-[1/2]} - default active-window
	--menu -m show rofi with available actions
	--output -o → {file, clipboard} - default file
	--quality -q → {1 to 10}
	--ocr -r 
	--help -h → show help

Examples:
screenshot.lua active-window -o=clipboard q=9

-- dependency: rofi, xclip, maim, tesseract for ocr
-- TODO: choose monitor with resolution label
]]

local DIR= os.getenv('HOME') .. "/Pictures/Screens"
local stat, _, err = run('mkdir -p ' .. DIR, 'Can not create ' .. DIR)
assert(stat, err)
local STAMP = os.date('%y-%m-%dT%H%M%S')
local OCR_DIR= '/tmp/lua/'
local OCR_IMG= OCR_DIR .. '/ocr.png'

-- parse arguments and flags
local args = cliparse(arg, 'target')
local target = 'active-window'
local output = 'file'
local format = 'webp'
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
	os.exit(1)
end

local function getPartialPath(active)
	local windowName = ''
	if active then
		local stat, name, err = run('xdotool getactivewindow getwindowname', "Can't get windowname")
		assert(stat, err)
		windowName = name[1]:gsub('/', ''):gsub('$','')
	end
	return string.format('%s/%s-%s', DIR, windowName, STAMP)
end

local function getActiveWindowId()
	local stat, windowNameId, err = run('xdotool getactivewindow', "Can't get windowname Id")
	assert(stat, err)
	return windowNameId[1]
end

local function getMonitor(nr)
	local cmd = string.format("xrandr --listactivemonitors | grep '+' | awk '{print $4, $3}' | awk -F'[x/+* ]' 'NR==%d {print $2\"x\"$4\"+\"$6\"+\"$7}'", nr)
	local stat, monitor, err = run(cmd , "Can't get windowname Id")
	assert(stat, err)
	return monitor[1]
end
-- DISPLAYS=$(xrandr --listactivemonitors | grep '+' | awk '{print $4, $3}' | awk -F'[x/+* ]' '{print $1,$2"x"$4"+"$6"+"$7}')

local function ocr()
	local textFile = createTmpFile({prefix = 'ocr'})
	local stat, _, err = run('maim -m 1 -s ' .. OCR_IMG, 'Could not take screenshot')
	assert(stat, err)
	local ocrCmd = ('tesseract %q %q'):format(OCR_IMG, textFile)
	stat, _, err = run(ocrCmd, 'Could not convert image to text')
	assert(stat, err)

	local text = assert(io.open(textFile .. '.txt'):read('*all'), 'filed to read file .. ' )
 -- Source: https://askubuntu.com/a/1276441/782646
-- sed -i 's/\x0c//' "$textFile"
	-- local xclipCmd = ('echo %q | xclip -selection clip'):format(text) -- lose new lines
	local xclipCmd = ('xclip -selection clip < %s.txt'):format(textFile)
	stat, _, err = run(xclipCmd, 'Could not copy text')
	assert(stat, err)
	if text == '' then
		notifyError('no text was detected')	
	else
		notify('ocr', text)
	end
	os.execute(('rm %q %q'):format(OCR_IMG, textFile))
end

-- param and path
local cases = {
	["active-window"] = {' -i ' .. getActiveWindowId(), getPartialPath(true)},
	['region'] = {' -s ',  getPartialPath() .. 'S'},
	['monitor1'] = {' -g ' .. getMonitor(1), getPartialPath()},
	['monitor2'] = {' -g ' .. getMonitor(2), getPartialPath()},
	['ocr'] = {'ocr'},
}
local function takeScreen()
	local params = switch(cases, target)
	if quality then
		params[1] = params[1] .. ' -m ' .. quality
		params[2] = params[2] .. 'Q'
	end
	local stat, err
	local path
	run('sleep 0.1')
	if output=='file' then
		-- stat, _, err = run('maim  ' .. params .. 'sc.png', "Can't take screenshot")
		path = ('%ssc.%s'):format(params[2], format)
		local cmd = string.format('maim -f %s %s %q', format, params[1], path)
		stat, _, err = run(cmd, "Can't take screenshot")
	else -- clipboard doesn't work with webp
		-- can't combine with selection 
		-- error handling doesn't work
		stat, _, err = run('maim -i $(xdotool getactivewindow) | xclip -selection clipboard -t image/png', "Can't take screenshot to clipboard")
	end
	if stat then
		local split = split(path, '/')
		notify('Took screen ' ..  split[#split])
	else
		errorMsg(err)
	end
end

if args.help or args.h then
	print(HELP)
	os.exit()
end

if args.orc or args.r then
	xpcall(ocr, errorMsg)
	os.exit()
end

if args.menu or args.m then
	local keyQuality = { ['Alt-q'] = {'hight quality', function() quality = 10  end,}}
	local keyJpg = { ['Alt-j'] = {'jpg format', function() format = 'jpg'  end,},} -- png has reversed quality values
	target, keyQ = rofiMenu(cases, {prompt = 'screenshot', width = '25ch', keys = keyQuality})
	if target == 'ocr' then
		xpcall(ocr, errorMsg)
		os.exit()
	end

	output, keyJ = rofiMenu({'file', 'clipboard'}, {prompt = 'screenshot', width = '25ch', keys = keyJpg} )

	if keyQuality[keyQ] then 
		keyQuality[keyQ][2]()
	end
	if keyJpg[keyJ] then 
		keyJpg[keyJ][2]()
	end
end
takeScreen()
os.exit()
