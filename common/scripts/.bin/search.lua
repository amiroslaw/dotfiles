#!/bin/luajit
HELP = [[
Utils for working with todo list.
todo.lua option
List of the options:

		add - add task
		show - show todo tasks for current day.
		-h help - show help

-- dependency: zenity
]]
todoPath = os.getenv('NOTE') ..  '/ZADANIA/week.todo'
function show() 
	local todoTxt = io.input(todoPath):read("*a")
	local start, last = todoTxt:find("# Week")
	local todayTxt = string.sub(todoTxt, 1, start -1)

	os.execute('echo "' .. todayTxt .. '" | zenity --text-info')
end
function add() 
	task = io.popen('zenity --entry --text="Add task"'):read('*a')
	file = io.open(todoPath, "a+")
	file:write("- [ ] " .. task)
	file:close()

	os.execute('dunstify "Task added"')
end
local switch = (function(name,args)
	local sw = {
		["add"] = add,
		["show"] = show,
		["-h"]= function() print(HELP); os.exit() end,
		["#default"] = show
	}
	return (sw[name]and{sw[name]}or{sw["#default"]})[1](args)
end)
switch(arg[1])