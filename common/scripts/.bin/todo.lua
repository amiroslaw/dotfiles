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
todoPath = os.getenv('NOTE') ..  '/Zadania/inbox.adoc'
function show() 
	local ok, list, err = run('task rc.verbose=nothing minimal | zenity --text-info')
	if not ok then
		notifyError(err)
	end
	-- local ok, err = run('todo.sh -p ls @t' .. ' | zenity --text-info')
	-- local todoTxt = io.input(todoPath):read("*a")
	-- local start, last = todoTxt:find("# Week")
	-- local todayTxt = string.sub(todoTxt, 1, start -1)
	-- os.execute('echo "' .. todayTxt .. '" | zenity --text-info')
end

function add() 
	-- local ok, err = run('todo.sh add "' .. task .. '" +x')
	local task = io.popen('zenity --entry --text="Add task"'):read('*a')
	local file = io.open(todoPath, "a+")
	file:write("* [ ] " .. task)
	file:close()

	os.execute('notify-send "Task added"')
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
