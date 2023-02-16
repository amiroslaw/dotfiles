#!/usr/bin/luajit

local TMP_PLAYLIST = '/tmp/qb_mpvplaylist.m3u'
local TMP_PLAY = '/tmp/qb_mpv.m3u'
local DIR_PLAYLISTS = os.getenv 'HOME' .. '/Templates/mpvlists'

function help()
print [[
Utility script for managing stream with the mpv program. 
Using: mpv.lua action [url]

The url argument can be replace by `--clip` (it will be pulled from the clipboard using the clipster application) or `--resume` (temporary file) options.
Actions that run list, create a playlist (*.m3u) - after the player is closed script will make a file. 
Actions that manage playlists can take `--save[=playlistName]` or `--input` options for overrate default name.

Actions:
	--push -u → Add an url to the playlist
	--audioplay -a → Play audio from the url
	--audiolist -A → Play audio from the playlist
	--videoplay -v → Play video from the url
	--videolist -V → Play video from the playlist
	--popupplay -p → Play video in lower resolution from the url
	--popuplist -P → Play video in lower resolution from the playlist
	--makeLocal -l → Create playlist (m3u) from the directories in current location 
	--makeOnline -o → Create playlist (m3u) from the url `--push` command
	--rename -n → Change name of the last playlist
	--help - Show help
Options:
	--clip -c → read parameter from clipboard
	--resume -r → read url from `TMP_PLAY`
	--save=name -s → save playlist, a name can be provide or it will be generated
	--input -i → prompt for a name of the playlist

examples:
mpv.lua --audioplay url 
mpv.lua --push url 
mpv.lua --videolist --save=custom-playlist-name
mpv.lua --videolist --input
mpv.lua --rename=custom-playlist-name
mpv.lua --makeOnline --input
mpv.lua --audioplay --resume

In order to change stream format and options it's needed to add the profiles `stream` and `stream-popup` into the mpv.conf file.
Dependencies: mpv, st, clipster, fd, zenity, rofi, notify-send, yt-dlp
	]]

end

local LINK_REGEX = "^https?://(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w%w%w?%w?)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))"

local args = cliparse(arg, 'params')
local param
if args.params then
	param = args.params[1]
	if not args.makeOnline and not args.o then
		param = split(param,"&list=" )[1]
	end
end

if args.clip or args.c then
	local status, clipboard = run('clipster -o --clipboard -n 1')
	if status then
		local match = clipboard[1]:match(LINK_REGEX)
		if match then
			param = match
		else
			errorMsg('Can not read url from the clipboard')
		end
	end
end
if args.resume or args.r then
	local tmpPlayUrl = readf(TMP_PLAY)
	if tmpPlayUrl then
		param = tmpPlayUrl[1]	
	end
end

function errorMsg(msg)
	print(msg)
	log(msg, 'ERROR')
	notifyError(msg)
end

