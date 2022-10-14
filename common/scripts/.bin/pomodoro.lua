#!/bin/env luajit
-- TODO
-- dailyGoal IDK if next actions is ok 
-- weird output
-- 24 notyfikacja 25 → break 1; output jest po tym jak się wykona skrypt czyli będzie notyfikacja
-- 4 notyfikacja 5 → work 0 lub

local HELP = [[
The pomodoro app for system bar like polybar with support of the work history.
pomodoro.lua option [-flags]
List of the options:
	add - add new pomodoro. If session is active it will update it, the  description and tag will remain the same if you won't provide them.
	status - print status message 
	info - shows daily spent time 
	history - display pomodoro history
	-h help - show help

flags (short options) in a format: -ca
	d - debug mode
	c - adds daily pomodoro counter in the status
	a - sound alert
	n - notification
	j - display pomodoro history in JSON format
	s - show secunds in the status - not implemented

Examples:
	pomodoro.lua status -ac - prints current status with daily ratio of the finished tasks, gives sound alert with notification if status changed

[module/pomodoro]
type = custom/script
exec = pomodoro.lua status -anc
click-middle = pomodoro.lua notify
click-right = pomodoro.lua stop -n
click-left = pomodoro.lua pause -n
interval = 60
-- dependency: taskwarrior, rofi, ffmpeg
]]

local POMODORO_DIR = os.getenv 'XDG_CONFIG_HOME' .. '/pomodoro'
local HISTORY_PATH = POMODORO_DIR .. '/history'
local CURRENT_PATH = POMODORO_DIR .. '/current'
local CONFIG_PATH = POMODORO_DIR .. '/settings'
local ALERT_PATH = POMODORO_DIR .. '/alert.mp3'
local STATUS_PATH = '/tmp/pomodoro'
local DELIMITER = '|'

local config = getConfigProperties(CONFIG_PATH)
local flags = splitFlags(arg[2])

function alert(msg)
	if flags['n'] then
		os.execute("dunstify Pomodoro '" .. msg .. "'")
	end
	if flags['a'] then
		os.execute('ffplay -nodisp -autoexit -loglevel -8 -volume 10 ' .. ALERT_PATH)
	end
end

local function changeTWstate(state)
	local taskId = io.open(CURRENT_PATH):read '*a'
	local ok, _, err
	if state == stateEnum.STOP then
		ok, _, err = run('task stop ' .. taskId)
	else
		ok, _, err = run('task start ' .. taskId)
	end
	assert(ok, 'Can not execute taskwarrior ' .. err[1])
end

function archiveTask(duration)
	duration = duration and duration or config['default_pomodoro_duration']
	local date = os.date '%Y-%m-%d'
	local file = io.open(HISTORY_PATH, 'a+')
	file:write(date .. DELIMITER .. duration, '\n')
	file:close()
end

