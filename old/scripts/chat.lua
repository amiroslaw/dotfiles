#!/bin/luajit
-- TODO 
-- add more resources - files  
-- add more methods:  corrections;  
local HELP = [[
--ask -a → provide prompt in rofi input
--text -t → ask about text provided from clipboard 
--summary -s → summary text from clipboard
--url -u → perform with text from a website instead of clipboard
--list -l → choose available model
--model -m → override default model

Examples:
chat.lua -a -l
chat.lua -s -u="https://en.wikipedia.org/"
]]

local function help() print(HELP); os.exit() end

local OLLAMA_API_HOST = os.getenv 'OLLAMA_API_HOST'
local termRun = os.getenv 'TERM_LT' .. os.getenv 'TERM_LT_RUN'
local host = OLLAMA_API_HOST and OLLAMA_API_HOST or 'http://localhost:11434'
local generateCmd = [[ 
curl --silent --no-buffer  %s/api/generate -d '{ "model": "%s", "prompt": "%s", "stream": false }' | jq -r '.response'
]]
local generateCmdEnc = [[ 
curl --silent --no-buffer  %s/api/generate --data-raw '{ "model": "%s", "prompt": "%s", "stream": false }' | jq -r '.response'
]]
local PROMPT = enum({ summary =  "Summarize (use asciidoc format with lists and bold text if needed) following text:\n", 
					copiedText = '. Answer to that question based to following text:\n' })

local args = cliparse(arg, 'txt')

local function handleServiceError(answer)
	if answer and answer == '' then
		notifyError('Failed to connect to ' .. host)
		os.exit(1)
	end
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

local function ask() return rofiInput({prompt = '  ', width = '70%'}) end

local function urlToTxt(url)
	local cmd = ('rdrview -H -A "Mozilla" "%s" -T title | pandoc --from html --to plain --output -'):format(url)
	return  io.popen(cmd):read '*a'
end

-- analys form prompt, webpage or clipboard
local function textAnalysis(prompt)
	if prompt == PROMPT.copiedText then prompt = ask() .. prompt end 
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

local cases = {
	['ask'] = ask, ['a'] = ask,
	['summary'] = M.bind(textAnalysis, PROMPT.summary), ['s'] = M.bind(textAnalysis, PROMPT.summary),
	['text'] = M.bind(textAnalysis, PROMPT.copiedText), ['t'] = M.bind(textAnalysis, PROMPT.copiedText),
	['help'] = help, ['h'] = help,
}

local action = ask
for key,_ in pairs(args) do
	local selection = switch(cases, key)
	if selection and args[key] then
		action = selection
	end
end
local ok, prompt = pcall(action)
print(prompt)

if not prompt or prompt == '' or not ok then
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
