#!/usr/bin/luajit
-- TODO save to different file cos it will overrite after refresh

local quteFifo = os.getenv 'QUTE_FIFO'
local URL = os.getenv 'QUTE_URL'
local HTML_PATH = '/tmp/qt-reader-mode.html'
-- local MODE = os.getenv 'QUTE_MODE'

local okCreate,out, err = run('rdrview -H "' .. URL.. '" > ' .. HTML_PATH)

if okCreate then
	io.open(quteFifo, 'a'):write('open -t file://' .. HTML_PATH)
else
	io.open(quteFifo, 'a'):write('message-error ' .. err[1])
end

