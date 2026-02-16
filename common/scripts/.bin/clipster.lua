#!/bin/luajit
-- TODO maybe reverse clipboard history when it join the elements

HELP = [[
Utils for working clipster program.
clipster.lua option [number]
List of the options:

		--join -j → join clipster history elements
		--next -n → get next element from clipboard history
		--clipboard -c → clip notes from secondary clipboard 
		--primary -p → clip notes from primary (selection) clipboard (default)
		-h show help

-- dependency: clipster, rofi
]]

local args = cliparse(arg, 'number')

local clipType = 'primary'
if args.clipboard or args.c then
	clipType = 'clipboard'
end

local number = 1
if args.number then
	number = args.number[1]	
end

function paste()
	local ok = os.execute('xdotool sleep 0.100 key --clearmodifiers ctrl+v')
	if not ok then error("Can not paste") end
end

function nextClip() 
	-- local clipsterOutput = io.popen("clipster --output -0 -N 1 -m '' --clipboard"):read('*a'):gsub('\0', '\n')
	local clipsterOutput = io.popen("clipster --output -N " .. number .. " -m '' --" .. clipType):read('*a')
	assert(#clipsterOutput ~= 0, "Can not get clipboard history")
	
	if os.execute('echo -n "' .. clipsterOutput .. '" | clipster --clipboard') == 0 then 
		paste()
	else
		error("Can not get clipboard history") 
	end
	return 'Got next ' .. clipType .. ' clipboard: ' .. clipsterOutput
end

function join() 
	if number == 1 then number = rofiNumberInput('Number of clips') end
	local clipsterOutput = io.popen("clipster --output --" .. clipType .. " -n " .. number):read('*a')
	assert(#clipsterOutput ~= 0, "Can not get clipboard history")
	assert(os.execute('echo "' .. clipsterOutput .. '" | clipster --clipboard') == 0, "Can not get clipboard history")
	return 'Joined ' .. clipType
end

local function help() print(HELP); os.exit() end

local options = {
	["next"] = nextClip,
	["n"] = nextClip,
	["join"] = join,
	["j"] = join,
	["h"]= help,
}

local action = help

for key,_ in pairs(args) do
	local selection = switch(options, key)
	if selection and args[key] then
		action = selection
	end
end

local ok, val = pcall(action)
print(val)
-- if not ok then notifyError('Clipster.lua error') end
