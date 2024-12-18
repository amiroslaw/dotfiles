#!/bin/luajit
-- in some cases I have to use this $BROWSER  "google.com/search?q=$(xclip -o -sel primary | sed -e 's/ /+/g')"

HELP = [[
Utils for searching.
search.lua action [option | phrase]
	phrase - search phrase
	actions: plen|cenowarka|tor|so|filmweb|enpl|amazon|ceneo|diki|tuxi|brave|maps|translator|dd|deepl|wiki|yt|google|cheat
List of the options:
	--menu -m show rofi with available actions
	--clipboard -c → search from secondary clipboard 
	--primary -p → search from primary clipboard (selection)
	--input -i → show form input for the phrase
	-h help - show help

Examples:
Translate text to Polish
search.lua --enpl "cat"
Search from a selected text
search.lua --google -p
Multi search
search.lua --google --dd "search phrase"

-- dependency: rofi, xclip, translate shell, tuxi
]]

local args = cliparse(arg, 'phrase')
local phraseArg = 'empty'

if args.clipboard or args.c then
	phraseArg = io.popen('xclip -out -selection clipboard'):read('*a')
elseif args.primary or args.p then
	phraseArg = io.popen('xclip -out -selection primary'):read('*a')
elseif args.input or args.i then
	phraseArg =	rofiInput({prompt = 'Search'})	
elseif args.phrase then
	phraseArg = args.phrase[1]	
end

function cheat()
	return function(phraseArg)
	local topics = {
		lua = "lang",
		java = 'lang',
		js = 'lang',
		typescript = 'lang',
		kotlin = 'lang',
		python = 'lang',
		css = 'lang',
		html = 'lang',
		bash = 'lang',
		xargs = 'app',
		sed = 'app',
		awk = 'app',
		find = 'app',
		ls = 'app'
	}

	local topic, code = rofiMenu(topics, {prompt = 'cheatsh', width = '25ch'})
	if not code then return end
	local query = phraseArg:gsub('%s', '+')
	local status = false
	local err = 'Can not fetch data'
	local out
	local cmd = ('curl "cht.sh/%s%s%s?T"') -- ?T without ascii
	if topics[topic[1]] == 'lang' then
		if query == '' then query = ':list' elseif query == 'l' then query = ':learn' end -- :learn; def=:list
		out, status, err = run(cmd:format(topic[1], '/', query)) 
	else
		out, status, err = run(cmd:format(topic[1], '~', query)) 
	end
	assert(status, err)
	local tmpFile = createTmpFile({prefix = 'cheat'})
	writef(out,tmpFile)
	local termCmd = (os.getenv 'TERM_LT' .. os.getenv 'TERM_LT_RUN'):format('cheatsh', 'nvim ' .. tmpFile)
	os.execute(termCmd)
end
end

local function transShell(dictionary)
	local translation = io.popen('trans -b -sp ' .. dictionary .. ' "' .. phraseArg ..'"'):read('*a')
	if #translation == 0 then 
		error("Can not translate") 
	else
		notify(translation)
		-- TODO
		-- path = os.getenv('CONFIG') ..  '/logs/
		-- echo "$selection ; $pl" >> ~/.config/rofi/scripts/tran/enpl-dictionary.txt ]]
	end
end

local function tuxi() --show error but work fine
	local output = io.popen('tuxi -ra "' .. phraseArg ..'"'):read('*a')
	assert(#output ~= 0, "Can not search")

	local cmd = ([[sh -c 'echo "%s" | nvim -']]):format(output)
	os.execute((os.getenv 'TERM_LT' .. os.getenv 'TERM_LT_RUN'):format('read', cmd)) -- can take terminal form env and save file into tmp
end

local function browser(url)
	local status = os.execute('xdg-open "' .. url .. phraseArg .. '"')
	assert(status == 0, 'Could not browse: ' .. phraseArg)
end

local function help() print(HELP); os.exit() end

local options = {
	["h"]= help,
	["google"] = M.bind(browser, 'https://google.com/search?q='),
	["brave"] = M.bind(browser, 'https://search.brave.com/search?q='),
	["dd"] = M.bind(browser, 'https://duckduckgo.com/html?q='),
	["yt"] = M.bind(browser, 'https://www.youtube.com/results?search_query='),
	["maps"] = M.bind(browser, 'https://www.google.com/maps?q='),
	["wiki"] = M.bind(browser, 'https://en.wikipedia.org/wiki/'),
	["ceneo"] = M.bind(browser, 'https://www.ceneo.pl/szukaj-'),
	["cenowarka"] = M.bind(browser, 'https://cenowarka.pl/?fs='),
	["allegro"] = M.bind(browser, 'https://allegro.pl/listing?string='),
	["amazon"] = M.bind(browser, 'https://www.amazon.pl/s/?field-keywords='),
	["so"] = M.bind(browser, 'https://stackoverflow.com/search?q='),
	["filmweb"] = M.bind(browser, 'https://www.filmweb.pl/search?q='),
	["diki"] = M.bind(browser, 'https://www.diki.pl/slownik-angielskiego?q='),
	["deepl"] = M.bind(browser, 'https://www.deepl.com/translator#en/pl/'),
	["translator"] = M.bind(browser, 'https://translate.google.com/#auto/en/'),
	["plen"]= M.bind(transShell,'pl:en'),
	["enpl"]= M.bind(transShell,'en:pl'),
	["tor"]= function(phrase) return  os.execute('tor.sh "' .. phrase .. '"') end,
	["tuxi"]= function() return tuxi() end,
	["cheat"]= cheat(),
}

local function errorMsg(msg)
	print(msg)
	log(msg, 'ERROR')
	notifyError(msg)
end

if args.menu or args.m then
	local action = switch(options, rofiMenu(options, {prompt = 'Search', width = '25ch'})[1])
	xpcall(action, errorMsg, phraseArg)
end

for key,_ in pairs(args) do
	local selection = switch(options, key)
	if selection and args[key] then
		xpcall(selection, errorMsg, phraseArg)
	end
end

