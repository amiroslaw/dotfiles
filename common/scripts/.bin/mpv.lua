#!/usr/bin/luajit

local tmpPlaylist = '/tmp/qt_mpvplaylist.m3u'
local tmpPlay = '/tmp/qt_mpv.m3u'
local dirPlaylists = os.getenv 'HOME' .. '/Templates/mpvlists'

function help()
print [[
Utility script for managing stream with the mpv program. 
Using: mpv.lua action [url | playlistName]

The url argument is optional. It will be pulled from the clipboard using the clipster application or if it is not a URL it will take it from the temporary file.
Actions that run list create a playlist (*.m3u) - after the player is closed script will make a file. Those actions can take `playlistName` argument as a custom name or a string `named` - it will prompt a form.

actions:
	push - Add an url to the playlist
	audioplay - Play audio from the url
	audiolist - Play audio from the playlist
	videoplay - Play video from the url
	videolist - Play video from the playlist
	videopopup - Play video in lower resolution from the url
	popuplist - Play video in lower resolution from the playlist
utils actions:
	rename - Rename the latest playlist
	make - Create playlist (m3u) from the directories in current location 
	help - Show help

examples:
mpv.lua audioplay url 
mpv.lua push url 
mpv.lua videolist named
mpv.lua videolist custom-playlist-name
mpv.lua rename custom-playlist-name

In order to change stream format and options it's needed to add the profiles `stream` and `stream-popup` into the mpv.conf file.
Dependencies: mpv, st, clipster, fd, zenity, rofi, notify-send, yt-dlp
	]]

end

local LINK_REGEX = "^https?://(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w%w%w?%w?)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))"

function errorMsg(msg)
	print(msg)
	log(msg, 'ERROR')
	notifyError(msg)
end

