#!/bin/luajit
-- dependencies zenity, gcalcli
-- can't have both params a and t/mon/next week
-- can't have both params duration time and t/mon/next week
-- maybe add list with params
CONFIG = '/home/miro/.config/gcalcli'
function zenity()
	local zenityCmd = [[ zenity --forms --title="reminder" \
	--text="adding 'a' in Hour will add event for all day \n
	adding sting in duration \n[t | tomorrow | next week | mon tue wed thu fri sat sun]" \
	--add-entry="Title" \
	--add-entry="Hour" \
	--add-entry="Minutes" \
	--add-entry="Duration [h]" \
	--add-calendar="Date" \
	--forms-date-format=%m/%d/%Y \
	--add-entry="Description" \
	]]
	-- # --add-entry="Where" \
	-- # --add-entry="Reminder" \

	return io.popen(zenityCmd):read("*a")
end 

function createGcalCmd(inputs) 
	local title, hour, minutes, duration, date, description = inputs:match("%s*(.-)|%s*(.-)|%s*(.-)|%s*(.-)|%s*(.-)|%s*(.-)\n")

	if title == '' then error('Provide title') end
	if duration == '' then duration = 1 end
	if hour == '' then  hour = 12 end
	if minutes == '' then minutes = 00 end

	local gcalCmd = ''
	if hour == 'a' then 
		gcalCmd = 'gcalcli --config-folder="' .. CONFIG .. '" --calendar "arek" add --title "' .. title .. '" --allday --when "' .. date .. '" --duration "' .. duration .. '" --description "' .. description ..'" --where " " --reminder "10m popup"'
	elseif duration == 't' then
		gcalCmd = 'gcalcli --config-folder="' .. CONFIG .. '" --calendar "arek" add --title "' .. title .. '" --when "tomorrow ' .. hour .. ':' .. minutes .. '" --duration 60 --description "' .. description ..'" --where " " --reminder "10m popup"'
	elseif tonumber(duration) then -- duration is a number
		local duration_in_minutes = tonumber(duration) * 60
		gcalCmd = 'gcalcli --config-folder="' .. CONFIG .. '" --calendar "arek" add --title "' .. title .. '" --when "' .. date .. ' ' .. hour .. ':' .. minutes .. '" --duration ' .. duration_in_minutes .. ' --description "' .. description ..'" --where " " --reminder "10m popup"'
	else
		gcalCmd = 'gcalcli --config-folder="' .. CONFIG .. '" --calendar "arek" add --title "' .. title .. '" --when "' .. duration .. ' ' .. hour .. ':' .. minutes .. '" --duration 60 --description "' .. description ..'" --where " " --reminder "10m popup"'
	end

	assert(os.execute(gcalCmd) == 0, "Can not add event")
	return "Added event - "  .. title
end

form = zenity()
local status, val = pcall(createGcalCmd, form)
print(status, val)

os.execute("notify-send '" .. val .. "'")
