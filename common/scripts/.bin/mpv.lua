#!/usr/bin/luajit

-- TODO change to init.lua
package.path = '/home/miro/Documents/dotfiles/common/scripts/.bin/' .. package.path
util = require 'scriptsUtil'

local tmpPlaylist = '/tmp/qt_mpvplaylist.m3u'
local tmpPlay = '/tmp/qt_mpv.m3u'
local dirPlaylists = os.getenv 'HOME' .. '/Templates/mpvlists'

function errorMsg(msg)
	util.notify('Error: ' .. msg)
	-- notifyError(msg)
end

function getHost()
	local pageUrl = os.getenv 'QUTE_URL'
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
	local file = io.open(filePath, 'w')
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
	assert(io.open(tmpPlaylist, 'a'):write(url .. '\n') == 0, 'Did not save url to playlist')
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

local switchFunction = util.switch(arg[1], cases)
-- local switchFunction = switch(cases, arg[1])
local ok = xpcall(switchFunction, errorMsg, arg[2])
if ok then
	-- notify(arg[1])
end