function make()
	local find = assert(io.popen('fd --type f --follow -e mp4 -e mkv -e avi -e 4v -e mkv -e webm -e wmv -e mp3 -e flac -e wav -e aac'):read '*a')
	local pwd = assert(io.popen('pwd'):read '*a')
	pwd = split(pwd, '/')
	local playlistName = pwd[#pwd]:gsub('\n', '') .. '.m3u'

	local playlist = assert(io.open(playlistName, 'w'))
	playlist:write(find)
	playlist:close()
end

function getHost()
	-- local pageUrl = assert(io.open(tmpPlaylist, 'r'):read('*l'), 'Did not read page url') -- reads first line
	local playlist = readf(tmpPlaylist) 
	local pageUrl = playlist[#playlist] -- gets last line
	-- return (pageUrl .. '/'):match '://(.-)/'
	return pageUrl:match('^%w+://([^/]+)'):gsub('www.', ''):match '([^.]+)'
end

local function buildName(defaultName)
	local cmdArg = arg[2]
	if cmdArg == "named" then
		local ok, out =	run('zenity --entry --text="Playlist name" --entry-text="' .. defaultName .. '"')
		if ok and out ~= '' then
			return out[1]
		end
	-- name form cli param: mpv.lua videolist customname
	elseif cmdArg ~= nil then
		return cmdArg .. '.m3u'
	end
end

function savePlaylist(mediaType)
	assert(os.execute('mkdir -p ' .. dirPlaylists) == 0, 'Did not create playlist dir ' .. dirPlaylists)
	local defaultName = os.date '%Y-%m-%dT%H%M-' .. mediaType .. '-' .. getHost() .. '.m3u'
	local listName = buildName(defaultName)
	if listName then
		assert( os.execute('mv ' .. tmpPlaylist .. ' "' .. dirPlaylists .. '/' .. listName .. '"') == 0, 'Did not move playlist to ' .. dirPlaylists)
	end
	assert(os.execute('rm -f ' .. tmpPlaylist) == 0, 'Did not remove playlist')
end

function writeUrlToFile(filePath, url)
	local file = assert(io.open(filePath, 'w'), 'Could not write to file ' .. filePath)
	file:write(url)
	file:close()
end

function videoplay(url)
	writeUrlToFile(tmpPlay, url)
	assert(os.execute('mpv --profile=stream --playlist=' .. tmpPlay) == 0, 'Error: run mpv')
end

function videolist()
	assert(os.execute('mpv --profile=stream --playlist=' .. tmpPlaylist) == 0, 'Error: run mpv')
	savePlaylist 'video'
end

function videopopup(url)
	writeUrlToFile(tmpPlay, url)
	assert(os.execute('mpv --x11-name=videopopup --profile=stream-popup --playlist=' .. tmpPlay) == 0, 'Error: run mpv')
end

function popuplist()
	assert(os.execute('mpv --x11-name=videopopup --profile=stream-popup --playlist=' .. tmpPlaylist) == 0, 'Error: run mpv')
	savePlaylist 'video'
end

function audioplay(url)
	writeUrlToFile(tmpPlay, url)
	assert( os.execute( 'st -c audio -e mpv --ytdl --no-video --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M --playlist=' .. tmpPlay) == 0, 'Error: run mpv')
end

function audiolist()
	assert( os.execute( 'st -c audio -e mpv --ytdl --no-video --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M --input-ipc-server=/tmp/mpvsocket --playlist=' .. tmpPlaylist) == 0, 'Error: run mpv')
	savePlaylist 'audio'
end

function push(url)
	local extinf = ''
	local ok, out = run('yt-dlp -i --print duration,title ' .. url)
	if ok then
		extinf = '#EXTINF:' .. out[1] .. ',' .. out[2] .. '\n'
	end
	assert(io.open(tmpPlaylist, 'a'):write(extinf .. url .. '\n'))
end

-- rename lastest saved playlist
local function renameList()
	local ok, latestPlaylistPaths = run('ls -1t ' .. dirPlaylists)
	local customName = buildName(latestPlaylistPaths[1])
	if customName then
		assert( os.execute('mv "' .. dirPlaylists .. '/' .. latestPlaylistPaths[1] .. '" "' .. dirPlaylists .. '/' .. customName .. '"') == 0, 'Error: Could not rename ' .. latestPlaylistPaths[1])
	end
end

local function makeYtPlaylist()
	print('yt-dlp -i --print playlist_title,playlist_count,duration,title,original_url "' .. arg[2] .. '"')
	local ok,out = run('yt-dlp -i --print playlist_title,playlist_count,duration,title,original_url "' .. arg[2] .. '"')

	-- won't create playlist with hidden videos
	assert(ok, 'Error: Could not get playlist metadata')
	local playlistTitle = out[1]
	local playlist = {'#EXTM3U', '#PLAYLIST: ' .. playlistTitle}
	for i = 0, out[2] -1 do
		local videoIndex = i * 5
		local duration = out[videoIndex + 3] and out[videoIndex + 3] or -1
		local title = out[videoIndex + 4] and out[videoIndex + 4] or ''
		table.insert(playlist,'#EXTINF:' .. duration .. ',' .. title)
		table.insert(playlist, out[videoIndex + 5])
	end
	local writeOk = writef(playlist, dirPlaylists .. '/' .. playlistTitle .. '.m3u')
	assert(writeOk, 'Error: Could not write playlist to a file')
	notify('created ' .. playlistTitle)
end

local cases = {
	['push'] = push,
	['audioplay'] = audioplay,
	['audiolist'] = audiolist,
	['videoplay'] = videoplay,
	['videolist'] = videolist,
	['videopopup'] = videopopup,
	['popuplist'] = popuplist,
	['make'] = make,
	['make-yt'] = makeYtPlaylist,
	['rename'] = renameList,
	['help'] = help,
	[false] = help,
}

local switchFunction = switch(cases, arg[1])
local url = arg[2]
if arg[2] and arg[1] ~= 'make' then
	url = split(url,"&list=" )[1]
else
	local status, clipboard = run('clipster -o --clipboard -n 1')
	if status then
		local match = clipboard[1]:match(LINK_REGEX)
		if match then
			url = match
		else
			local tmpPlayUrl = readf(tmpPlay)
			if tmpPlayUrl then
				url = tmpPlayUrl[1]	
			end
		end
	end
end
xpcall(switchFunction, errorMsg, url)
