#!/bin/luajit
local function errorMsg(msg)
	if type(msg) == 'table' then
		msg = msg[1]
	end
	print 'errorMsg'
	printt(msg)
	log(msg, 'ERROR')
	notifyError(msg)
end

local taskConfirmationCmd = 'task rc.bulk=0 rc.confirmation=off rc.dependency.confirmation=off rc.recurrence.confirmation=off '
local contextPrefix = enum { ADD = '+', REMOVE = '-' }
local contextAliases = {
	code = 'cod',
	easy = 'eas',
	finance = 'fin',
	inbox = 'in',
	kindle = 'kin',
	laptop = 'lap',
	listen = 'lis',
	personal = 'per',
	routine = 'rou',
}

local option = arg[1]
arg[1] = ' '
local taskIDs = table.concat(arg, ' ')

-- show context or report
local function switchView()
	local views = copyt(contextAliases)
	views['none'] = 'none'
	views['pro'] = 'report'
	views['waiting'] = 'report'
	local selected = rofiMenu(views, 'Switch view')

	local stat
	if views[selected] == 'report' then
		stat = os.execute('taskwarrior-tui --report=' .. selected)
	else
		stat = os.execute('task context ' .. selected)
	end
	assert(stat == 0, "Coulden't switch view")
end

local function modifyTask(modification)
	local stat, _, err = run(taskConfirmationCmd .. 'modify ' .. modification .. ' ' .. taskIDs)
	assert(stat, err)
end

local function setPriority(priority)
	local priority = priority and priority or rofiMenu ({ ' ', 'L', 'M', 'H' }, 'Set priority')
	modifyTask('priority:' .. priority)
end

local function setProject(project)
	modifyTask('project:' .. project)
end

local function setContext(prefix, context)
	modifyTask(prefix .. contextAliases[context])
end

local function addProject()
	local name = rofiInput('Add project', '400px'):gsub('%s', '-')
	-- maybe check if empty cos it will delete project
	setProject(name)
end
local function setWait(prefix, date)
	modifyTask('wait:' .. date)
end

local function addTag()
	local tags = copyt(contextAliases)
	local _, projects = run 'task _projects'
	for _, project in ipairs(projects) do
		tags[project] = 'project'
	end
	tags['removeProject'] = 'project'
	tags['someday'] = 'wait'

	-- TODO change rofiMenu - it should return table via run() for multi-select
	local selected = rofiMenu(tags, 'Add tag')
	if tags[selected] == 'context' then
		setContext(contextPrefix.ADD, selected)
	elseif tags[selected] == 'wait' then
		setWait(contextPrefix.ADD, selected)
	else
		if selected == 'removeProject' then
			setProject ' '
		else
			setProject(selected)
		end
	end
end

local cases = {
	['view'] = switchView,
	['priority'] = setPriority,
	['add-tag'] = addTag,
	['add-project'] = addProject,
	['rm-inbox'] = function() setContext(contextPrefix.REMOVE, 'inbox') end,
	['rm-context'] = function() setContext(contextPrefix.REMOVE, rofiMenu(contextAliases, 'Remove context')) end,
	[false] = function() errorMsg 'Invalid command argument' end,
}

local switchFunction = switch(cases, option)

xpcall(switchFunction, errorMsg)

-- IDK how to retrive all tags _context returns only defined contexts 
	-- local tags = {}
	-- local _, contexts = run 'task _context'
	-- for _, context in ipairs(contexts) do
	-- 	tags[context] = 'context'
	-- end
