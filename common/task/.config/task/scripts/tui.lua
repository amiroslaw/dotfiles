#!/bin/luajit
local function errorMsg(msg)
	printt(msg)
	log(msg, 'ERROR')
	notifyError(msg)
end

local taskConfirmationCmd = 'task rc.bulk=0 rc.confirmation=off rc.dependency.confirmation=off rc.recurrence.confirmation=off '
local contextPrefix = enum { ADD = '+', REMOVE = '-' }
local contextAliases = {
	inbox = 'in',
	routine = 'rou',
	carrer = 'car',
	code = 'cod',
	finance = 'fin',
	personal = 'per',
	laptop = 'lap',
	kindle = 'kin',
	listen = 'lis',
	easy = 'eas',
	next = 'next',
}

local option = arg[1]
arg[1] = ' '
local taskIDs = table.concat(arg, ' ')

-- show context or report
local function switchView()
	local views = M.clone(contextAliases)
	views['none'] = 'none'
	views['pro'] = 'report'
	views['waiting'] = 'report'
	views['completed'] = 'report'
	local selected, code = rofiMenu(views, {prompt = 'Switch view', width = '25ch'})
	selected = code and selected or 'none'
	local stat
	if views[selected] == 'report' then
		stat = os.execute('taskwarrior-tui --report=' .. selected)
	else
		stat = os.execute('task context ' .. selected)
	end
	assert(stat == 0, "Coulden't switch view")
end

local function modifyTask(modification)
	local stat, _, err = run(taskConfirmationCmd .. 'modify ' .. modification .. ' ' .. taskIDs, "Can't modify")
	assert(stat, err)
end

local function setPriority(priority)
	local priority = priority and priority or rofiMenu({ ' ', 'L', 'M', 'H' }, {prompt = 'Set priority', width = '15ch'})
	modifyTask('priority:' .. priority)
end

local function setContext(prefix, context)
	modifyTask(prefix .. contextAliases[context])
end

local function setProject(project)
	modifyTask('project:' .. project)
end

local function addProject()
	local name = rofiInput({prompt ='Add project', width = '400px'}):gsub('%s', '-')
	-- maybe check if empty cos it will delete project
	setProject(name)
end

local function setWait(date)
	if date == 'wait/someday' then
		modifyTask('wait:' .. '2038-01-18')
	else
		modifyTask('wait:' .. date)
	end
end

local function modifyTag(tag, alias)
	if alias == 'project' then
		setProject(tag:gsub('^#', ''))
	elseif alias == 'wait' then
		setWait(tag)
	else
		setContext(contextPrefix.ADD, tag)
	end
end

-- projects have `#` prefix
-- new item is a new project
local function addTag()
	local tags = M.clone(contextAliases)
	local _, projects = run 'task _projects'
	for _, project in ipairs(projects) do
		project = project:gsub('^%a', '#' .. project:match '^%a')
		tags[project] = 'project'
	end
	tags['wait/someday'] = 'wait'

	local selection, code = rofiMenu(tags, {prompt ='Add tag', multi = true})
	if not code then return end
	for _, sel in ipairs(selection) do
		modifyTag(sel, tags[sel])
	end
end

local function removeTag()
	local tags = M.clone(contextAliases)
	tags['remove project'] = 'project'
	tags['all contexts'] = 'allContexts'
	tags['wait/someday'] = 'wait'
	local selected, code = rofiMenu(tags, {prompt = 'Remove tag', width = '25ch'})
	if not code then return end

	if tags[selected] == 'project' then
		setProject ''
	elseif tags[selected] == 'wait' then
		setWait ''
	elseif tags[selected] == 'allContexts' then
		--TODO loop all tasks  task _get id.tags
	else
		setContext(contextPrefix.REMOVE, selected)
	end
end

local function sync()
	local stat, _, err = run('task sync', "Can't sync")
	assert(stat, err)
	notify 'Synchronized'
end

local function openInBrowser(url)
	local stat, _, err = run('xdg-open "' .. url .. '"')
	assert(stat, err)
end

local function parseUrls(taskId, annotationId)
	local urlPattern = '(https?://([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w%w%w?%w?)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'
	local _, annotation = run('task _get ' .. taskId .. '.annotations.' .. annotationId .. '.description')
	for match in annotation[1]:gmatch(urlPattern) do
		openInBrowser(match)
	end
end

local function openUrl()
	for i = 2, #arg do
		local taskId = arg[i]
		local stat, annoCount, err = run('task _get ' .. taskId .. '.annotations.count', "Can't open url from task: " .. taskId)
		assert(stat, err)
		for j = 1, annoCount[1] do
			parseUrls(taskId, j)
		end
	end
end

local function duplicate()
	local stat, _, err = run(taskConfirmationCmd .. 'duplicate ' .. taskIDs, "Can't duplicate " .. taskIds)
	assert(stat, err)
end

local cases = {
	['view'] = switchView,
	['priority'] = setPriority,
	['add-tag'] = addTag,
	['add-project'] = addProject,
	['rm-inbox'] = function()
		setContext(contextPrefix.REMOVE, 'inbox')
	end,
	['rm-tag'] = removeTag,
	['sync'] = sync,
	['url'] = openUrl,
	['duplicate'] = duplicate,
	[false] = function()
		errorMsg 'Invalid command argument'
	end,
}

local switchFunction = switch(cases, option)

xpcall(switchFunction, errorMsg)

-- with not hardcoded contexts
-- IDK how to retrive all tags _context returns only defined contexts
-- local tags = {}
-- local _, contexts = run 'task _context'
-- for _, context in ipairs(contexts) do
-- 	tags[context] = 'context'
-- end
