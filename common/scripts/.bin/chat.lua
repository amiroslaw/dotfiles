#!/bin/luajit
local OUT_DIR ='/tmp/txt/'
local DATE_STAMP= os.date('%d-%H%M%S')
local FILE = OUT_DIR .. 'ollama-' .. DATE_STAMP .. '.txt'
local OLLAMA_API_HOST = os.getenv 'OLLAMA_API_HOST'
local termRun = os.getenv 'TERM_LT' .. os.getenv 'TERM_LT_RUN'
local host = OLLAMA_API_HOST and OLLAMA_API_HOST or 'http://localhost:11434'
local tagsCmd = ("curl %s/api/tags | jq -r '.models[].name' | rofi -dmenu"):format(host)
local generateCmd = [[ 
curl %s/api/generate -d '{ "model": "%s", "prompt": "%s", "stream": false }' | jq -r '.response'
]]
local model = 'mistral:latest'

local function handleServiceError(answer)
	if answer and answer == '' then
		notifyError('Failed to connect to ' .. host)
		os.exit(1)
	end
end

if arg[1] and arg[1] == 'list' then
	model = io.popen(tagsCmd:format(host)):read '*l'
	handleServiceError(model)
end

local prompt = rofiInput({prompt = '  ', width = '70%'})
if prompt == '' then
	os.exit(1)
end

-- escape: '
prompt = prompt:gsub("'", "'\\''")
local answer = io.popen(generateCmd:format(host, model, prompt)):read '*a'
print(generateCmd:format(host, model, prompt))
handleServiceError(answer)

print('----------------------------------------------\n')
print(answer)

os.execute('mkdir -p ' .. OUT_DIR)
writef(answer, FILE)

os.execute(termRun:format('chat', 'nvim ' .. FILE))
-- # zenity --info --text="$ANSWER"
-- # wezterm start --class read -- nvim  $FILE
