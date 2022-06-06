#!/usr/bin/luajit

package.path = '/home/miro/Documents/dotfiles/common/scripts/.bin/' .. package.path
util = require 'scriptsUtil'

local gumbo = require 'gumbo'
local quteFifo = os.getenv 'QUTE_FIFO'
local htmlPath = os.getenv 'QUTE_HTML'
local document = gumbo.parseFile(htmlPath)

local anchors = {}
local headerTags = { 'h1', 'h2', 'h3', 'h4', 'h5', 'h6' }

for h, header in ipairs(headerTags) do
	local codeElements = assert(document:getElementsByTagName(header))
	for i, element in ipairs(codeElements) do
		if element:hasAttribute 'id' then
			anchors[h .. '. ' .. element.textContent] = element.id
		end
	end
end

local selectedAnchor = util.menu(anchors)

if selectedAnchor ~= '' then
	local anchor = anchors[selectedAnchor]
	if not anchor then
		anchor = selectedAnchor
	end
	io.open(quteFifo, 'a'):write('scroll-to-anchor ' .. anchor)
end

-- io.open(quteFifo, 'a'):write("message-info 'anchor not found'" )
-- local selectedAnchor = util.select(anchors, 'headings')
-- io.open('/tmp/qb-output', 'w+'):write(anchors[selectedAnchor])
-- io.open(quteFifo, 'a'):write("message-info 'Bookmark added to Buku!'" )
-- local foo = document:getElementById 'messages'
