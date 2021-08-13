#!/bin/luajit
util = {}
function util.notify(msg)
	print(msg)
	os.execute("dunstify '" .. msg .. "'")
end 

function util.errorHandling(msg)
	util.notify('Error: ' .. msg)
	-- error(msg) -- does not work
end

function util.input(prompt, width)
	prompt = prompt and prompt or 'Input'
	width = width and width or 500
	return io.popen('rofi -monitor -4 -width ' .. width .. ' -lines 0 -dmenu -p "'.. prompt ..'"'):read('*a')
end 

function util.numberInput(prompt)
	local input
	repeat
		input = util.input(prompt, '-'.. #prompt + 8)
	until tonumber(input)
	return input
end 


return util
