#!/bin/luajit
package.path = '/home/miro/Documents/dotfiles/common/scripts/.bin/' .. package.path
util = require('scriptsUtil')

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
	util.errorHandling('Provide argument')
end

function clipster(clipType) 
	local delimiter = '~#~'
	local clipboardAmount = 1
	if not arg[2] then clipboardAmount = util.numberInput('Number of clips') 
	else
		clipboardAmount = arg[2]
	end

	-- local clipElements = io.popen("clipster --output --" .. clipType .. " -n " .. clipboardAmount):read('*a') -- for LIFO order
	local clipElements = {}
	local clipsterOutput = io.popen("clipster --output --delim " .. delimiter .. " --" .. clipType .. " -n " .. clipboardAmount + 1):read('*a')
	if #clipsterOutput == 0 then error("Can not get clipboard history") end

	for token in clipsterOutput:gmatch("(.-)" .. delimiter) do
		table.insert(clipElements, token)
	end
	
	revertedClip = ''
	for i=1, #clipElements do
		revertedClip = revertedClip .. clipElements[#clipElements + 1 - i] .. '\n'
	end
	return revertedClip
end

function writeNote() 
	return '\n' .. util.input('Note', 70) .. '\n'
end

function writeToFile(text) 
	file = io.open(FILE_PATH, "a+")
	file:write('\n' .. text)
	file:close()
	return 'Copied to ' .. FILE_PATH
end

local switch = (function(name,args)
	local sw = {
		["clip"]= function() return clipster, 'clipboard' end,
		["clipboard"]= function() return clipster, 'clipboard' end,
		["sel"]= function() return clipster, 'primary' end,
		["selection"]= function() return clipster, 'primary' end,
		["write"] = function() return writeNote end,
		["-h"]= function() print(HELP); os.exit() end,
		["#default"]= function() return clipster, 'primary' end
	}
	return (sw[name]and{sw[name]}or{sw["#default"]})[1](args)
end)

local exec, param = switch(action)
local ok, val = pcall(exec, param)

if not ok then 
	util.errorHandling(val)
else
	local ok, val = pcall(writeToFile, val)
	util.notify(val)
end
