#!/usr/bin/luajit

local tmpPlaylist = '/tmp/qt_mpvplaylist.m3u'
local tmpPlay = '/tmp/qt_mpv.m3u'
local dirPlaylists = os.getenv 'HOME' .. '/Templates/mpvlists'

function errorMsg(msg)
	print(msg)
	notifyError(msg)
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
	[false] = videoplay,
}

local switchFunction = switch(cases, arg[1])
local url = split(arg[2],"&list=" )[1]
xpcall(switchFunction, errorMsg, url)
