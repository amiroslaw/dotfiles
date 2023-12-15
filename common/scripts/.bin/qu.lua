#!/usr/bin/luajit

local function help()
	print [[
Utility script for managing the pueue program. It's a tool that processes a queue of shell commands.
Using: mpv.lua [action] [group] [option]

Actions:
	--menu -m → 
	--mpvList, -l → Create playlist (m3u) from the pueue
	--kill, -k →
	--restart, -r →
	--delete, -d →
	--help, -h → Show help
Options for mpvList:
	--save=name -s → save playlist, a name can be provide or it will be generated
	--noInput -i → skip prompt for a name of the playlist

examples:
qu.lua --kill queueGroupName
qu.lua --restart queueGroupName
qu.lua --mpvList queueGroupName --videolist --save=custom-playlist-name
qu.lua --mpvList queueGroupName --noInput

In order to change stream format and options it's needed to add the profiles `stream` and `stream-popup` into the mpv.conf file.
Dependencies: pueue, rofi, notify-send, jq, zenity

Testing:
trzeba najpierw kill aby usunąć - jak jest running to nie usunie tego joba

TODO 
jest problem jak dodaje listę z yt - ona się odpala jako dodatkowy job - zmienić funkcje w mpv.lua i tam ucinać parametr z list
przy kill mpv i ponownym uruchomieniu nie zapisuje się gdzie mpv przerwał odtwarzanie, to jest normalne zachowanie przy np. killall mpv
	]]
end

local DIR_PLAYLISTS = os.getenv 'HOME' .. '/Templates/mpvlists'
local LINK_REGEX = '(https?://([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w%w%w?%w?)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'

local function errorMsg(msg)
	print(msg)
	log(msg, 'ERROR')
	notifyError(msg)
end

local args = cliparse(arg, 'params')
local params = args.params and args.params or {}

local function buildName(defaultName)
	local save = args.save or args.s
	if save then
		save = save[1] and save[1] or defaultName
		return save
	end
	if args.noInput or args.i then
		return defaultName
	end
	local ok, out, err =
		run('zenity --entry --text="Playlist name" --entry-text="' .. defaultName .. '"', "Can't run zenity")
	return out[1]
end

local function getMetadata(url)
	local extinf = ''
	local ok, out, err = run('yt-dlp -i --print duration,title "' .. url .. '"', "Can't get metadata form: " .. url)
	if not ok then
		log(err, 'WARNING')
	end
	if #out == 2 then
		extinf = '#EXTINF:' .. out[1] .. ',' .. out[2] .. '\n'
	end
	return extinf .. url
end

-- yt's list doesn't nest in mpv
-- m3u list won't have duplicats
-- I could pass url to --label option in pueue
local function makeMpvList(group)
	local _, out = run(('pueue status --json | jq -r \'.tasks.[] | select(.group == "%s") | .command\''):format(group))

	if #out == 0 then
		notify('No url in the ' .. group)
		return
	end
	local links = M(out):map(M.fun.match(LINK_REGEX)):keys():value()

	local hostName = links[1]:match('^%w+://([^/]+)'):gsub('www.', ''):match '([^.]+)'
	local defaultName = os.date '%Y-%m-%dT%H%M-' .. hostName
	local listName = buildName(defaultName)

	-- :filter(M.fun.contains(urlPattern))
	local playlistNameTemplate = '#EXTM3U\n#PLAYLIST: ' .. listName .. '\n'
	local playlistTemplate = playlistNameTemplate .. M(links):map(getMetadata):concat('\n'):value()

	assert(os.execute('mkdir -p ' .. DIR_PLAYLISTS) == 0, 'Did not create playlist dir ' .. DIR_PLAYLISTS)
	io.open(('%s/%s.m3u'):format(DIR_PLAYLISTS, listName), 'w'):write(playlistTemplate)
end

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
	['mpvList'] = makeMpvList, ['l'] = makeMpvList,
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
