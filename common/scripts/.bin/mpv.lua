#!/usr/bin/luajit

local tmpPlaylist = '/tmp/qt_mpvplaylist.m3u'
local tmpPlay = '/tmp/qt_mpv.m3u'
local dirPlaylists = os.getenv 'HOME' .. '/Templates/mpvlists'

function help()
print [[
Utility script for managing stream with the mpv program. 
Using: mpv.lua action [url]
The url argument is optional. It will be pulled from the clipboard using the clipster application.
actions:
	push - Add an url to the playlist
	audioplay - Play audio from the url
	audiolist - Play audio from the playlist
	videoplay - Play video from the url
	videolist - Play video from the playlist
	videopopup - Play video in lower resolution from the url
	popuplist - Play video in lower resolution from the playlist
	make - Create playlist (m3u) from the directories in current location 
	help - Show help

In order to change stream format and options it's needed to add the profiles `stream` and `stream-popup` into the mpv.conf file.
	]]

end

function errorMsg(msg)
	print(msg)
	notifyError(msg)
end

function make()
	local find = assert(io.popen('fd --absolute-path --type f --follow -e mp4 -e mkv -e avi -e 4v -e mkv -e webm -e wmv -e mp3 -e flac -e wav -e aac'):read '*a')
	local pwd = assert(io.popen('pwd'):read '*a')
	pwd = split(pwd, '/')
	local playlistName = pwd[#pwd]:gsub('\n', '') .. '.m3u'

	local playlist = assert(io.open(playlistName, 'w'))
	playlist:write(find)
	playlist:close()
end

function getHost()
	local pageUrl = assert(io.open(tmpPlaylist, 'r'):read('*l'), 'Did not read page url')
	-- return (pageUrl .. '/'):match '://(.-)/'
	return pageUrl:match('^%w+://([^/]+)'):gsub('www.', ''):match '([^.]+)'
end

function savePlaylist(mediaType)
	assert(os.execute('mkdir -p ' .. dirPlaylists) == 0, 'Did not create playlist dir ' .. dirPlaylists)
	local listName = '/' .. os.date '%Y-%m-%dT%H%M-' .. mediaType .. '-' .. getHost() .. '.m3u'
	assert( os.execute('mv ' .. tmpPlaylist .. ' ' .. dirPlaylists .. listName) == 0, 'Did not move playlist to ' .. dirPlaylists)
	assert(os.execute('rm -f ' .. tmpPlaylist) == 0, 'Did not remove playlist')
end

function writeUrlToFile(filePath, url)
	print(url)
	local file = assert(io.open(filePath, 'w'), 'Could not write to file ' .. filePath)
	file:write(url)
	file:close()
end

function videoplay(url)
	writeUrlToFile(tmpPlay, url)
	assert(os.execute('mpv --profile=stream --playlist=' .. tmpPlay) == 0)
end

function videolist()
	assert(os.execute('mpv --profile=stream --playlist=' .. tmpPlaylist) == 0)
	savePlaylist 'video'
end

function videopopup(url)
	writeUrlToFile(tmpPlay, url)
	assert(os.execute('mpv --x11-name=videopopup --profile=stream-popup --playlist=' .. tmpPlay) == 0)
end

function popuplist()
	assert(os.execute('mpv --x11-name=videopopup --profile=stream-popup --playlist=' .. tmpPlaylist) == 0)
	savePlaylist 'video'
end

function audioplay(url)
	writeUrlToFile(tmpPlay, url)
	assert( os.execute( 'st -c audio -e mpv --ytdl --no-video --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M --playlist=' .. tmpPlay) == 0)
end

function audiolist()
	assert( os.execute( 'st -c audio -e mpv --ytdl --no-video --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M --input-ipc-server=/tmp/mpvsocket --playlist=' .. tmpPlaylist) == 0)
	savePlaylist 'audio'
end

function push(url)
	assert(io.open(tmpPlaylist, 'a'):write(url .. '\n'))
end

local cases = {
	['push'] = push,
	['audioplay'] = audioplay,
	['audiolist'] = audiolist,
	['videolist'] = videolist,
	['videopopup'] = videopopup,
	['popuplist'] = popuplist,
	['make'] = make,
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
		url = clipboard[1]
	else
		notifyError('Could not retrieve clipboard from the clipster app')
	end
end
xpcall(switchFunction, errorMsg, url)
