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
	local ok, err = run('todo.sh -p ls @t' .. ' | zenity --text-info')
	-- local todoTxt = io.input(todoPath):read("*a")
	-- local start, last = todoTxt:find("# Week")
	-- local todayTxt = string.sub(todoTxt, 1, start -1)
 --
	-- os.execute('echo "' .. todayTxt .. '" | zenity --text-info')
end
function add() 
	local task = io.popen('zenity --entry --text="Add task"'):read('*a')
	local ok, err = run('todo.sh add "' .. task .. '" +x')
	-- file = io.open(todoPath, "a+")
	-- file:write("- [ ] " .. task)
	-- file:close()

	if ok then
		os.execute('dunstify "Task added"')
	else
		notifyError(err[1])
	end
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
