#!/bin/luajit
-- optimalization 
-- kindle - I execute 2 times, maybe I don't need title of the article, I can useos.tmpfile - but it remove file after end of the script

HELP = [[
Utils for using URLs from the system clipboard.
link.lua action [number|url] 
List of the actions:
		menu - show rofi with available actions
		audio - downlad audio via youtube-dl 
		yt - downlad video via youtube-dl 
		tor - create torrent file form a magnetlink
		kindle - downlad video via gallery-dl 
		read - convert website to asciidoc and show it in 'reader view' mode
		speed - convert website to text for rsvp
		wget - downlad file via wget
		video - play video in video player (mpv)
		gallery - downlad images via gallery-dl 

List of the options:
		number - number of line from clipboard-default is 1
		input - show form input for the number
		url - link of the website
		-h help - show help

dependencies: mpv, youtube-dl or yt-dlp, gallery-dl, clipster, rdrview, mailx, speedread, pandoc
]]

YT_DIR = '~/Videos/YouTube/'
WGET_DIR = '~/Downloads/wget' -- can't have spaces
AUDIO_DIR = '~/Musics/PODCASTS/' 
GALLERY_DIR = '~/Pictures/gallery-dl/'
KINDLE_TMP_DIR = '/tmp/kindle/'
LINK_REGEX = "^https?://(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w%w%w?%w?)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))"
TOR_REGEX = "xt=urn:btih:([^&/]+)"

local action = arg[1]
local urlArg = arg[2] and arg[2] or 1

function execXargs(args, cmd)
	args = table.concat(args, '\n')
	local status = os.execute('echo "' .. args .. '" ' .. cmd)
	assert(status == 0, "Could not execute command")
	return "Executed"
end

