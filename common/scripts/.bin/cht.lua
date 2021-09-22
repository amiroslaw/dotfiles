#!/bin/luajit
package.path = '/home/miro/Documents/dotfiles/common/scripts/.bin/' .. package.path
util = require('scriptsUtil')

topics = {
	lua = "lang",
	java = 'lang',
	js = 'lang',
	typescript = 'lang',
	kotlin = 'lang',
	css = 'lang',
	html = 'lang',
	xargs = 'app',
	sed = 'app',
	awk = 'app',
	find = 'app',
	ls = 'app'
}

local tmpname = os.tmpname()
function fetchAnswer(topic, query)
	local status
	if topics[topic] == 'lang' then
		if query == '' then query = ':list' end
		status = os.execute('curl cht.sh/' .. topic .. '/' .. query .. ' > ' .. tmpname)
	else
		status = os.execute('curl cht.sh/' .. topic .. '~' .. query .. ' > ' .. tmpname)
	end
	assert(status == 0, 'Can not fetch data')
end

selectedTopic = util.menu(topics)
query = util.input('Question (:learn; def=:list)')
query = query:gsub('%s', '+')

ok, answer = pcall(fetchAnswer, selectedTopic, query)
if not ok then
	util.errorHandling(ok)
end

-- terminal = os.getenv('TERM')
-- ?T without ascii
os.execute("alacritty --class cheatsh -e less -R " .. tmpname)
