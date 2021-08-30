#!/bin/luajit
--[[ stop - nie ma pliku current
running - jest plik status
pause - duration time in status
break - pusty plik w status
running - jest plik z danymi o tasku ale duration jest nulem  ]]

-- TODO 
-- wyświetlać daily goals
-- options - daily_goal albo zmieniać config lub czytać z linni
-- krótkie opcje -sn short format - without taskCounter, notification itp.
-- dodawanie pomodoro przez cli
-- przy stopie dodawać niedokończony czas - test
-- history json
-- maybe use coroutine when when adds alert
-- weird output
-- 24 notyfikacja 25 → break 1; output jest po tym jak się wykona skrypt czyli będzie notyfikacja
-- 4 notyfikacja 5 → work 0 lub
-- 5 notyfikacja 6 
package.path = '/home/miro/Documents/dotfiles/common/scripts/.bin/' .. package.path
util = require('scriptsUtil')

HELP = [[
The pomodoro app for system bar like polybar with support of the work history.
pomodoro.lua option [-flags]
List of the options:
	add - add new pomodoro
	status - print status message 
	duration - shows daily spent time 
	history - display pomodoro history
	-h help - show help

flags (short options) in a format: -ca
	d - debug mode
	c - adds daily pomodoro counter in the status
	a - sound alert with notification
	j - display pomodoro history in JSON format
	s - show secunds in the status - not implemented

Examples:
	pomodoro.lua history -j | jq '.[].tag' - prints history in the JSON format 
	pomodoro.lua status -ac - prints current status with daily ratio of the finished tasks, gives sound alert with notification if status changed
-- dependency: rofi, ffmpeg
]]
POMODORO_DIR = os.getenv('XDG_CONFIG_HOME') .. '/pomodoro'
HISTORY_PATH = POMODORO_DIR .. '/history'
CURRENT_PATH = POMODORO_DIR .. '/current'
CONFIG_PATH = POMODORO_DIR .. '/settings'
ALERT_PATH = POMODORO_DIR .. '/alert.mp3'
STATUS_PATH = '/tmp/pomodoro'
DELIMITER = '|'

config = util.getConfigProperties(CONFIG_PATH)
flags = util.splitFlags(arg[2])

function getHistoryTasks()
	local tasks = {}
	for line in io.lines(HISTORY_PATH) do
		table.insert(tasks, line)
	end
	return tasks
end

function archiveTask(duration)
	local current = io.open(CURRENT_PATH):read('*a')
	local file = io.open(HISTORY_PATH, 'a+')
	file:write(current .. duration, '\n')
	file:close()
end