function getHost()
	-- local pageUrl = assert(io.open(TMP_PLAYLIST, 'r'):read('*l'), 'Did not read page url') -- reads first line
	local playlist = readf(TMP_PLAYLIST) 
	local pageUrl = playlist[#playlist] -- gets last line
	-- return (pageUrl .. '/'):match '://(.-)/'
	return pageUrl:match('^%w+://([^/]+)'):gsub('www.', ''):match '([^.]+)'
end

local function buildName(defaultName)
	if args.input or args.i then
		local ok, out =	run('zenity --entry --text="Playlist name" --entry-text="' .. defaultName .. '"')
		if ok and out ~= '' then
			return out[1]
		end
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

local function savePlaylist(mediaType)
	if args.save or args.s or args.input or args.i then
		assert(os.execute('mkdir -p ' .. DIR_PLAYLISTS) == 0, 'Did not create playlist dir ' .. DIR_PLAYLISTS)
		local defaultName = os.date '%Y-%m-%dT%H%M-' .. mediaType .. '-' .. getHost()
		local listName = buildName(defaultName)
		if listName then
			print('mv ' .. TMP_PLAYLIST .. ' "' .. DIR_PLAYLISTS .. '/' .. listName .. '.m3u"')
			assert( os.execute('mv ' .. TMP_PLAYLIST .. ' "' .. DIR_PLAYLISTS .. '/' .. listName .. '.m3u"') == 0, 'Did not move playlist to ' .. DIR_PLAYLISTS)
		end
		assert(os.execute('rm -f ' .. TMP_PLAYLIST) == 0, 'Did not remove playlist')
	end
end

local function writeUrlToFile(filePath, url)
	local file = assert(io.open(filePath, 'w'), 'Could not write to file ' .. filePath)
	file:write(url)
	file:close()
end

local function videoplay(url)
	writeUrlToFile(TMP_PLAY, url)
	assert(os.execute('mpv --profile=stream --playlist=' .. TMP_PLAY) == 0, 'Error: run mpv')
end

local function videolist()
	assert(os.execute('mpv --profile=stream --playlist=' .. TMP_PLAYLIST) == 0, 'Error: run mpv')
	savePlaylist 'video'
end

local function popupplay(url)
	writeUrlToFile(TMP_PLAY, url)
	assert(os.execute('mpv --x11-name=videopopup --profile=stream-popup --playlist=' .. TMP_PLAY) == 0, 'Error: run mpv')
end

local function popuplist()
	assert(os.execute('mpv --x11-name=videopopup --profile=stream-popup --playlist=' .. TMP_PLAYLIST) == 0, 'Error: run mpv')
	savePlaylist 'video'
end

local function audioplay(url)
	writeUrlToFile(TMP_PLAY, url)
	assert( os.execute( 'st -c audio -e mpv --ytdl --no-video --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M --playlist=' .. TMP_PLAY) == 0, 'Error: run mpv')
end

local function audiolist()
	assert( os.execute( 'st -c audio -e mpv --ytdl --no-video --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M --input-ipc-server=/tmp/mpvsocket --playlist=' .. TMP_PLAYLIST) == 0, 'Error: run mpv')
	savePlaylist 'audio'
end

local function push(url)
	local extinf = ''
	local ok, out = run('yt-dlp -i --print duration,title ' .. url)
	if ok then
		extinf = '#EXTINF:' .. out[1] .. ',' .. out[2] .. '\n'
	end
	assert(io.open(TMP_PLAYLIST, 'a'):write(extinf .. url .. '\n'))
end

-- rename lastest saved playlist
local function renameList()
	local ok, latestPlaylistPaths = run('ls -1t ' .. DIR_PLAYLISTS)
	local customName = buildName(latestPlaylistPaths[1])
	if customName then
		assert( os.execute('mv "' .. DIR_PLAYLISTS .. '/' .. latestPlaylistPaths[1] .. '" "' .. DIR_PLAYLISTS .. '/' .. customName .. '.m3u"') == 0, 'Error: Could not rename ' .. latestPlaylistPaths[1])
	end
end

local function makeLocal()
	local find = assert(io.popen('fd --type f --follow -e mp4 -e mkv -e avi -e 4v -e mkv -e webm -e wmv -e mp3 -e flac -e wav -e aac'):read '*a')
	local pwd = assert(io.popen('pwd'):read '*a')
	pwd = split(pwd, '/')
	local playlistName = pwd[#pwd]:gsub('\n', '')
	playlistName = buildName(playlistName)
	local playlist = assert(io.open(playlistName .. '.m3u', 'w'))
	playlist:write(find)
	playlist:close()
end

local function makeOnline()
	local ok,out = run('yt-dlp -i --print playlist_title,playlist_count,duration,title,original_url "' .. param .. '"')
	-- local type = arg[3] and 

	-- won't create playlist with hidden videos
	assert(ok, 'Error: Could not get playlist metadata')
	local playlistName = out[1]
	playlistName = buildName(playlistName)
	local playlist = {'#EXTM3U', '#PLAYLIST: ' .. playlistName}
	for i = 0, out[2] -1 do
		local videoIndex = i * 5
		local duration = out[videoIndex + 3] and out[videoIndex + 3] or -1
		local title = out[videoIndex + 4] and out[videoIndex + 4] or ''
		table.insert(playlist,'#EXTINF:' .. duration .. ',' .. title)
		table.insert(playlist, out[videoIndex + 5])
	end
	local writeOk = writef(playlist, DIR_PLAYLISTS .. '/' .. playlistName .. '-video.m3u')
	assert(writeOk, 'Error: Could not write playlist to a file')
	notify('created ' .. playlistName)
end

local cases = {
	['push'] = push, ['u'] = push,
	['audioplay'] = audioplay, ['a'] = audioplay,
	['audiolist'] = audiolist, ['A'] = audiolist,
	['videoplay'] = videoplay, ['v'] = videoplay,
	['videolist'] = videolist, ['V'] = videolist,
	['popupplay'] = popupplay, ['p'] = popupplay,
	['popuplist'] = popuplist, ['P'] = popuplist,
	['makeLocal'] = makeLocal, ['l'] = makeLocal,
	['makeOnline'] = makeOnline, ['o'] = makeOnline,
	['rename'] = renameList, ['n'] = renameList,
	['help'] = help, ['h'] = help
}

for key,_ in pairs(args) do
	local switchFunction = switch(cases, key)
	if switchFunction and args[key] then
		xpcall(switchFunction, errorMsg, param)
	end
end