function createTorrent(magnetlinks)
	local torDir = os.getenv('TOR_WATCH')
	os.execute('mkdir -p ' .. torDir)
	for i, magnetlink in ipairs(magnetlinks) do
		local hash = magnetlink:match(TOR_REGEX)
		local file = io.open(torDir .. '/meta-' .. hash.. '.torrent', 'w')
		file:write('d10:magnet-uri' .. #magnetlink .. ':' .. magnetlink .. 'e')
		file:close()
	end
	return '⬇️ Start downloading torrent'
end


function createEpub(link)
	local readerCmd =  'rdrview -A "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" "' .. link .. '" '
	
	local title = io.popen(readerCmd .. ' -M | head -1 | cut -d ":" -f 2'):read('*a'):gsub("\n", ""):gsub('/', ''):gsub('\"',''):gsub('^%s', '')
	if #title == 0 then 
		title = 'untitled-' .. os.date('%Y-%m-%dT%H:%M:%S')
	end 
	-- pandoc has error when converting to pdf, html need to have <html> <body> tags and has problem with encoding
	-- metadata title is required by the kindle server. excerpt can be add
	local date = os.date('%Y-%m-%d')
	local epubExe = run(readerCmd .. ' -H -T url,sitename,byline | pandoc --from html --to epub --output "' .. KINDLE_TMP_DIR .. title .. '.epub" --toc --metadata title="' .. title .. '" --metadata date='..date)
	return epubExe, title
end

function createEbook(linkTab)
	local articlesWithErrors = {}
	os.execute('mkdir -p ' .. KINDLE_TMP_DIR)

	for i, link in ipairs(linkTab) do
		local epubExe = createEpub(link)
		if not epubExe then
			table.insert(articlesWithErrors, link)
		end
	end
	assert(#articlesWithErrors == 0, 'Could not create ' .. #articlesWithErrors .. ' articles\n' .. table.concat(articlesWithErrors, '\n'))
	return 'Created ' .. #linkTab .. ' articles'
end

function sendToKindle(linkTab)
	local kindleEmail = io.input(os.getenv('PRIVATE') .. '/kindle_email'):read('*l'):gsub('%s', '')
	local articlesWithErrors = {}
	os.execute('mkdir -p ' .. KINDLE_TMP_DIR)

	for i, link in ipairs(linkTab) do
		local epubExe, title = createEpub(link)
		local sendFile = run('echo "' .. title .. '\nKindle article from reader" | mailx -v -s "Convert" -a"' .. KINDLE_TMP_DIR .. title .. '.epub" ' .. kindleEmail)
		if not epubExe or not sendFile then
			table.insert(articlesWithErrors, link)
		end
	end
	assert(#articlesWithErrors == 0, 'Could not send ' .. #articlesWithErrors .. ' articles\n' .. table.concat(articlesWithErrors, '\n'))
	return 'Sent ' .. #linkTab .. ' articles'
end

function readable(linkTab)
	local tmpname = os.tmpname()
	for i, link in ipairs(linkTab) do
		local createFile = os.execute('rdrview -H -A "Mozilla" "' .. link .. '" -T title | pandoc --from html --to asciidoc --output ' .. tmpname .. '.adoc')
		os.execute('st -c read -n read -e nvim ' .. tmpname .. '.adoc')
		assert(createFile == 0, 'Could not create file')
	end
	return 'Created file ' .. tmpname
end 

function speed(linkTab)
	local tmpname = os.tmpname()
	for i, link in ipairs(linkTab) do
		local createFile = os.execute('rdrview -H -A "Mozilla" "' .. link .. '" -T title | pandoc --from html --to plain --output ' .. tmpname)
		os.execute('wezterm --config font_size=19.0 start --class rsvp -- sh -c "cat ' .. tmpname .. ' | speedread -w 330"') 
		-- os.execute('st -c rsvp -n rsvp -e sh -c "cat ' .. tmpname .. ' | speedread -w 330"') 
		assert(createFile == 0, 'Could not create file')
	end
	return 'RSVP finished ' .. tmpname
end 

function wget(linkTab)
	os.execute('mkdir -p ' .. WGET_DIR)
	local cmd =	 "| xargs -P 0 -I {} wget -P " .. WGET_DIR .. " {}"
 -- -U "Mozilla"
	return execXargs, cmd
end

function audio()
	os.execute('mkdir -p ' .. AUDIO_DIR)
	local cmd = "| xargs -P 0 -I {} yt-dlp --embed-metadata -f bestaudio -x --audio-format mp3 -o '".. AUDIO_DIR .. "%(title)s.%(ext)s' {}"
	return execXargs, cmd
end

function yt()
	os.execute('mkdir -p ' .. YT_DIR)
	local cmd = "| xargs -P 0 -I {} yt-dlp --embed-metadata -o '".. YT_DIR .. "%(title)s.%(ext)s' {}"
	-- local cmd = "| xargs -P 0 -I {} yt-dlp --embed-metadata --restrict-filenames -o '".. YT_DIR .. "%(title)s.%(ext)s' {}"
	return execXargs, cmd
end

function gallery()
	os.execute('mkdir -p ' .. GALLERY_DIR)
	local cmd =	 "| xargs -P 0 -I {} gallery-dl -d '" .. GALLERY_DIR .. "' {}"
	return execXargs, cmd
end

local options = {
	["audio"]= audio,
	["yt"]= yt,
	["tor"]= function() return createTorrent end,
	["kindle-send"]= function() return sendToKindle end,
	["kindle"]= function() return createEbook end,
	["read"]= function() return readable end,
	["speed"]= function() return speed end,
	["wget"]= wget,
	["video"]= function() return execXargs, "| xargs -P 0 -I {} mpv {}" end,
	["gallery"]= gallery,
	["-h"]= function() print(HELP); os.exit() end,
	["#default"]= audio
}
local switch = (function(name,args)
	local sw = options
	return (sw[name]and{sw[name]}or{sw["#default"]})[1](args)
end)
if action == 'menu' then
	action = rofiMenu(options)
end

function filtrLinks(clipboardStream, regex)
	local links = {}
	for line in clipboardStream:lines() do
		local match = line:match(regex)
		if match then table.insert(links, line) end
	end
	if #links  == 0 then notifyError('No link provided') end
	return links
end

linkTab = {}
if urlArg == 'input' then
	urlArg = rofiInput({prompt = 'No. urls'})	
end
if action == '-h' or action == 'help' then 
	action = '-h'
elseif tonumber(urlArg) then
	local clipboard = io.popen("clipster --output --clipboard -n " .. urlArg )
	local regex = action == 'tor' and TOR_REGEX or LINK_REGEX
	linkTab = filtrLinks(clipboard, regex)
else
	table.insert(linkTab, urlArg) 
end

local exec, cmd = switch(action)
local status, val = pcall(exec, linkTab, cmd)
if status then
	notify(val)
else
	log(val, 'ERROR')
	notifyError(val)
end
