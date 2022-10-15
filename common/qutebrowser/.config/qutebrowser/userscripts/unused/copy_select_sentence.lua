#!/usr/bin/luajit

local gumbo = require 'gumbo'

local selectedHtml = os.getenv 'QUTE_SELECTED_HTML'
local quteFifo = os.getenv 'QUTE_FIFO'

local document = gumbo.parse(selectedHtml)
local selectedTxt = document:getElementsByTagName '*'
selectedTxt = selectedTxt[1].textContent

local sentenses = {}
for match in selectedTxt:gmatch '([^.?!]+)' do
	table.insert(sentenses, match)
end
selectedTxt = rofiMenu(sentenses, {prompt = 'Sentense'})

local ok = os.execute('echo "' .. selectedTxt .. '" | xclip -sel clip')
if ok then
	io.open(quteFifo, 'a'):write 'message-info Copied'
else
	io.open(quteFifo, 'a'):write 'message-error Coping field'
end
