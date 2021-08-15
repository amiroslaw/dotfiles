#!/bin/luajit
-- TODO maybe reverse clipboard history when it join the elements
package.path = '/home/miro/Documents/dotfiles/common/scripts/.bin/' .. package.path
util = require('scriptsUtil')

HELP = [[
Utils for working clipster program.
clipster.lua option clipboardType [number]
List of the options:

		join - join clipster history elements
		next - get next element from clipboard history
		clipboard - clip notes from secondary clipboard 
		primary - clip notes from primary (selection) clipboard 
		-h help - show help

-- dependency: clipster, rofi
]]

clipType = arg[2] and arg[2] or 'clipboard'

function paste()
	ok = os.execute('xdotool sleep 0.100 key --clearmodifiers ctrl+v')
	if not ok then error("Can not paste") end
end

function nextClip() 
	-- local clipsterOutput = io.popen("clipster --output -0 -N 1 -m '' --clipboard"):read('*a'):gsub('\0', '\n')
	local clipsterOutput = io.popen("clipster --output -N 1 -m '' --" .. clipType):read('*a')
	if #clipsterOutput == 0 then error("Can not get clipboard history") end
	
	if os.execute('echo -n "' .. clipsterOutput .. '" | clipster --clipboard') == 0 then 
		paste()
	else
		error("Can not get clipboard history") 
	end
	return 'Got next clipboard ' .. clipType
end

function join() 
	local clipboardAmount = 1
	if not arg[3] then clipboardAmount = util.numberInput('Number of clips') 
	else
		clipboardAmount = arg[3]
	end
	print("clipster --output --" .. clipType .. " -n " .. clipboardAmount)
	
	local clipsterOutput = io.popen("clipster --output --" .. clipType .. " -n " .. clipboardAmount):read('*a')
	if #clipsterOutput == 0 then error("Can not get clipboard history") end
	if os.execute('echo "' .. clipsterOutput .. '" | clipster --clipboard') ~= 0 then 
		error("Can not get clipboard history") 
	end
	return 'Joined ' .. clipType
end
local switch = (function(name,args)
	local sw = {
		["next"] = nextClip,
		["join"] = join,
		["-h"]= function() print(HELP); os.exit() end,
		["#default"] = nextClip
	}
	return (sw[name]and{sw[name]}or{sw["#default"]})[1](args)
end)

local exec, param = switch(arg[1])
local ok, val = pcall(exec, param)
-- if not ok then util.errorHandling('Clipster.lua error') end
