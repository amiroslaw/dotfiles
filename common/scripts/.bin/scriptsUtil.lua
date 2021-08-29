#!/bin/luajit
util = {}

function util.const(tab)
	local meta_table = {
		__index = function(self, key)
			if tab[key] == nil then
				error("Attepted access a non existant field: " .. key)
			end
			return tab[key]
		end,
		__newindex = function(self, key, value)
			error("Attepted to modify const table: " .. key .. " " .. value)
		end,
		__metatable = false
	}
	return setmetatable({}, meta_table)
end

function util.notify(msg)
	print(msg)
	os.execute("dunstify '" .. msg .. "'")
end 

function util.errorHandling(msg)
	os.execute("dunstify -u critical Error: '" .. msg .. "'")
	-- util.notify('Error: ' .. msg .. ' ')
	error(msg) -- does not work
end

function util.input(prompt, width)
	prompt = prompt and prompt or 'Input'
	width = width and width or 500
	return io.popen('rofi -monitor -4 -width ' .. width .. ' -lines 0 -dmenu -p "'.. prompt ..'"'):read('*a'):gsub('\n', '')
end 

function util.numberInput(prompt)
	local input
	repeat
		input = util.input(prompt, '-'.. #prompt + 8)
	until tonumber(input)
	return input
end 

function util.select(optionTab, prompt)
	local prompt = prompt and prompt or 'Select'
	local options = ''
	local lines = 0
	for name,val in pairs(optionTab) do
		options = options  .. val	.. '|'
		lines = lines + 1
	end
	return io.popen('echo "' .. options .. '" | rofi -monitor -4 -i -lines ' .. lines .. ' -sep "|" -dmenu -p "' .. prompt .. '"'):read('*a'):gsub('\n', '')
end

function util.menu(unorderTab)
	local optionTab = {}
	for name,val in pairs(unorderTab) do
		table.insert(optionTab, name)
	end
	return util.select(optionTab)
end

function util.split(str, delimiter)
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
	return result
end

-- key=value format
function getConfigProperties(path)
	assert(os.execute( "test -f " .. path ) == 0, 'Config file does not exist: ' .. path)
	local properties = {}
	for line in io.lines(path) do
		local property = util.split(line, '=')
		properties[property[1]:gsub('%s', '')] = property[2]:gsub('%s', '')
	end
	return properties
end

return util
