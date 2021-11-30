#!/bin/luajit
-- in some cases I have to use this $BROWSER  "google.com/search?q=$(xclip -o -sel primary | sed -e 's/ /+/g')"
package.path = '/home/miro/Documents/dotfiles/common/scripts/.bin/' .. package.path
util = require('scriptsUtil')

HELP = [[
Utils for searching.
search.lua action [clipboard | phrase | input]
List of the options:

	actions: plen|cenowarka|tor|so|filmweb|enpl|amazon|ceneo|diki|tuxi|brave|maps|translator|dd|deepl|wiki|yt|google|cheat
	menu - show rofi with available actions
	clipboard - type of the clipboard: clip or primary (default)
	phrase - search phrase
	input - show form input for the phrase
	-h help - show help

-- dependency: rofi, xclip, translate shell, tuxi
]]

action = arg[1]

phraseArg = arg[2] and arg[2] or 'primary'

if not phraseArg or phraseArg == 'input' then
	phraseArg =	util.input('Search')	
end 
if phraseArg == 'primary' or phraseArg == 'clip' then
	phraseArg = io.popen('xclip -out -selection ' .. phraseArg):read('*a')
end

function cheat()
	local topics = {
		lua = "lang",
		java = 'lang',
		js = 'lang',
		typescript = 'lang',
		kotlin = 'lang',
		css = 'lang',
		html = 'lang',
		bash = 'lang',
		xargs = 'app',
		sed = 'app',
		awk = 'app',
		find = 'app',
		ls = 'app'
	}

	local tmpname = os.tmpname()
	local topic = util.menu(topics)
	local query = phraseArg:gsub('%s', '+')
	local status = 1
	if topics[topic] == 'lang' then
		if query == '' then query = ':list' elseif query == 'l' then query = ':learn' end -- :learn; def=:list
		status = os.execute('curl cht.sh/' .. topic .. '/' .. query .. ' > ' .. tmpname)
	else
		status = os.execute('curl cht.sh/' .. topic .. '~' .. query .. ' > ' .. tmpname)
	end
	assert(status == 0, 'Can not fetch data')
	-- terminal = os.getenv('TERM') - won't have class or title name option
	-- ?T without ascii
	-- os.execute("alacritty --class cheatsh -t cheatsh -e less -R " .. tmpname)
	os.execute("wezterm start --class cheatsh -- less -R " .. tmpname)
end

function browser(url)
	local status = os.execute('xdg-open ' .. url)
	assert(status, 'Could not browse')
end

function transShell(dictionary)
	local translation = io.popen('trans -b -sp ' .. dictionary .. ' "' .. phraseArg ..'"'):read('*a')
	if #translation == 0 then 
		error("Can not translate") 
	else
		util.notify(translation)
		-- todo
		-- path = os.getenv('CONFIG') ..  '/logs/
		-- echo "$selection ; $pl" >> ~/.config/rofi/scripts/tran/enpl-dictionary.txt ]]
	end
end

function tuxi() --show error but work fine
	local output = io.popen('tuxi -ra "' .. phraseArg ..'"'):read('*a')
	assert(#output ~= 0, "Can not search")
	os.execute("st -t read -n read -e sh -c 'echo \"" .. output .. "\" | nvim -'") -- can take terminal form env and save file into tmp
end

local options = {
	["google"] = function(phrase) return browser, 'https://google.com/search?q="' .. phrase .. '"' end,
	["brave"] = function(phrase) return browser, 'https://search.brave.com/search?q="' .. phrase .. '"' end,
	["dd"] = function(phrase) return browser, 'https://duckduckgo.com/html?q="' .. phrase .. '"' end,
	["yt"] = function(phrase) return browser, 'https://www.youtube.com/results?search_query="' .. phrase .. '"' end,
	["maps"] = function(phrase) return browser, 'https://www.google.com/maps?q="' .. phrase .. '"' end,
	["wiki"] = function(phrase) return browser, 'https://en.wikipedia.org/wiki/"' .. phrase .. '"' end,
	["ceneo"] = function(phrase) return browser, 'https://www.ceneo.pl/szukaj-"' .. phrase .. '"' end,
	["cenowarka"] = function(phrase) return browser, 'https://cenowarka.pl/?fs="' .. phrase .. '"' end,
	["allegro"] = function(phrase) return browser, 'https://allegro.pl/listing?string="' .. phrase .. '"' end,
	["amazon"] = function(phrase) return browser, 'https://www.amazon.pl/s/?field-keywords="' .. phrase .. '"' end,
	["so"] = function(phrase) return browser, 'https://stackoverflow.com/search?q="' .. phrase .. '"' end,
	["filmweb"] = function(phrase) return browser, 'https://www.filmweb.pl/search?q="' .. phrase .. '"' end,
	["diki"] = function(phrase) return browser, 'https://www.diki.pl/slownik-angielskiego?q="' .. phrase .. '"' end,
	["deepl"] = function(phrase) return browser, 'https://www.deepl.com/translator#en/pl/"' .. phrase .. '"' end,
	["translator"] = function(phrase) return browser, 'https://translate.google.com/#auto/en/"' .. phrase .. '"' end,
	["plen"]= function(phrase) return transShell, 'pl:en' end,
	["enpl"]= function(phrase) return transShell, 'en:pl' end,
	["tuxi"]= function(phrase) return tuxi  end,
	["cheat"]= function(phrase) return cheat end,
	["tor"]= function(phrase) return  os.execute('tor.sh ' .. phrase) end,
	["-h"]= function() print(HELP); os.exit() end,
	["#default"] = function(phrase) return browser, 'http://google.com/search?q="' .. phrase .. '"' end
}
local switch = (function(name,args)
	local sw = options	
	return (sw[name]and{sw[name]}or{sw["#default"]})[1](args)
end)

if action == 'menu' then
	action = util.menu(options)
end

local exec, param = switch(action, phraseArg)
local ok, val = pcall(exec, param)

if not ok then 
	util.errorHandling(val)
end
