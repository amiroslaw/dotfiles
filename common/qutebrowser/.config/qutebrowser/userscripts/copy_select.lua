#!/usr/bin/luajit
-- TODO maybe add flag for url of the website that it copied from, don't forget to add the second arg in the wrapper script

package.path = '/home/miro/Documents/dotfiles/common/scripts/.bin/' .. package.path
util = require 'scriptsUtil'
local gumbo = require 'gumbo'

local selectedHtml = os.getenv 'QUTE_SELECTED_HTML'
local quteFifo = os.getenv 'QUTE_FIFO'
local readerTmp = '/tmp/qute-speedread.txt'

local arg = ''
local argFile = io.open('/tmp/qute-arg', 'r')
if argFile then
	arg = argFile:read '*all'
	argFile:close()
end

local document = gumbo.parse(selectedHtml)
local selectedTxt = document:getElementsByTagName '*'
selectedTxt = selectedTxt[1].textContent

if arg == '--split' then
	local sentenses = {}
	-- regex = '[^%.!?]+[!?%.]%s*'
	-- regex = '.-[!?:%.]'
	-- regex = '.-[!?:%.]%s'
	regex = '.-[%.:!?]%f[%z%s]'
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

if arg == '--speed' then
	local file = io.open(readerTmp, 'w')
	file:write(selectedTxt)
	file:close()
	os.execute( 'wezterm --config font_size=19.0 start --class rsvp -- sh -c "cat ' .. readerTmp .. ' | speedread -w 300"')
end

if arg == '--read' then
	local tmpName = os.tmpname()
	tmpName = tmpName .. '.txt'
	local file = io.open(tmpName, 'w')
	file:write(selectedTxt)
	file:close()
	os.execute('st -c read -n read -e nvim ' .. tmpName)
end

if arg == '--translate' then
	local fifo = io.open(quteFifo, 'a')
	fifo:write('open -t l ' .. selectedTxt)
	fifo:close()
end


local ok = os.execute('echo "' .. selectedTxt .. '" | xclip -sel clip')
if ok then
	io.open(quteFifo, 'a'):write 'message-info "Selected"'
	-- io.open(quteFifo, 'a'):write('message-info "Copied: ' .. util.split(selectedTxt, '\n')[1] .. '"')
else
	io.open(quteFifo, 'a'):write 'message-error Selection field'
end

-- io.open(quteFifo, 'a'):write("message-info 'anchor not found'" )
-- local selectedAnchor = util.select(anchors, 'headings')
-- io.open('/tmp/qb-output', 'w+'):write(anchors[selectedAnchor])
-- io.open(quteFifo, 'a'):write("message-info 'Bookmark added to Buku!'" )
