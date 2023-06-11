#!/usr/bin/luajit
local gumbo = require 'gumbo'

local CONST = enum({
	selectedTxt = os.getenv 'QUTE_SELECTED_TEXT',
	selectedHtml = os.getenv 'QUTE_SELECTED_HTML',
	quteFifo = os.getenv 'QUTE_FIFO',
	quteUrl = os.getenv 'QUTE_URL',
	readerTmp = '/tmp/qb-reader.txt',
	clipFile = '/tmp/qb-clipboard',
	clipFileHtml = '/tmp/qb-clip.html',
	argFile = '/tmp/qb-arg',
	argEngineSeparator = ':',
	defaultSearchEngine = ' ',
})

function getHtmlElement()
	local document = gumbo.parse(CONST.selectedHtml)
	local gumboElement = document:getElementsByTagName '*'
	return gumboElement[1]
end

local function copy(txt)
	local txt = txt and txt or CONST.selectedTxt
	assert(writef(txt, CONST.clipFile), 'Did not copy to clipboard - IO error')
	assert(os.execute('xclip -sel clip -i ' .. CONST.clipFile) == 0, 'Did not copy to clipboard -xclip')
end

local function splitSentences()
	local sentences = {}
	-- regex = '[^%.!?]+[!?%.]%s*'
	-- regex = '.-[!?:%.]'
	-- regex = '.-[!?:%.]%s'
	local regex = '.-[%.:!?]%f[%z%s]'
	for match in CONST.selectedTxt:gmatch(regex) do
		local sentence = trim(match):gsub('\n', ' ')
		table.insert(sentences, sentence)
	end
	local rofiOutput = rofiMenu(sentences, {prompt = 'Select sentence', multi = true, width = '95%'} )
	if type(rofiOutput) == 'table' then
		rofiOutput = table.concat(rofiOutput, '\n')
	end
	copy(rofiOutput)
end

function adoc()
	local html = getHtmlElement().outerHTML
	assert(writef(html, CONST.clipFileHtml), 'adoc - IO error')
	local ok, out, err = run('pandoc --wrap=none --from html --to asciidoc --output ' .. CONST.clipFile .. ' ' .. CONST.clipFileHtml)
	
	if ok then
		assert(os.execute('xclip -sel clip -i ' .. CONST.clipFile) == 0, 'Did not copy to clipboard -xclip')
	else
		log(err, 'ERROR')
		writef('message-warning "Could not convert to adoc - copied plain text"', CONST.quteFifo, 'a')
		copy()
	end
end

function copyWithUrl()
	local document = gumbo.parse(CONST.selectedHtml)
	local urls = '' -- urls will have relative path
	for _, element in ipairs(document.links) do
		urls = urls .. '\n' .. element:getAttribute 'href'
	end
	copy(CONST.selectedTxt .. urls)
end

function copyAdocUrl()
	copy(CONST.quteUrl .. '[' .. trim(CONST.selectedTxt) .. ']')
end

function speed()
	assert(os.execute( 'wezterm --config font_size=19.0 start --class rsvp -- sh -c "echo ' .. CONST.selectedTxt .. ' | speedread -w 300"') == 0, 'Error in function speed()')
end

function read()
	assert(writef(CONST.selectedTxt, CONST.readerTmp), 'read() - IO error')
	os.execute('st -c read -n read -e nvim ' .. CONST.readerTmp)
end

function searchEngine(engine, txt)
	local txt = txt:gsub('\t', ' ')
	txt = txt:gsub('\n', ' ')
	txt = txt:gsub('/', '\\')

	local cmd = 'open -t ' .. engine .. ' ' .. txt
	writef(cmd, CONST.quteFifo, 'a')
end

function search(engine)
	engine = engine and engine or CONST.defaultSearchEngine
	searchEngine(engine, CONST.selectedTxt)
end

local cases = {
	['--adoc'] = adoc,
	['--adoc-url'] = copyAdocUrl,
	['--url'] = copyWithUrl,
	['--speed'] = speed,
	['--read'] = read,
	['--split'] = splitSentences,
	['--search'] = search,
	[false] = copy,
}

local arg = 'no argument'
local argFile = io.open(CONST.argFile, 'r+')
if argFile then
	arg = argFile:read '*all'
	argFile:seek 'set'
	argFile:write 'no argument'
	argFile:close()
end

-- argument `--search` can have value provided after colon - `--search:l`
local engine
if arg:match '--search' then
	engine = split(arg, CONST.argEngineSeparator)[2]
	arg = '--search'
end

local switchFun = switch(cases, arg)
local ok, error = pcall(switchFun, engine)
if ok and arg ~= '--search' then -- probably qb is too slow so it join info and cmd
	writef('message-info "Selected"', CONST.quteFifo, 'a')
end
if not ok then
	writef('message-error "' .. error .. '"', CONST.quteFifo, 'a')
end
