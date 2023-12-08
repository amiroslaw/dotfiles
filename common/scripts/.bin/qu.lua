#!/usr/bin/luajit

function help()
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
	-- local		fetchStatus, queued = run(("pueue status -g %s --json | jq -c '.tasks.[] | select(.status == \"Queued\") | .id'"):format(group))
	-- will return error cos unfinished jobs doesn't have "done" value
	-- print(("pueue status --json | jq -r '.tasks.[] | select(.status.Done == \"Killed\" && .group == \"%s\") | .id'"):format(group))
	-- local		_, queued = run(("pueue status --json | jq -r '.tasks.[] | select(.status.Done == \"Killed\" && .group == \"%s\") | .id'"):format(group))
	-- local		_, queued = run(("pueue status -g %s --json | jq -r '.tasks.[] | select(.status.Done == \"Killed\") | .id'"):format(group))
	-- 		if #queued == 0 then
	-- 			notify('Any task to restart')
	-- 			return
	-- 		end
	-- 		local killedJobId = queued[1]
	-- 		nie trzeba id
	local restartStatus, err = run(('pueue restart -i -g %s'):format(group))
	assert(restartStatus, err)
	local startStatus, err = run(('pueue start -g %s'):format(group))
	assert(startStatus, err)
end

-- remove jobs
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

local function menu()
	local _, groups = run "pueue status --json | jq -r '.tasks[].group'"
	groups = M(groups):unique():value()
	local prompt = 'Available queues; default:restart'
	local keys = {
		['Alt-k'] = 'kill',
		['Alt-d'] = 'delete',
		['Alt-l'] = 'm3u',
	}

	local selected, keybind = rofiMenu(groups, { prompt = prompt, keys = keys })

	if selected == '' then
		return
	end

	if keys[keybind] == 'kill' then
		killQueue(selected)
	elseif keys[keybind] == 'delete' then
		resetQueue(selected)
	elseif keys[keybind] == 'm3u' then
		makeMpvList(selected)
	else -- default
		restartQueue(selected)
	end
end

local cases = {
	['menu'] = menu, ['m'] = menu,
	['mpvList'] = makeMpvList, ['l'] = makeMpvList,
	['kill'] = killQueue, ['k'] = killQueue,
	['restart'] =restartQueue , ['r'] = restartQueue,
	['delete'] = resetQueue, ['d'] = resetQueue,
	['help'] = help, ['h'] = help,
}

for key, _ in pairs(args) do
	local switch = switch(cases, key)
	if switch and args[key] then
		xpcall(switch, errorMsg, params[1])
	end
end
