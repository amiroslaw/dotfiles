#!/usr/bin/luajit

local function help()
	print [[
Utility script for managing the pueue program. It's a tool that processes a queue of shell commands.
Using: mpv.lua [action] [group] [option]

Actions:
	--menu -m → 
	--kill, -k →
	--killAny, -K →
	--cleanQueue, -c →
	--delete, -d →
	--restart, -r →
	--list, l → show job list in a rofi menu, can be limited to provided group
	--help, -h → Show help

examples:
qu.lua --kill queueGroupName
qu.lua --restart queueGroupName

In order to change stream format and options it's needed to add the profiles `stream` and `stream-popup` into the mpv.conf file.
Dependencies: pueue, rofi, notify-send, jq, zenity

Testing:
trzeba najpierw kill aby usunąć - jak jest running to nie usunie tego joba

TODO 
Czasami po restarcie nie odpala się następny element. poprawiać też w jobList
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

-- stop any running job, in their many - show menu
local function killAny()
	local _, running = run([[pueue status --json | jq -r '.tasks[] | select(.status == "Running").status' ]])
	if #running == 0 then
		notify('Any running jobs')
		return
	end

	if #running < 2 then
		local killStatus, _, err = run('pueue kill --all')
		assert(killStatus, err)
	else
		local okList, runningJobs, err = run([[pueue status --json status=running | jq -r '.tasks[] | "\(.id) \(.label) @\(.group)"']])
		assert(okList, err)
		M(rofiMenu(runningJobs, { prompt = 'Jobs to kill', multi = true, width = '70%'}))
				:map(M.fun.match('@[%w-]+$'))
				:map(M.fun.gsub('@', ''))
				:each(killQueue)
		-- if you kill one job from a group the secound will start - change to pueue kill -g 
		-- local selectedIds = M(selected)
		-- 		:map(M.fun.match('^%d+'))
		-- 		:concat(' ')
		-- 		:value()
		-- local killStatus, _, err = run('pueue kill ' .. selectedIds)
		-- assert(killStatus, err)
	end
end

-- A killed job will be restarted.
local function restartQueue(group)
	group = group and group or 'default'
	local restartStatus, _, err = run(('pueue restart -i -g %s'):format(group))
	assert(restartStatus, err)
	local startStatus, _, err = run(('pueue start -g %s'):format(group))
	assert(startStatus, err)
end

-- remove all jobs in a group, first kill them if necessary 
local function resetQueue(group)
	group = group and group or 'default'
	killQueue(group)
	local _, ids = run(('pueue status --json | jq -r \'.tasks.[] | select(.group == "%s") | .id\''):format(group))
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

local function makeMpvList(group)
	assert(os.execute('mpv.lua --makeQueue --input ' .. group) == 0, "Can't make m3u playlist form a queue " .. group)
end

-- TODO, test 
local function jobList(group)
	if group then
		group = ' -g ' .. group
	else
		group = ''
	end
	local ok, out, err = run('pueue status columns=id,status,label,command ' .. group) 
	assert(ok, err)
	local keys = {
		['Alt-k'] = 'kill',
		['Alt-d'] = 'delete',
	}
	local cases = {
		['kill'] = 'pueue kill %s',
		['delete'] = 'pueue remove %s', -- maybe kill before
		[false] = 'pueue restart -i %s; pueue start %s',
		-- ['kill'] = killQueue,
		-- ['delete'] = resetQueue,
		-- [false] = restartQueue,
	} 
	local jobs = M(out):filter(M.fun.contains('^%s%d'))
					:value()
	local selected, keybind = rofiMenu(jobs, { prompt = 'Default action:restart', multi = true, width = '70%', keys = keys})
	if selected == '' then
		menu()
	end
	local jobsId = M(selected)
			:map(M.fun.match('%d+'))
			:concat(' ')
			:value()
			-- :each(killQueue)
	local cmd = switch(cases, keys[keybind])
	printt(cmd .. jobsId)
	local ok, _, err = run(cmd:format(jobsId, jobsId))
	-- assert(ok, err)
end
local function jobListAll()
	jobList()
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
	return options, { prompt = prompt, keys = keys, width = '800px' }
end

function menu()
	local keys = {
		['Alt-k'] = 'kill',
		['Alt-d'] = 'delete',
		['Alt-c'] = 'clean',
		['Alt-m'] = 'm3u',
		['Alt-l'] = 'list',
		['Alt-a'] = 'all jobs',
	}
	local cases = {
		['kill'] = killQueue,
		['delete'] = resetQueue,
		['clean'] = cleanQueue,
		['m3u'] = makeMpvList,
		['list'] = jobList,
		['all jobs'] = jobListAll,
		[false] = restartQueue,
	} 
	local options, config = buildRofiMenu(keys)
	local selected, keybind = rofiMenu(options, config)
	if selected == '' then
		return
	end
	selected = options[selected]

	switch(cases, keys[keybind])(selected)
end


local cases = {
	['menu'] = menu, ['m'] = menu,
	['kill'] = killQueue, ['k'] = killQueue,
	['killAny'] = killAny, ['K'] = killAny,
	['restart'] =restartQueue , ['r'] = restartQueue,
	['delete'] = resetQueue, ['d'] = resetQueue,
	['clean'] = cleanQueue, ['c'] = cleanQueue,
	['list'] = jobList, ['l'] = jobList,
	['help'] = help, ['h'] = help,
}

for key, _ in pairs(args) do
	local switch = switch(cases, key)
	if switch and args[key] then
		xpcall(switch, errorMsg, params[1])
	end
end
