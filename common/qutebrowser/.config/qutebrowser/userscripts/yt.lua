#!/usr/bin/luajit

local quteFifo = os.getenv 'QUTE_FIFO'
local url = os.getenv 'QUTE_URL'
local selectedHtml = os.getenv 'QUTE_SELECTED_HTML'
local ytAlternative = 'piped.kavin.rocks'
local cmd = 'open '


if url:match(ytAlternative) then
	cmd = cmd .. url
elseif selectedHtml then
	cmd = cmd .. '-t p ' .. url
else
	cmd = cmd .. 'p ' .. url
end

io.open(quteFifo, 'a'):write(cmd)


-- local gumbo = require 'gumbo'
-- local ytDomain = 'https://www.youtube.com'
-- for selectedHtml
	-- local document = gumbo.parse(selectedHtml)
	-- url = document.links[1]:getAttribute 'href'
	-- cmd = cmd .. '-t p ' .. ytDomain .. url
	-- local url = document:getElementById('thumbnail'):getAttribute('href')
