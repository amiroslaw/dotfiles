#!/usr/bin/luajit

local function help()
	print [[
Utility script for managing the pueue program. It's a tool that processes a queue of shell commands.
Using: mpv.lua [action] [group] [option]

Actions:
	--menu -m → 
	--kill, -k →
	--restart, -r →
	--delete, -d →
	--help, -h → Show help

examples:
qu.lua --kill queueGroupName
qu.lua --restart queueGroupName

In order to change stream format and options it's needed to add the profiles `stream` and `stream-popup` into the mpv.conf file.
Dependencies: pueue, rofi, notify-send, jq, zenity

Testing:
trzeba najpierw kill aby usunąć - jak jest running to nie usunie tego joba

TODO 
jest problem jak dodaje listę z yt - ona się odpala jako dodatkowy job - zmienić funkcje w mpv.lua i tam ucinać parametr z list
przy kill mpv i ponownym uruchomieniu nie zapisuje się gdzie mpv przerwał odtwarzanie, to jest normalne zachowanie przy np. killall mpv
	]]
end

local function errorMsg(msg)
	print(msg)
	log(msg, 'ERROR')
	notifyError(msg)
end

local args = cliparse(arg, 'params')
local params = args.params and args.params or {}

-- stop
local function killQueue(group)
	group = group and group or 'default'
	local killStatus, _, err = run(('pueue kill -g %s'):format(group))
	assert(killStatus, err)
end

-- A killed job will be restarted.
local function restartQueue(group)
	group = group and group or 'default'
	local restartStatus, err = run(('pueue restart -i -g %s'):format(group))
	assert(restartStatus, err)
	local startStatus, err = run(('pueue start -g %s'):format(group))
	assert(startStatus, err)
end

-- remove all jobs in a group
local function resetQueue(group)
	group = group and group or 'default'
	killQueue(group)
	local _, ids = run(('pueue status --json | jq -r \'.tasks.[] | select(.group == "%s") | .id\''):format(group))
	ids = table.concat(ids, ' ')
	print('pueue remove ' .. ids)
	local ok, _, err = run('pueue remove ' .. ids)
	assert(ok, err)
	local ok, _, err = run('pueue start -g ' .. group)
	assert(ok, err)
end

-- remove successful jobs from a group
local function cleanQueue(group)
	group = group and group or 'default'
	local ok, _, err = run('pueue clean --successful-only -g ' .. group)
	assert(ok, err)
end

local function buildStatus(group)
	local selectGroup = ([[ pueue status --json | jq -r '.tasks[] | select(.group == "%s")]]):format(group)
	local _, success = run(selectGroup .. [[ | .status | select(.Done? == "Success").Done' ]])
	local _, killed = run(selectGroup .. [[ | .status | select(.Done? == "Killed").Done' ]])
	local _, queued= run(selectGroup .. [[ | select(.status == "Queued").status' ]])
	local _, running= run(selectGroup .. [[ | select(.status == "Running").status' ]])
	local _, failed= run(selectGroup .. [[ | .status.Done?.Failed?' ]])
	local active = running[1] and running[1] or ''
	local key = ("%s \t K:%s; Q:%s; F:%s; S:%s; %s"):format(group, #killed, #queued, #failed, #success, active)
	return {key, group}
end

local function buildRofiMenu(keys)
	local _, groups = run "pueue status --json | jq -r '.tasks[].group'"
	local options = M(groups)
		:unique()
		:map(buildStatus)
		:toObj()
		:value()

	local prompt = 'Opened queues; default action:restart\nLabels: K:killed; Q:queued; F:failed; S:success'
	return options, { prompt = prompt, keys = keys, width = '550px' }
end

local function makeMpvList(group)
	assert(os.execute('mpv.lua --makeQueue --input ' .. group) == 0, "Can't make m3u playlist form a queue " .. group)
end

local function menu()
	local keys = {
		['Alt-k'] = 'kill',
		['Alt-d'] = 'delete',
		['Alt-c'] = 'clean',
		['Alt-l'] = 'm3u',
	}
	local options, config = buildRofiMenu(keys)
	local selected, keybind = rofiMenu(options, config)
	selected = options[selected]

	if selected == '' then
		return
	end

	local cases = {
		['kill'] = killQueue,
		['delete'] = resetQueue,
		['clean'] = cleanQueue,
		['m3u'] = makeMpvList,
		[false] = restartQueue,
	} 
	switch(cases, keys[keybind])(selected)
end

local cases = {
	['menu'] = menu, ['m'] = menu,
	['kill'] = killQueue, ['k'] = killQueue,
	['restart'] =restartQueue , ['r'] = restartQueue,
	['delete'] = resetQueue, ['d'] = resetQueue,
	['clean'] = cleanQueue, ['c'] = cleanQueue,
	['help'] = help, ['h'] = help,
}

for key, _ in pairs(args) do
	local switch = switch(cases, key)
	if switch and args[key] then
		xpcall(switch, errorMsg, params[1])
	end
end
