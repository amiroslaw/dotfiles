#!/bin/luajit

-- TODO 
-- generalize - for copied text/file; 
-- add more resources - files  
-- add more methods:  corrections;  
local help = [[
--model -m → override default model
--list -l → choose available model
--summary -s → summary text default from clipboard
--url -u → summary from text on website
]]

local OLLAMA_API_HOST = os.getenv 'OLLAMA_API_HOST'
local termRun = os.getenv 'TERM_LT' .. os.getenv 'TERM_LT_RUN'
local host = OLLAMA_API_HOST and OLLAMA_API_HOST or 'http://localhost:11434'
local prompt = ''
local generateCmd = [[ 
curl %s/api/generate -d '{ "model": "%s", "prompt": "%s", "stream": false }' | jq -r '.response'
]]

local function handleServiceError(answer)
	if answer and answer == '' then
		notifyError('Failed to connect to ' .. host)
		os.exit(1)
	end
end

local args = cliparse(arg, 'txt')
if args.help or args.h then
	print(help)
	os.exit(0)
end

local model = os.getenv 'AI_MODEL' and os.getenv 'AI_MODEL' or 'llama3:latest'
local function selectModel()
	model = args.model and args.model or model
	model = args.m and args.m or model
	if args.list or args.l then
		local tagsCmd = ("curl %s/api/tags | jq -r '.models[].name' | rofi -dmenu"):format(host)
		model = io.popen(tagsCmd:format(host)):read '*l'
		handleServiceError(model)
	end
	return model
end

local function urlToTxt(url)
	local cmd = ('rdrview -H -A "Mozilla" "%s" -T title | pandoc --from html --to plain --output -'):format(url)
	return  io.popen(cmd):read '*a'
end

local function summaryPrompt()
	local prompt = "Summarize (use asciidoc format with lists and bold text if needed) following text: "
	if args.url or args.u then
		local url = args.url and args.url or (args.u and args.u or args.url)
		prompt = prompt .. urlToTxt(url[1])
	else
		prompt = prompt .. io.popen("clipster --output -m '' --clipboard"):read('*a')
	end
	return prompt
	-- assert(#prompt ~= 0, "Can not get clipboard history")
end

local function escapeForJson(str)
  local escapes = {
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
    ["\b"] = "\\b",
    ["\\"] = "\\\\",
    -- ["\"'] = "\\\"", -- Escape both double quote and single quote
  }
  local function replace_char(char)
    return escapes[char] or ("\\u" .. string.format("%04X", string.byte(char)))
  end
  return string.gsub(str, ".", replace_char)
end

if args.summary or args.s then
	prompt = summaryPrompt()
else
	prompt = rofiInput({prompt = '  ', width = '70%'})
end

if prompt == '' then
	os.exit(1)
end
prompt = escapeForJson(prompt)
model = selectModel()
local answer = io.popen(generateCmd:format(host, model, prompt)):read '*a'
handleServiceError(answer)

print('----------------------------------------------\n')
print(answer)
print('----------------------------------------------\n')

local tmpFilePath = createTmpFile({prefix = 'ollama', format = 'adoc'})
writef(answer, tmpFilePath) 

os.execute(termRun:format('chat', 'nvim ' .. tmpFilePath))
-- # zenity --info --text="$ANSWER"
-- # wezterm start --class read -- nvim  $FILE
