#!/usr/bin/luajit

local branches = {}
local repoPath = arg[1] 
for branch in io.popen('git -C ' .. repoPath  .. ' branch'):lines() do
	table.insert(branches, branch )
end 

local chosen = rofiMenu(branches, {prompt = 'git checkout', width = '25ch'})

local status = os.execute('git -C ' .. repoPath .. ' checkout ' .. chosen)
if status == 0 then
	notify('Checked out to ' .. chosen)	
else
	notifyError('Could not checkout out to ' .. chosen)
end
