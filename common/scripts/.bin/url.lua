#!/bin/luajit

HELP = [[
Utils for URLs.
url.lua actions [options] url|clipItems
List of the actions:
		--menu -m show rofi with available actions
		--audio -a downlad audio via youtube-dl 
		--video -v downlad video via youtube-dl 
		--tor -t create torrent file form a magnetlink
		--kindle -k downlad video via gallery-dl 
		--read -r convert website to asciidoc and show it in 'reader view' mode
		--speed -s convert website to text for rsvp
		--wget -w downlad file via wget
		--gallery -g downlad images via gallery-dl 
		--help -h - show help

List of the options:
		--number -n number of line from clipboard. In default it will grab one item from CLIPBOARD clipboard
		--primary -p → takes url from the PRIMARY clipboard, instead of the CLIPBOARD clipboard
		--input -i show form input for the number
		--email -e → option for kinde, ebook will be send to a kindle device via email. You need to setup mailx and create $PRIVATE/kindle_email file with an email address
		url - link of a website

Examples:
Convert a website to asciidoc and show it a terminal.
url.lua --read url
Search urls from 4 last PRIMARY clipboard items, and download them
url.lua --wget --primary --number 4
Prompt clipboard item numbers. Search urls from clipboard, and download videos
url.lua --video --input 
Convert a website to epub and send it via email
url.lua --kindle --email url
Choose action from menu, and pass url from PRIMARY clipboard
url.lua --menu --primary

dependencies:  clipster, yt-dlp, gallery-dl, rdrview, mailx, speedread, pandoc
]]

YT_DIR = '~/Videos/YouTube/'
WGET_DIR = '~/Downloads/wget' -- can't have spaces
AUDIO_DIR = '~/Musics/PODCASTS/' 
GALLERY_DIR = '~/Pictures/gallery-dl/'
KINDLE_TMP_DIR = '/tmp/kindle/'
LINK_REGEX = "^https?://(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w%w%w?%w?)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))"
TOR_REGEX = "xt=urn:btih:([^&/]+)"

local function help() print(HELP); os.exit() end

local args = cliparse(arg, 'url')
local linkTab = args.url

