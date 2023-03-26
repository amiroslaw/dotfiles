#!/bin/luajit

HELP = [[
Utils for working with notes.
note.lua clip|sel|write|-h [number]
List of the options:
	clip, clipboard - clip notes from secondary clipboard 
	sel, selection - clip notes from primary (selection) clipboard 
	write - write note form form input
	number - number of clipboard history, if it will be empty, input form will appear
	-h help - write help

-- dependency: rofi, clipster
]]
FILE_PATH = os.getenv('NOTE') ..  '/clip.adoc'
action = arg[1]
clipboard = 'primary'

if not action then 
	notifyError('Provide argument')
end

function clipster(clipboard) 
	local clipType = clipboard
	return function()
		local delimiter = '~#~'
		local clipboardAmount = 1
		if not arg[2] then clipboardAmount = rofiNumberInput('Number of clips') 
		else
			clipboardAmount = arg[2]
		end

		-- local clipElements = io.popen("clipster --output --" .. clipType .. " -n " .. clipboardAmount):read('*a') -- for LIFO order
		local clipElements = {}
		local clipsterOutput = io.popen("clipster --output --delim " .. delimiter .. " --" .. clipType .. " -n " .. clipboardAmount + 1):read('*a')
		assert(#clipsterOutput ~= 0, "Can not get clipboard history")

		for token in clipsterOutput:gmatch("(.-)" .. delimiter) do
			table.insert(clipElements, token)
		end
		
		local revertedClip = ''
		for i=1, #clipElements do
			revertedClip = revertedClip .. clipElements[#clipElements + 1 - i] .. '\n'
		end
		return revertedClip
	end
end

function writeNote() 
	return '\n' .. rofiInput({prompt = 'Note', width = '70%'}) .. '\n'
end

function writeToFile(text) 
	file = io.open(FILE_PATH, "a+")
	file:write('\n' .. text)
	file:close()
	return 'Copied to ' .. FILE_PATH
end

local switch = (function(name)
	local sw = {
		["clip"]= clipster('clipboard'),
		["clipboard"]= clipster('clipboard'),
		["sel"]= clipster('primary'),
		["selection"]= clipster('primary'),
		["write"] = writeNote,
		["-h"]= function() print(HELP); os.exit() end,
		["#default"]= clipster('primary'),
	}
	return (sw[name]and{sw[name]}or{sw["#default"]})[1]
end)

local exec = switch(action)
local ok, val = pcall(exec)

if not ok then 
	log(val, 'ERROR')
	notifyError(val)
else
	local ok, out = pcall(writeToFile, val)
	notify(val)
end

