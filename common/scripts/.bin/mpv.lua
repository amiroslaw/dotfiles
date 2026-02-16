#!/usr/bin/luajit

function help()
print [[
Utility script for managing stream with the mpv program. 
Using: mpv.lua action [url]

The url argument can be replace by `--clip` (it will be pulled from the clipboard using the clipster application) or `--resume` (temporary file) options.
Actions that run list, create a playlist (*.m3u) - after the player is closed script will make a file. 
Actions that manage playlists can take `--save[=playlistName]` or `--input` options for overrate default name.

Actions:
	--makeLocal -l → Create playlist (m3u) from the directories in current location 
	--makeOnline -m → Create playlist (m3u) from the yt playlist url
	--makeQueue -q → Create playlist (m3u) from a queue
	--open -o [--list] [dir] → Open and manage videos or playlists
	--rename -n [dir] → Change name of the last playlist
	--metadata -M → Retrieves metadata form the video
	--ytsearch -y → Search YT for videos
	--help - Show help
Options:
	--clip -c → read parameter from clipboard
	--save=name -s → save playlist, a name can be provide or it will be generated
	--input -i → prompt for a name of the playlist
	--list -L → filter only playlists

examples:
mpv.lua --videolist --save=custom-playlist-name
mpv.lua --videolist --input
mpv.lua --rename=custom-playlist-name
mpv.lua --makeLocal --input ~/Videos
mpv.lua --makeLocal --save=YouTube ~/Videos/yt
mpv.lua --audioplay --resume
mpv.lua --mpvList queueGroupName --videolist --save=custom-playlist-name
mpv.lua --mpvList queueGroupName --noInput

In order to change stream format and options it's needed to add the profiles `stream` and `stream-popup` into the mpv.conf file.
For editing - set system env: GUI_EDITOR
Dependencies: st, clipster, fd, zenity, rofi, notify-send, yt-dlp, trash-put in optional, jq
	for yt: mpv, pueue

TODO: 
add support reading from env
doesn't clear playlist after abort prompt
	]]
end

local CMD_VIDEO = 'mpv --profile=stream %s'
local CMD_POPUP = 'mpv --x11-name=videopopup --profile=stream-popup %s'
local CMD_AUDIO = (os.getenv 'TERM_LT' .. os.getenv 'TERM_LT_RUN'):format('audio', 'mpv --profile=stream-audio %s')
local CMD_QUEUE = {
	fullscreen = 'pueue add  --label "%s" -g mpv-fullscreen -- ' .. CMD_VIDEO,
	popup = 'pueue add  --label "%s" -g mpv-popup -- ' .. CMD_POPUP,
	audio = 'pueue add -e --label "%s" -g mpv-audio -- ' .. CMD_AUDIO
}
local GUI_EDITOR = os.getenv('GUI_EDITOR') .. ' %s'
local DIR_PLAYLISTS = os.getenv 'HOME' .. '/Templates/mpvlists'
local DIR_ARCHIVE = os.getenv 'HOME' .. '/Templates/mpvlists-archive'

local LINK_REGEX = "(https?://([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w%w%w?%w?)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))"

local function errorMsg(msg)
	print(msg)
	log(msg, 'ERROR')
	notifyError(msg)
end

local args = cliparse(arg, 'params')
local param
if args.params then
	param = args.params[1]
	if not args.makeOnline and not args.o then
		param = split(param,"&list=" )[1]
	end
end

if args.clip or args.c then
	local clipboard, status, err = run('clipster -o --clipboard -n 1', "Can't read from cliparser")
	assert(status, err)
	local match = clipboard[1]:match(LINK_REGEX)
	if match then
		param = match
	else
		errorMsg('Can not read url from the clipboard')
	end
end

local function buildName(defaultName)
	if args.input or args.i then
		local out = run('zenity --entry --text="Playlist name" --entry-text="' .. defaultName .. '"', "Can't run zenity")
		return out[1]
	end
	local save = args.save or args.s
	if save then
		save = save[1] and save[1] or defaultName
		return save
	end

	local rename = args.rename or args.n
	if rename then
		return rename[1] or rename[1]
	end

	return defaultName
end

local function renamePlaylist(playlistName)
	local customName = buildName(playlistName)
	if customName then
		assert( os.execute('mv "' .. DIR_PLAYLISTS .. '/' .. playlistName .. '" "' .. DIR_PLAYLISTS .. '/' .. customName .. '"') == 0, 'Error: Could not rename ' .. playlistName)
	end
end