local function createTorrent()
	local torDir = os.getenv('TOR_WATCH')
	os.execute('mkdir -p ' .. torDir)
	for _, magnetlink in ipairs(linkTab) do
		local hash = magnetlink:match(TOR_REGEX)
		local file = io.open(torDir .. '/meta-' .. hash.. '.torrent', 'w')
		file:write('d10:magnet-uri' .. #magnetlink .. ':' .. magnetlink .. 'e')
		file:close()
	end
	return '⬇️ Start downloading torrent'
end

local function createEpub(link)
	local readerCmd =  'rdrview -A "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" "' .. link .. '" '
	
	local title = io.popen(readerCmd .. ' -M | head -1 | cut -d ":" -f 2'):read('*a'):gsub("\n", ""):gsub('/', ''):gsub('\"',''):gsub('^%s', '')
	if #title == 0 then 
		title = 'untitled-' .. os.date('%Y-%m-%dT%H:%M:%S')
	end 
	-- pandoc has error when converting to pdf, html need to have <html> <body> tags and has problem with encoding
	-- metadata title is required by the kindle server. excerpt can be add
	local date = os.date('%Y-%m-%d')
	local epubExe = run(readerCmd .. ' -H -T url,sitename,byline | pandoc --from html --to epub --output "' .. KINDLE_TMP_DIR .. title .. '.epub" --toc --metadata title="' .. title .. '" --metadata date='..date, "Can't create ebook: " .. title)
	return epubExe, title
end

local function kindle()
	local msg = 'Created '
	local kindleEmail = io.input(os.getenv('PRIVATE') .. '/kindle_email'):read('*l'):gsub('%s', '')
	local articlesWithErrors = {}
	os.execute('mkdir -p ' .. KINDLE_TMP_DIR)
	for _, link in ipairs(linkTab) do
		local epubExe, title = createEpub(link)
		local sendFile = true
		-- sometimes can't send
		if args.email or args.e then
			msg = 'Sent '
			sendFile = run('echo "' .. title .. '\nKindle article from reader" | mailx -v -s "Convert" -a"' .. KINDLE_TMP_DIR .. title .. '.epub" ' .. kindleEmail, "Can't send book: " .. title)
		end

		if not epubExe or not sendFile then
			table.insert(articlesWithErrors, link)
		end
	end

	assert(#articlesWithErrors == 0, 'Could not send ' .. #articlesWithErrors .. ' articles\n' .. table.concat(articlesWithErrors, '\n'))
	return msg .. #linkTab .. ' articles'
end

local function readable()
	local tmpPath, tmpName = createTmpFile({prefix = 'readable', format = 'adoc'})
	for _, link in ipairs(linkTab) do
		local createFile = os.execute('rdrview -H -A "Mozilla" "' .. link .. '" -T title | pandoc --from html --to asciidoc --output ' .. tmpPath)
		-- os.execute('st -c read -n read -e nvim ' .. tmpPath)
		os.execute('wezterm start --class read -- nvim ' .. tmpPath)
		assert(createFile == 0, 'Could not create file')
	end
	return 'Created file ' .. tmpName
end 

local function speed()
	local tmpPath, tmpName = createTmpFile({prefix = 'rsvp'})
	for _, link in ipairs(linkTab) do
		local createFile = os.execute('rdrview -H -A "Mozilla" "' .. link .. '" -T title | pandoc --from html --to plain --output ' .. tmpPath)
		os.execute('wezterm --config font_size=19.0 start --class rsvp -- sh -c "cat ' .. tmpPath .. ' | speedread -w 330"') 
		-- os.execute('st -c rsvp -n rsvp -e sh -c "cat ' .. tmpPath .. ' | speedread -w 330"') 
		assert(createFile == 0, 'Could not create file')
	end
	return 'RSVP finished ' .. tmpName
end 

local function execXargs(cmd, outputDir)
	if outputDir then
		os.execute('mkdir -p ' .. outputDir)
	end
	local args = table.concat(linkTab, '\n')
	local status = os.execute('echo "' .. args .. '" ' .. cmd)
	assert(status == 0, "Could not execute command")
	return "Executed"
end

local function wget()
	local cmd =	 "| xargs -P 0 -I {} wget -P " .. WGET_DIR .. " {}"
 -- -U "Mozilla"
	return execXargs(cmd, WGET_DIR)
end

function audio()
	local cmd = "| xargs -P 0 -I {} yt-dlp --embed-metadata -f bestaudio -x --audio-format mp3 -o '".. AUDIO_DIR .. "%(title)s.%(ext)s' {}"
	return execXargs(cmd, AUDIO_DIR)
end

function video()
	local cmd = "| xargs -P 0 -I {} yt-dlp --embed-metadata -o '".. YT_DIR .. "%(title)s.%(ext)s' {}"
	-- local cmd = "| xargs -P 0 -I {} yt-dlp -o '".. YT_DIR .. "%(title)s.%(ext)s' {}"
	-- local cmd = "| xargs -P 0 -I {} yt-dlp --embed-metadata --restrict-filenames -o '".. YT_DIR .. "%(title)s.%(ext)s' {}"
	return execXargs(cmd, YT_DIR)
end

function gallery()
	local cmd =	 "| xargs -P 0 -I {} gallery-dl -d '" .. GALLERY_DIR .. "' {}"
	return execXargs(cmd, GALLERY_DIR)
end

local options = {
	["audio"]= audio,
	["a"]= audio,
	["video"]= video,
	["v"]= video,
	["tor"]= createTorrent,
	["t"]= createTorrent,
	["kindle"]= kindle,
	["k"]= kindle,
	["read"]= readable,
	["r"]= readable,
	["speed"]= speed,
	["s"]= speed,
	["wget"]= wget,
	["w"]= wget,
	["gallery"]= gallery,
	["g"]= gallery,
	["h"]= help,
	["help"]= help,
}

local function filterLinks(clipboardStream)
	local links = {}
	local regex = LINK_REGEX
	if args.tor or args.t then
		regex = TOR_REGEX
	end

	for line in clipboardStream:lines() do
		local match = line:match(regex)
		if match then table.insert(links, line) end
	end
	if #links  == 0 then notifyError('No link provided') end
	return links
end

local action = help

if args.menu or args.m then
	local selection = rofiMenu(options)
	action = switch(options, selection)
else
	for key,_ in pairs(args) do
		local selection = switch(options, key)
		if selection and args[key] then
			action = selection
		end
	end
end

if args.input or args.i then
	args.number = {}
	args.number[1] = rofiInput({prompt = 'No. urls'})	
end
local argNumber = args.number or args.n
if argNumber then
	local number = 1
	if argNumber[1] then -- get form param value or rofiInput
		number = argNumber[1]
	end
	if args.url then -- get from the option
		number = args.url[1]
	end
	local clip = ' --clipboard '
	if args.primary or args.p then
		clip = ' --primary '
	end
	local clipboard = io.popen("clipster --output ".. clip .." -n " .. number)
	linkTab = filterLinks(clipboard)
end

local status, val = pcall(action)
if status then
	notify(val)
else
	log(val, 'ERROR')
	notifyError(val)
end
