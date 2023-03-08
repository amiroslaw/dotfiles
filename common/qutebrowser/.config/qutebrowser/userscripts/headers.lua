#!/usr/bin/luajit

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
-- or search href=#...

local selectedAnchor, code = rofiMenu(anchors, {prompt = 'Jump to header'})

if code then
	local anchor = anchors[selectedAnchor]
	if not anchor then
		anchor = selectedAnchor
	end
	io.open(quteFifo, 'a'):write('scroll-to-anchor ' .. anchor)
end
