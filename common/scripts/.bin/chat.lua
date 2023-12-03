#!/bin/luajit
local prompt = rofiInput({prompt = '  ', width = '70%'})
if prompt == '' then
	os.exit(1)
end
local OUT_DIR ='/tmp/txt/'
local DATE_STAMP= os.date('%d-%H%M%S')
local FILE = OUT_DIR .. 'ollama-' .. DATE_STAMP .. '.txt'
os.execute('mkdir -p ' .. OUT_DIR)

local OLLAMA_API_HOST = os.getenv 'OLLAMA_API_HOST'
local host = OLLAMA_API_HOST and OLLAMA_API_HOST or 'http://localhost:11434'

local model = 'mistral'
local serverCallCmd = [[
curl %s/api/generate -d '{ "model": "%s", "prompt": "%s", "stream": false }' | jq -r '.response'
]]

local function handleServiceError(answer)
	if answer == '' then
		notifyError('Failed to connect to ' .. host)
		os.exit(1)
	end
end

-- print(serverCallCmd:format(host, model, prompt))
local answer = io.popen(serverCallCmd:format(host, model, prompt)):read '*a'
handleServiceError(answer)
print('----------------------------------------------\n')
print(answer)

writef(answer, FILE)

os.execute('st -c chat -n chat -e nvim ' .. FILE)
-- # zenity --info --text="$ANSWER"
-- # wezterm start --class read -- nvim  $FILE
