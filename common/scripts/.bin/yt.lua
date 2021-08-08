#!/bin/luajit
-- yt.lua [numberOfLinks] [video|audio]

VIDEO_DIR = '~/Videos/YouTube/'
AUDIO_DIR = '~/Musics/PODCASTS/' 
AUDIO_CMD = "| xargs -P 0 -I {} youtube-dl -f bestaudio -x --audio-format mp3 -o '".. AUDIO_DIR .. "%(title)s.%(ext)s' {}"
VIDEO_CMD = "| xargs -P 0 -I {} youtube-dl -o '".. VIDEO_DIR .. "%(title)s.%(ext)s' {}"

numberOfLinks = arg[1]
fileType = arg[2]

numberOfLinks = numberOfLinks and numberOfLinks or 1
local linksCmd = "clipster -co -n " .. numberOfLinks

local typeSwitch = (function(name,args)
	local sw = {
		["audio"]=function(args) return AUDIO_CMD end,
		["video"]=function(args) return VIDEO_CMD end,
		["#default"]=function() return AUDIO_CMD end
	}
	return (sw[name]and{sw[name]}or{sw["#default"]})[1](args)
end)


function download(cmd)
	local status = os.execute(linksCmd .. cmd)
	if status == 0 then
		return "Downloaded"
	else
		error("Could not download")
	end
end

local status, val = pcall(download(typeSwitch(fileType)))

os.execute("dunstify '" .. val .. "'")

