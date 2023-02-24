#!/usr/bin/luajit
-- TODO save to different file cos it will overrite after refresh
-- some css that I have but they arent custom to rader mode
--  darculized.css
--  gruvbox.css
--  reader-mode.css
-- solarized-dark.css

local quteFifo = os.getenv 'QUTE_FIFO'
local URL = os.getenv 'QUTE_URL'
local CSS_PATH = os.getenv 'QUTE_CONFIG_DIR' .. '/css/reader-solarized-light.css'
local HTML_PATH = os.getenv 'QUTE_DATA_DIR' .. '/reader-mode.html'
local CSS = '<link rel="stylesheet" type="text/css" href="' .. CSS_PATH ..'" />'
-- local MODE = os.getenv 'QUTE_MODE'
local okCreate, out, err = run('rdrview -H "' .. URL .. '" > ' .. HTML_PATH, 'Could not create html')
io.open(HTML_PATH, 'a+'):write(CSS)

if okCreate then
	io.open(quteFifo, 'a'):write('open -t file://' .. HTML_PATH)
else
	io.open(quteFifo, 'a'):write('message-error "' .. split(err, '\n')[1] .. '"')
	log(err, 'ERROR')
end
