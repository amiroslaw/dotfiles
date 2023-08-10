#!/bin/env luajit
-- TODO
-- dailyGoal IDK if next actions is ok 
-- weird output
-- 24 notyfikacja 25 → break 1; output jest po tym jak się wykona skrypt czyli będzie notyfikacja
-- 4 notyfikacja 5 → work 0 lub
-- debug option has error
-- IDK how to reload polybar module I can reload whole polybar
-- pkill -USR1 polybar

local HELP = [[
The pomodoro app for system bar like polybar with support of the work history.
pomodoro.lua option [-flags]
List of the options:
	add - add new pomodoro. If session is active it will update it, the  description and tag will remain the same if you won't provide them.
	status - print status message 
	info - shows daily spent time 
	history - display pomodoro history
	menu - list of the options
	-h help - show help

flags (short options) in a format: -ca
	d - debug mode
	c - adds daily pomodoro counter in the status
	a - sound alert
	n - notification
	j - display pomodoro history in JSON format  - not implemented
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
local flags = cliparse(arg)

function alert(msg)
	if flags['n'] then
		os.execute("notify-send Pomodoro '" .. msg .. "'")
	end
	if flags['a'] then
		os.execute('ffplay -nodisp -autoexit -loglevel -8 -volume 10 ' .. ALERT_PATH)
	end
end

local function archiveTask(duration)
	duration = duration and duration or config['default_pomodoro_duration']
	local date = os.date '%Y-%m-%d'
	local file = io.open(HISTORY_PATH, 'a+')
	file:write(date .. DELIMITER .. duration, '\n')
	file:close()
end

local function getModifiedDateDiff()
	local modifiedDate = io.popen('stat -c%Y ' .. STATUS_PATH):read '*a'
	assert(#modifiedDate ~= 0, 'Can not get modification file date')
	local diff = os.difftime(os.time(), tonumber(modifiedDate))
	return math.floor(diff / 60)
end

local function changeTWstate(state)
	local taskUuid = io.open(CURRENT_PATH):read '*a'
	local ok, _, err
	if state == stateEnum.STOP then
		ok, _, err = run('task stop ' .. taskUuid, 'Can not stop task: ' .. taskUuid)
		assert(ok, err) 
		alert 'Work stopped'
	else
		ok, _, err = run('task start ' .. taskUuid, 'Can not stop task: ' .. taskUuid)
		assert(ok, err) 
		alert 'Work started'
	end
end

local function duplicateTask()
	io.open(STATUS_PATH, 'w'):write 'work'
	changeTWstate(stateEnum.WORK)
end

local function pause()
	local difftime = getModifiedDateDiff()
	local file = io.open(STATUS_PATH, 'w')
	file:write(difftime)
	file:close()
end

local function getState()
	local file = io.open(STATUS_PATH)
	if not file then
		return stateEnum.STOP
	end
	local taskStatus = file:read '*a'
	file:close()
	local state
	if taskStatus == '' then
		state = stateEnum.BREAK
	elseif type(tonumber(taskStatus)) == 'number' then
		state = stateEnum.PAUSE
	else
		state = stateEnum.WORK
	end
	return state
end

local function pauseStatus(toggle)
	local workDuration = io.open(STATUS_PATH):read '*a'
	io.write(workDuration, '  ')
	if toggle then
		changeTWstate(stateEnum.STOP)
	end
end

local function workStatus()
	local defaultDuration = config['default_pomodoro_duration'] and config['default_pomodoro_duration'] or 25
	local diff = getModifiedDateDiff()
	io.write(diff, '  ')
	if diff >= tonumber(defaultDuration) then
		archiveTask(defaultDuration)
		io.open(STATUS_PATH, 'w'):close()
		changeTWstate(stateEnum.STOP)
		return
	end
end

local function breakStatus()
	local breakDuration = config['default_break_duration'] and config['default_break_duration'] or 5
	local diff = getModifiedDateDiff()
	io.write(diff, '  ')
	if diff >= tonumber(breakDuration) then
		io.open(STATUS_PATH, 'w'):write 'work'
		duplicateTask()
		workStatus()
		return
	end
end

local function stopStatus()
	local state = getState()
	if state == stateEnum.STOP then
		ok, count, err = run('task +ACTIVE count', 'Can not get active task information')
		assert(ok, err) 
		io.write(count[1])
	else
		os.execute('rm ' .. STATUS_PATH)
		alert 'Finished'
		changeTWstate(stateEnum.STOP)
	end
	io.write('  ')
end

local function restart()
		local file = io.open(STATUS_PATH, 'r+')
		local workDuration = file:read '*a'
		file:write 'Restarted'
		file:close()
		assert( os.execute('touch -d "' .. workDuration .. ' minutes ago" ' .. STATUS_PATH) == 0, 'Can not change modification date')
		changeTWstate(stateEnum.WORK)
end

function pauseToggle()
	local state = getState()
	if state == stateEnum.BREAK then -- finish
		archiveTask()
		stopStatus()
	elseif state == stateEnum.WORK then -- pause
		pause()
		pauseStatus(true)
	elseif state == stateEnum.PAUSE then -- restart
		restart()
		workStatus()
	elseif state == stateEnum.STOP then -- repeat
		io.open(STATUS_PATH, 'w'):write 'work'
		workStatus()
	end
end

local function setCurrentTask(uuid)
	os.execute('rm ' .. CURRENT_PATH)
	local file = io.open(CURRENT_PATH, 'w')
	uuid = split(uuid[1], '-')
	file:write(uuid[1])
	file:close()
end

local function add()
	local STOP = '#stop'
	local PAUSE = '#pause'
	local okContext, _, err = run('task context none',  'Could not switch context')
	-- assert(okContext, err) -- return error code 2 if it did not have context
	--task rc.verbose=nothing minimal - wrap lines 
	local ok, tasks, err = run('task rc.verbose=nothing minimal',  'Could not get task list')
	assert(ok, 'err')

	table.insert(tasks, STOP)
	table.insert(tasks, PAUSE)
	local selected, code = rofiMenu(tasks, {prompt = 'Start pomodoro task', width = '94%'})
	if not code then
		return true
	end
	if selected == STOP then
		stopStatus()
		return
	elseif selected == PAUSE then
		pauseStatus()
		return
	end
	-- local selectedId = selected:match '^%d+'
	local selectedId = selected:match '^%s*%d+'
	local okUuid, uuid, err = run('task _uuid ' .. selectedId, 'Could not fetch task uuid')
	assert(okUuid, err)
	setCurrentTask(uuid)
	io.open(STATUS_PATH, 'w'):write 'work'
	changeTWstate(stateEnum.WORK)
end

function getHistoryTasks()
	local tasks = {}
	for line in io.lines(HISTORY_PATH) do
		table.insert(tasks, line)
	end
	return tasks
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
	local taskUuid = io.open(CURRENT_PATH):read '*a'
	local taskDesc = ''
	local ok, description = run('task _get ' .. taskUuid .. '.description')
	if ok then
		taskDesc = description[1]
	end
	return taskCounter .. '/' .. dailyGoal, os.date('%M:%S', sum), taskDesc
end

function annotate()
	local takskRatio, sumDuration, taskDescription  = dailyInfo()
	notify('Progress: ' .. takskRatio .. '\nDaily duration: ' .. sumDuration .. '\nCurrent task:' .. taskDescription)
end

function getNextActionCount()
	local ok, nextCounter = run('task stat:pending +next count')
	if ok then
		return	nextCounter[1] 
	end
	return config['daily_goal']
end

stateEnum = enum { STOP = stopStatus, BREAK = breakStatus, WORK = workStatus, PAUSE = pauseStatus, }

local function modify()
	local cmd = [[ timew summary :ids :week | awk '/@/ {out=""; startIndex=1; { if($1 ~/W/){ startIndex=4;} for(i=startIndex;i<=NF;i++)if($i !~/:/) out=out" "$i};  if($(NF-3) ~/:/) {print out" "$(NF-1)} else {print out" "$NF};  o=""}' | tac ]]
	local ok, tasks, err = run(cmd, 'Error: modification')
	assert(ok, err) 
	local action, code = rofiMenu({'lengthen', 'shorten'}, {prompt = 'modify interval'})
	assert(code, "Can not modify")
	local selectedTask, code = rofiMenu(tasks, {prompt = 'choose task (empty == last)', width = '94%'})
	selectedTask = code and selectedTask or ' @1'
	local taskId = selectedTask:match '^%s@%d+'
	local minutes = rofiNumberInput('Minutes')
	local ok, _, err = run('timew ' .. action .. taskId .. ' ' .. minutes .. 'min', 'Could not modify task: ' .. taskId)
	assert(ok, err) 
end

local function synchronise()
	local ok, _, err = run('~/.config/task/scripts/sync.sh', 'Did not synchronise taskwarrior')
	if ok then
		msg = {['Synchronised'] = 'green'}
		notify('Taskwarrior', next(msg), msg)
	else
		notifyError(err)
	end
end

local defaultOption = 'status'
local options = {
	['add'] = add,
	['pause'] = pauseToggle,
	['stop'] = stopStatus,
	['repeat'] = duplicateTask,
	['status'] = getState,
	['sync'] = synchronise,
	['notify'] = annotate,
	['modify'] = modify,
	['info'] = function() print(dailyInfo()) end,
	['-h'] = function() print(HELP) os.exit() end,
}
local switch = function(name, args)
	local sw = options
	return (sw[name] and { sw[name] } or { sw[defaultOption] })[1](args)
end

local action = arg[1] and arg[1] or defaultOption
if action == 'menu' then
	action = rofiMenu(options, {prompt = 'Pomodoro menu'})
end
local exec, param = switch(action)
local ok, err = pcall(exec, param)

if flags['d'] and not ok then
	print(err)
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

