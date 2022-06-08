#!/usr/bin/luajit
-- TODO maybe add flag for url of the website that it copied from, don't forget to add the second arg in the wrapper script

package.path = '/home/miro/Documents/dotfiles/common/scripts/.bin/' .. package.path
util = require 'scriptsUtil'
local gumbo = require 'gumbo'

local selectedHtml = os.getenv 'QUTE_SELECTED_HTML'
local quteFifo = os.getenv 'QUTE_FIFO'


local arg = io.open('/tmp/qute-arg', 'r'):read('*all')

local document = gumbo.parse(selectedHtml)
local selectedTxt = document:getElementsByTagName '*'
selectedTxt = selectedTxt[1].textContent

if arg == '--split' then
	local sentenses = {}
-- regex = '[^%.!?]+[!?%.]%s*'
-- regex = '.-[!?:%.]'
-- regex = '.-[!?:%.]%s'
	regex = ".-[%.:!?]%f[%z%s]"
	for match in selectedTxt:gmatch(regex) do
		table.insert(sentenses, match)
	end
	selectedTxt = util.select(sentenses, 'Sentense')
end

if arg == '--url' then
	for i, element in ipairs(document.links) do
		selectedTxt = selectedTxt .. '\n' .. element:getAttribute 'href'
	end
end

local ok = os.execute('echo "' .. selectedTxt .. '" | xclip -sel clip')
if ok then
	io.open(quteFifo, 'a'):write('message-info "Copied')
	-- io.open(quteFifo, 'a'):write('message-info "Copied: ' .. util.split(selectedTxt, '\n')[1] .. '"')
else
	io.open(quteFifo, 'a'):write('message-error Coping field')
end

-- io.open(quteFifo, 'a'):write("message-info 'anchor not found'" )
-- local selectedAnchor = util.select(anchors, 'headings')
-- io.open('/tmp/qb-output', 'w+'):write(anchors[selectedAnchor])
-- io.open(quteFifo, 'a'):write("message-info 'Bookmark added to Buku!'" )
-- local foo = document:getElementById 'messages'
