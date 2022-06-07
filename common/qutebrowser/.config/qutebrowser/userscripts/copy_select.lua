#!/usr/bin/luajit

package.path = '/home/miro/Documents/dotfiles/common/scripts/.bin/' .. package.path
util = require 'scriptsUtil'
local gumbo = require 'gumbo'

local selectedHtml = os.getenv 'QUTE_SELECTED_HTML'
local quteFifo = os.getenv 'QUTE_FIFO'

local document = gumbo.parse(selectedHtml)
local selectedTxt = document:getElementsByTagName '*'
selectedTxt = selectedTxt[1].textContent

-- won't work. IDK how to pass an argument to command hint p userscript copy_select.lua
if arg[1] == 'split' then
	local sentenses = {}
	for match in selectedTxt:gmatch '([^.?!]+)' do
		table.insert(sentenses, match)
	end
	selectedTxt = util.select(sentenses, 'Sentense')
end

-- if arg[1] == 'url' then
for i, element in ipairs(document.links) do
	selectedTxt = selectedTxt .. '\n' .. element:getAttribute 'href'
end
-- end

local ok = os.execute('echo "' .. selectedTxt .. '" | xclip -sel clip')
if ok then
	io.open(quteFifo, 'a'):write 'message-info Copied'
else
	io.open(quteFifo, 'a'):write 'message-error Coping field'
end

-- io.open(quteFifo, 'a'):write("message-info 'anchor not found'" )
-- local selectedAnchor = util.select(anchors, 'headings')
-- io.open('/tmp/qb-output', 'w+'):write(anchors[selectedAnchor])
-- io.open(quteFifo, 'a'):write("message-info 'Bookmark added to Buku!'" )
-- local foo = document:getElementById 'messages'
