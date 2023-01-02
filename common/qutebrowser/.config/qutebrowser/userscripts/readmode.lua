#!/usr/bin/luajit

local quteFifo = os.getenv 'QUTE_FIFO'
local URL = os.getenv 'QUTE_URL'
notify(URL)
-- run('cp ' .. URL .. ' /tmp/test.html')

writef('rdrview "' .. URL.. '"', '/tmp/cmd')
local status,out,err = run('/usr/bin/rdrview "' .. URL.. '"')
notify(tostring(status))
writef(err, '/tmp/err')


-- io.open(quteFifo, 'a'):write('scroll-to-anchor ' .. anchor)