-- rename lastest saved playlist
local function renameLastPlaylist()
	local latestPlaylist = run('ls -1t ' .. DIR_PLAYLISTS)
	renamePlaylist(latestPlaylist[1])
end

local function makeLocal()
	if param then
		param =' --search-path="' .. param .. '"'
	end
	param = param and param or ''
	local find = assert(io.popen('fd --type f --follow -e mp4 -e mkv -e avi -e 4v -e mkv -e webm -e wmv -e mp3 -e flac -e wav -e aac -e mov ' .. param):read '*a')
	local pwd = assert(io.popen('pwd'):read '*a')
	pwd = split(pwd, '/')
	local playlistName = pwd[#pwd]:gsub('\n', '')
	playlistName = buildName(playlistName)
	if playlistName then
		local playlist = assert(io.open(playlistName .. '.m3u', 'w'))
		playlist:write(find)
		playlist:close()
	end
end

local function toMetaVideo(data)
	return { url = data[1] , title = data[2], duration = data[3], channel = data[4], }
end

local function makeOnline()
	local out, ok, err = run('yt-dlp -i --print original_url,title,duration,playlist_title "' .. param .. '"')
	-- assert(ok, err) -- has an error with hidden or private videos
	if not ok then
		notify('Warning', split(err, '\n'), {['YouTube said'] = 'red'})
	end
	local playlistName = out[4]
	playlistName = buildName(playlistName)
	if not playlistName then
		return
	end

	local playlist = M(M.tabulate(M.partition(out,4)))
						:map(toMetaVideo)
						:map(function(v) 
							local duration = v.duration and v.duration or -1
							local title = v.title and v.title or ''
							return '#EXTINF:' .. duration .. ',' .. title .. '\n' .. v.url end)
						:prepend('#EXTM3U', '#PLAYLIST: ' .. playlistName)
						:value()

	local writeOk = writef(playlist, DIR_PLAYLISTS .. '/' .. playlistName .. '.m3u')
	assert(writeOk, 'Error: Could not write playlist to a file')
	notify('created ' .. playlistName)
end

local function getMetadata(url)
	local extinf = ''
	local  out, ok, err = run('yt-dlp -i --print duration,title "' .. url .. '"', "Can't get metadata form: " .. url)
	if not ok then
		log(err, 'WARNING')
	end
	if #out == 2 then
		extinf = ('#EXTINF:%s,%s\n'):format(out[1], out[2])
	end
	return extinf .. url
end

-- yt's list doesn't nest in mpv
-- m3u list won't have duplicats
-- I could pass url to --label option in pueue
local function makeQueue(group)
	-- I could read a title from label
	-- local cmd = [[pueue status --json | jq -r '.tasks.[] | select(.group == "%s") | "\(.label)@@@\(.command)"']]
	-- local _, out = run(cmd:format(group))
	local out = run(('pueue status --json | jq -r \'.tasks.[] | select(.group == "%s") | .command\''):format(group))

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
	notify('Made playlist for ' .. group)
end

local function concatPath(files)
	local paths = ' '
	for _,file in ipairs(files) do
		paths = paths .. ('"%s/%s" '):format(DIR_PLAYLISTS, file)
	end
	return paths
end

local function delete(selected)
	if os.execute('command -v trash-put') then
		return 'trash-put ' .. concatPath(selected)
	else
		return 'rm ' .. concatPath(selected)
	end
end

local function rename(selected) 
	args.input = true;
	for _,playlist in ipairs(selected) do
		renamePlaylist(playlist)
	end
	return 'notify-send "Renamed"' 
end

local function archive(selected) 
	assert(os.execute('mkdir -p ' .. DIR_ARCHIVE) == 0, 'Did not create playlist dir ' .. DIR_ARCHIVE)
	return 'mv ' .. concatPath(selected) .. ' "' .. DIR_ARCHIVE .. '"'
end

local function buildCmd(selectedElements, cmd)
	return cmd:format(concatPath(selectedElements))
end

-- When selected few playlists, they will be nested.
-- Multiple option opens videos in playlist but it doesn't hold --x11-name
-- with too many files, it doesn't work
local function openPlaylist()
	DIR_PLAYLISTS = param and param or DIR_PLAYLISTS
	local filetype = ' -e m3u -e mp4 -e mkv -e avi -e 4v -e mkv -e webm -e 3u -e mv -e pg -e part -e mov'
	if args.list or args.L then
		filetype = ' -e m3u '
	end

	local cmd = ('fd --follow --type=f %s --base-directory="%s" --exec stat --format="%%Z %%n" {} \\; | sort -nr | cut -d\' \' -f2-'):format(filetype, DIR_PLAYLISTS)
	local  playlists, okFind, err = run(cmd, "Can't find files" )

	assert(okFind, err)
	local prompt = 'default:open video; shift-enter:multi selection; Found:'.. #playlists
	local keysFun = {
		['Alt-p'] = {'popup', M.bind2(buildCmd, CMD_POPUP) },
		['Alt-a'] = {'audio', M.bind2(buildCmd, CMD_AUDIO) },
		['Alt-n'] = {'rename', rename },
		['Alt-o'] = {'open folder', function() return 'xdg-open "' .. DIR_PLAYLISTS .. '" &' end },
		['Alt-d'] = {'delete', delete },
		['Alt-e'] = {'edit', M.bind2(buildCmd, GUI_EDITOR) },
		['Alt-h'] = {'archive', archive },
	}

	local selected, keybind = rofiMenu(playlists, {prompt = prompt, keys = keysFun, multi=true, width = '95%'})
	if not keybind then return end -- cancel
	if not keysFun[keybind] then -- default
		notify(CMD_VIDEO:format(concatPath(selected)))
		local _, ok, _ = run(CMD_VIDEO:format(concatPath(selected)))
		assert(ok, 'Error: Can not play video ')
	else
		local _, ok, _ = run(keysFun[keybind][2](selected))
		assert(ok, 'Error: Can not execute ')
	end
end

local function play(videos, type)
	for i,_ in ipairs(videos) do
		os.execute(CMD_QUEUE[type]:format(videos[i].title, videos[i].url))
	end
end

-- different way to retrieve data
-- https://www.youtube.com/results?search_query=$search_term&sp=EgIQAQ%253D%253D - only videos
-- yt-dlp "$1" -J --flat-playlist --extractor-args youtubetab:approximate_date --playlist-start "$PLAYLIST_START" --playlist-end "$PLAYLIST_END" $PREFERRED_BROWSER || send_notification "Failed to fetch data : ("

local function ytsearch()
	local query = param and param or rofiInput({prompt = 'Search YT'})
	-- local results, ok, err = run('yt-dlp --print original_url,title,duration,channel "ytsearch15:' .. query .. '"', 'Search error: ') 15 results
	local results, ok, err = run('yt-dlp --print original_url,title,duration,channel "ytsearch10:' .. query .. '"', 'Search error: ')
	assert(ok, err)

	local videos = M(M.tabulate(M.partition(results,4)))
				:map(toMetaVideo):value()

	local prompt = 'default:open video; shift-enter:multi selection'
	local keysFun = {
		['Alt-p'] = {'popup', M.bind2(play,'popup') },
		['Alt-a'] = {'audio', M.bind2(play,'audio') },
	}

	local descriptions = {}
	for i,video in ipairs(videos) do
		table.insert(descriptions, string.format('%d-%.95s @%.1f #%s', i, video.title, video.duration/60, video.channel))
	end

	local selected, keybind = rofiMenu(descriptions, {prompt = prompt, keys = keysFun, multi=true, width = '95%'})

	if not keybind then return end -- cancel
	local playlist = M(selected):map(M.fun.match('^%d+'))
		:map(function(i) return videos[tonumber(i)] end)
		:value()
	if not keysFun[keybind] then -- default
		play(playlist, 'fullscreen')
	else
		keysFun[keybind][2](playlist)
	end

end

-- Gets metadata form YouTube's video
local function metadata()
	local metadata, ok, err = run('ffprobe -print_format json -show_format "' .. param .. '"', 'Can not retrieve metadata')
	assert(ok, err)
	local json = jsonish(table.concat(metadata, '\n'))
	json = json.format.tags
	--local out = { json.COMMENT, json.DATE, json.ARTIST, json.title, json.DESCRIPTION, }
	-- editor(table.concat(out,'\n'))
end

local cases = {
	['ytsearch'] = ytsearch, ['y'] = ytsearch,
	['makeLocal'] = makeLocal, ['l'] = makeLocal,
	['makeOnline'] = makeOnline, ['m'] = makeOnline,
	['makeQueue'] = makeQueue, ['q'] = makeQueue,
	['metadata'] = metadata, ['M'] = metadata,
	['open'] = openPlaylist, ['o'] = openPlaylist,
	['rename'] = renameLastPlaylist, ['n'] = renameLastPlaylist,
	['help'] = help, ['h'] = help
}

for key,_ in pairs(args) do
	local switch = switch(cases, key)
	if switch and args[key] then
		xpcall(switch, errorMsg, param)
	end
end