function getModifiedDateDiff()
	local modifiedDate = io.popen('stat -c%Y ' .. STATUS_PATH):read '*a'
	assert(#modifiedDate ~= 0, 'Can not get modification file date')
	local diff = os.difftime(os.time(), tonumber(modifiedDate))
	return math.floor(diff / 60)
end

function duplicateTask()
	changeTWstate(stateEnum.WORK)
	io.open(STATUS_PATH, 'w'):write 'work'
end

function pauseStatus()
	local workDuration = io.open(STATUS_PATH):read '*a'
	io.write(workDuration, '  ')
	changeTWstate(stateEnum.STOP)
end

function breakStatus()
	local diff = getModifiedDateDiff()
	local breakDuration = config['default_break_duration'] and config['default_break_duration'] or 5
	io.write(diff, '  ')
	if diff >= tonumber(breakDuration) then
		io.open(STATUS_PATH, 'w'):write 'work'
		duplicateTask()
		workStatus()
		alert 'Break finished'
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
		changeTWstate(stateEnum.STOP)
		alert 'Work finished'
	end
end

function stopStatus()
	io.write('')
	os.execute('rm ' .. STATUS_PATH)
	if flags['n'] then
		os.execute "dunstify Pomodoro 'Finished'"
	end
	changeTWstate(stateEnum.STOP)
end

function getState()
	local file = io.open(STATUS_PATH)
	if not file then
		return stateEnum.STOP
	end
	local taskStatus = file:read '*a'
	local state
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

function pauseToggle()
	local state = getState()
	if state == stateEnum.BREAK then -- finish
		archiveTask()
		stopStatus()
	elseif state == stateEnum.WORK then -- pause
		local difftime = getModifiedDateDiff()
		local file = io.open(STATUS_PATH, 'w')
		file:write(difftime)
		file:close()
		stateEnum.PAUSE()
	elseif state == stateEnum.PAUSE then -- restart
		local file = io.open(STATUS_PATH, 'r+')
		local workDuration = file:read '*a'
		file:write 'restarted'
		file:close()
		assert( os.execute('touch -d "' .. workDuration .. ' minutes ago" ' .. STATUS_PATH) == 0, 'Can not change modification date')
		stateEnum.WORK()
		changeTWstate(stateEnum.WORK)
	end
end

function add()
	local okContext, _, err = run 'task context none'
	local ok, tasks, err = run 'task rc.verbose=nothing minimal'
	local selected = rofiMenu(tasks, '90%') -- TODO change rofiMenu for adding width height via table option
	local selectedId = selected:match '^%d+'
	local file
	if getState() == stateEnum.STOP then
		file = io.open(CURRENT_PATH, 'w')
		io.open(STATUS_PATH, 'w'):write 'work'
	else
		file = io.open(CURRENT_PATH, 'r+')
		local current = file:read '*a'
		file:seek 'set'
	end
	file:write(selectedId)
	file:close()
	changeTWstate(stateEnum.WORK)
end

function getHistoryTasks()
	local tasks = {}
	for line in io.lines(HISTORY_PATH) do
		table.insert(tasks, line)
	end
	return tasks
end
function getNextActionCount()
	local ok, nextCounter = run('task stat:pending +next count')
	if ok then
		return	nextCounter[1] 
	end
	return config['daily_goal']
end
function dailyInfo()
	local dailyGoal = config['daily_goal'] -- or getNextActionCount
	dailyGoal = dailyGoal and dailyGoal or 8
	local today = os.date '%Y.%m.%d'
	local sum = 0
	local taskCounter = 0
	for _, task in ipairs(getHistoryTasks()) do
		if task:find(today) then
			local taskInfo = split(task, DELIMITER)
			sum = sum + taskInfo[#taskInfo]
			taskCounter = taskCounter + 1
		end
	end

	local taskId = io.open(CURRENT_PATH):read '*a'
	local taskDesc = ''
	local ok, description = run('task _get ' .. taskId .. '.description')
	if ok then
		taskDesc = description[1]
	end
	return taskCounter .. '/' .. dailyGoal, os.date('%M:%S', sum), taskDesc
end

function annotate()
	local takskRatio, sumDuration, taskDescription  = dailyInfo()
	notify('Progress: ' .. takskRatio .. '\nDaily duration: ' .. sumDuration .. '\nCurrent task:' .. taskDescription)
end

stateEnum = enum { STOP = function() print '' end, BREAK = breakStatus, WORK = workStatus, PAUSE = pauseStatus, }

local defaultOption = 'status'
local options = {
	['add'] = add,
	['pause'] = pauseToggle,
	['stop'] = stopStatus,
	['repeat'] = duplicateTask,
	['status'] = getState,
	['notify'] = annotate,
	['info'] = function() print(dailyInfo()) end,
	['-h'] = function() print(HELP) os.exit() end,
}
local switch = function(name, args)
	local sw = options
	return (sw[name] and { sw[name] } or { sw[defaultOption] })[1](args)
end

local action = arg[1] and arg[1] or defaultOption
if action == 'menu' then
	action = rofiMenu(options)
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

-- not used
-- function getDuration()
-- 	local ok, report, err = run 'task rc.verbose=nothing pomodoro'
-- 	assert(ok, 'Can not get duration')
-- 	return report[1]:match '(%d+)min'
-- end

