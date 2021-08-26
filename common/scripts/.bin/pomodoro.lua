#!/bin/luajit
-- TODO 
package.path = '/home/miro/Documents/dotfiles/common/scripts/.bin/' .. package.path
util = require('scriptsUtil')

HELP = [[
Wrapper for openpomodoro-cli.
pomodoro.lua option [debug]
List of the options:
		add - add new pomodoro
		status - print status message 
		-h help - show help

-- dependency: openpomodoro-cli, rofi
]]

POMODORO_DIR = os.getenv('HOME') .. '/.pomodoro'
HISTORY_PATH = POMODORO_DIR .. '/history'
ALERT_PATH = POMODORO_DIR .. '/alert.mp3'

function add()
	local description = util.input('description')
	local tags = {}
	for line in io.lines(HISTORY_PATH) do
		local first, second = util.split(line, 'tags=')
		if second then 
			tags[second] = second
		end
	end
	local selectedTag = util.select(tags, 'Tags')

	assert(os.execute('pomodoro start "' .. description ..'" --tags ' .. selectedTag), 'Could not create pomodoro task')
end

function duplicate() 
	local output = io.popen('pomodoro repeat')
	assert(output ~= null, "Could not create pomodoro task")
	os.execute("dunstify 'Pomodoro started'")
	os.execute('ffplay -nodisp -autoexit -loglevel -8 ' .. ALERT_PATH)
end

function status() 
	local output = io.popen('pomodoro status --format "%!R ⏱ %c/%g"'):read('*a')
	assert(#output ~= 0, "Can not get pomodoro output")
	if output:find('❗️') then
		local modifiedDate = io.popen('stat -c%Y ' .. HISTORY_PATH):read('*a')
		assert(#output ~= 0, "Can not get modification file date")
		local diff = os.difftime(os.time(), tonumber(modifiedDate))
		if diff >= 300 then -- break 5 min
			duplicate()
		end	
		local first, second = util.split(output, '⏱')
		print(math.floor(diff/60) .. ' ' .. second)
	else 
		print(output)
	end
end

function sumDuration()
	local today = os.date('%Y%-%m%-%d')
	local sum = 0
	for line in io.lines(HISTORY_PATH) do
		if line:find(today) then
			local first, second = util.split(line, 'duration=')
			local duration = util.split(second, ' tags=')
			sum = sum + duration
		end
	end
	print(string.format('%.2f', sum/60))
end

local options = {
	["add"] = add,
	["status"] = status,
	["repeat"] = duplicate,
	["duration"] = sumDuration,
	["-h"]= function() print(HELP); os.exit() end,
	["#default"] = status
}
local switch = (function(name,args)
	local sw = options
	return (sw[name]and{sw[name]}or{sw["#default"]})[1](args)
end)

local exec, param = switch(arg[1])
local ok, val = pcall(exec, param)
if arg[2] == 'debug' and not ok then 
	print(val)
end