function getModifiedDateDiff()
	local modifiedDate = io.popen('stat -c%Y ' .. STATUS_PATH):read('*a')
	assert(#modifiedDate ~= 0, 'Can not get modification file date')
	local diff = os.difftime(os.time(), tonumber(modifiedDate))
	return math.floor(diff/60)
end

function duplicateTask() 
	local current = io.open(CURRENT_PATH):read('*a')
	local taskInfo = util.split(current, DELIMITER)
	taskInfo[1] = os.date('%Y-%m-%dT%H:%M:%S')
	taskInfo[#taskInfo] = nil
	local file = io.open(CURRENT_PATH, 'w')
	file:write(table.concat(taskInfo, DELIMITER) .. DELIMITER)
	file:close()
	io.open(STATUS_PATH, 'w'):write(taskInfo[3])
end

function pauseStatus()
	local workDuration = io.open(STATUS_PATH):read('*a')
	io.write(workDuration, '  ')
end

function breakStatus()
	local diff = getModifiedDateDiff()
	local breakDuration = config['default_break_duration'] and config['default_break_duration'] or 5
	io.write(diff, '  ')
	if diff >= tonumber(breakDuration) then
		duplicateTask()
		workStatus()
		alert('Break finished')
	end	
end

function workStatus() 
	local diff = getModifiedDateDiff()
	io.write(diff, '  ')

	local defaultDuration = config['default_pomodoro_duration'] and config['default_pomodoro_duration'] or 25
	if diff >= tonumber(defaultDuration) then
		archiveTask(defaultDuration)
		io.open(STATUS_PATH, 'w'):close()
		breakStatus()
		alert('Work finished')
	end	
end

function getState()
	local file = io.open(STATUS_PATH)
	if not file then 
		return stateEnum.STOP 
	end 
	local taskStatus = file:read('*a')
	if taskStatus == '' then 
		state = stateEnum.BREAK
	elseif type(tonumber(taskStatus)) == 'number' then 
		state = stateEnum.PAUSE
	else
		state = stateEnum.WORK
	end
	file:close()
	return state
end

function add()
	assert(os.execute( "test -f " .. STATUS_PATH ) ~= 0, 'Task exist')

	local description = util.input('description')
	local tags = {}
	for _, line in ipairs(getHistoryTasks()) do
		local taskInfo = util.split(line, DELIMITER)
		if taskInfo[2] then 
			tags[taskInfo[2]] = taskInfo[2]
		end
	end
	local selectedTag = util.select(tags, 'Tags')

	io.open(STATUS_PATH, 'w'):write(description)
	local file = io.open(CURRENT_PATH, 'w')
	file:write(os.date('%Y-%m-%dT%H:%M:%S'), DELIMITER, selectedTag, DELIMITER, description, DELIMITER)
	file:close()
end

function alert(msg)
	if flags['a'] then 
		os.execute("dunstify Pomodoro '" .. msg .. "'")
		os.execute('ffplay -nodisp -autoexit -loglevel -8 -volume 10 ' .. ALERT_PATH)
	end
end

function stop()
	os.execute('rm ' .. STATUS_PATH)
	stateEnum.STOP()
end

function pauseToggle()
	local state = getState()
	if state == stateEnum.BREAK then -- finish
		local stoppedDuration = io.open(CURRENT_PATH):read('*a')
		archiveTask(stoppedDuration)
		stop()
	elseif state == stateEnum.WORK then -- pause
		local difftime = getModifiedDateDiff()
		local file = io.open(STATUS_PATH, 'w')
		file:write(difftime)
		file:close()
		stateEnum.PAUSE()
	elseif state == stateEnum.PAUSE then -- restart
		local file = io.open(STATUS_PATH, 'r+')
		local workDuration = file:read('*a')
		file:write('restarted')
		file:close()
		assert(os.execute('touch -d "' .. workDuration .. ' minutes ago" ' .. STATUS_PATH) == 0, 'Can not change modification date')
		stateEnum.WORK()
	end
end

function dailyInfo()
	local today = os.date('%Y%-%m%-%d')
	local sum = 0
	local taskCounter = 0
	for _, task in ipairs(getHistoryTasks()) do
		if task:find(today) then
			local taskInfo = util.split(task, DELIMITER)
			sum = sum + taskInfo[#taskInfo]
			taskCounter = taskCounter + 1
		end
	end
	return taskCounter .. '/' .. config['daily_goal'], os.date('%M:%S', sum)
end

function notify()
	local takskRatio, duration = dailyInfo()
	local currentTask = io.open(CURRENT_PATH):read('*a')
	util.notify(currentTask:gsub(DELIMITER, '\n') .. dailyInfo())
end

function history()
	if flags['j'] then 
		tasksJson = '['
		for _, historyEntry in ipairs(getHistoryTasks()) do
			local task = util.split(historyEntry, DELIMITER)
			tasksJson = tasksJson .. '{"description":"' .. task[3] .. '",' .. '"tag":"' .. task[2] .. '","duration":' .. task[4] .. ', "date":"' .. task[1] .. '"},' end 
		io.write(tasksJson:sub(1,-2), ']')
	else
		print(io.open(HISTORY_PATH):read('*a'))
	end
end

stateEnum = util.const({STOP = function() print'' end, BREAK = breakStatus, WORK = workStatus, PAUSE = pauseStatus})

local defaultOption = 'status'
local options = {
	["add"] = add,
	["repeat"] = duplicateTask,
	["pause"] = pauseToggle,
	["status"] = getState,
	["notify"] = function() print(notify()) end,
	["stop"] = function() print(stop()) end,
	["history"] = function() print(history()) end,
	["duration"] = function() print(dailyInfo()) end,
	["-h"]= function() print(HELP); os.exit() end,
}
local switch = (function(name,args)
	local sw = options
	return (sw[name]and{sw[name]}or{sw[defaultOption]})[1](args)
end)

local action = arg[1] and arg[1] or defaultOption
if action == 'menu' then
	action = util.menu(options)
end
local exec, param = switch(action)
local ok, val = pcall(exec, param)

if flags['d'] and not ok then 
	print(val)
end
if flags['c'] then 
	local ratio = dailyInfo()
	io.write(ratio)
end
