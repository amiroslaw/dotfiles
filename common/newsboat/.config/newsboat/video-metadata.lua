#!/usr/bin/luajit
local toBoolean = { ['True'] = true, ['False'] = false }

local ok, metadata, err = run('yt-dlp -i --print title,duration_string,like_count,view_count,is_live,live_status "' .. arg[1] .. '"')

if not ok and err:match ' in %d+' then
	local due = err:match '%d+%s%w+'
	local msg = split(err, ':')[3]
	notify('Due:', msg, {due})
	-- notify(split(err, ':')[3])
elseif ok then
	local msg = ''
	local isLive = toBoolean[metadata[5]]
	if isLive then
		msg = msg .. 'Live status: ' .. metadata[6]
	else
		msg = msg .. 'Duration: ' .. metadata[2]
	end
	msg = msg .. '<br>Like/Views: ' .. metadata[3] .. '/' .. metadata[4]
	style = {
		metadata[2],
		[metadata[6]] = 'red',
	}
	notify(metadata[1], msg, style)
else
	notifyError(err)
end

--[[
--
-- Possible options and outputs
-- notify-send --icon=clock -t 4000 "<i>Time Now</i>" "<span color='#57dafd' font='26px'><i><b>phrase</b></i></span>" >/dev/null 2>&1
description,original_url, title,duration_string,like_count,view_count,live_status,is_live,playable_in_embed 
• live_status (string): One of “not_live”, “is_live”, “is_upcoming”, “was_live”, “post_live” (was live, but VOD is not yet processed)
• is_live (boolean): Whether this video is a live stream or a fixed-length video
• was_live (boolean): Whether this video was originally a live stream
• playable_in_embed (string): Whether this video is allowed to play in embedded players on other sites
• subtitles_table (table): The subtitle format table as printed by --list-subs
,dislike_count - NA

live stream 
duration  NA 
live_status is_live
• is_live  True
• playable_in_embed  True

is_upcoming 
error will begin in..

shorts
• is_live not_live
• was_live False 
• playable_in_embed 
--]]
