#!/usr/bin/luajit

local quteFifo = os.getenv 'QUTE_FIFO'
local tmpPlaylist = '/tmp/qt_mpvplaylist.m3u'
local tmpPlay = '/tmp/qt_mpv.m3u'
local dirPlaylists = os.getenv 'HOME' .. '/Templates/mpvlists'

function errorMsg(msg)
	io.open(quteFifo, 'a'):write('message-error "' .. msg .. '"')
end

function getHost()
	local pageUrl = os.getenv 'QUTE_URL'
	-- return (pageUrl .. '/'):match '://(.-)/'
	return pageUrl:match('^%w+://([^/]+)'):gsub('www.', ''):match '([^.]+)'
end

function savePlaylist(mediaType)
	assert(os.execute('mkdir -p ' .. dirPlaylists))
	local listName = '/' .. os.date '%Y-%m-%dT%H%M-' .. mediaType .. '-' .. getHost() .. '.m3u'
	assert(os.execute('mv ' .. tmpPlaylist .. ' ' .. dirPlaylists .. listName))
	assert(os.execute('rm -f ' .. tmpPlaylist))
end

function writeUrlToFile(filePath, url)
	local file = io.open(filePath, 'w')
	file:write(url)
	file:close()
end

function videoplay(url)
	writeUrlToFile(tmpPlay, url)
	assert(os.execute('mpv --profile=stream --playlist=' .. tmpPlay))
end

function videolist()
	assert(os.execute('mpv --profile=stream --playlist=' .. tmpPlaylist))
	savePlaylist 'video'
end

function videopopup(url)
	writeUrlToFile(tmpPlay, url)
	assert(os.execute('mpv --x11-name=videopopup --profile=stream-popup --playlist=' .. tmpPlay))
end

function popuplist()
	assert(os.execute('mpv --x11-name=videopopup --profile=stream-popup --playlist=' .. tmpPlaylist))
	savePlaylist 'video'
end

function audioplay(url)
	print('play')
	writeUrlToFile(tmpPlay, url)
	assert(os.execute( 'st -c audio -e mpv --ytdl --no-video --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M --playlist=' 
	.. tmpPlay))
end

function audiolist()
	assert( os.execute( 'st -c audio -e mpv --ytdl --no-video --cache=yes --demuxer-max-bytes=500M --demuxer-max-back-bytes=100M --input-ipc-server=/tmp/mpvsocket --playlist=' .. tmpPlaylist))
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
print(arg[1])
switch(cases, arg[1])(arg[2])
-- local ok, switchFunction = xpcall(switch, errorMsg, cases, arg[1])
-- if ok then
-- 	switchFunction(arg[2])
-- end
