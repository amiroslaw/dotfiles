#!/bin/luajit
-- todo: rofi with list of actions
-- optimalization 
-- kindle - I execute 2 times, maybe I don't need title of the article, I can useos.tmpfile - but it remove file after end of the script
HELP = [[
Utils for using URLs from the system clipboard.
link.lua action [number|url] 
List of the actions:
		audio - downlad audio via youtube-dl 
		yt - downlad video via youtube-dl 
		tor - create torrent file form a magnetlink
		kindle - downlad video via gallery-dl 
		read - convert website to asciidoc and show it in 'reader view' mode
		wget - downlad file via wget
		video - play video in video player (mpv)
		gallery - downlad images via gallery-dl 

List of the options:
		number - number of line from clipboard-default is 1
		url - link of the website
		-h help - show help

dependencies: mpv, youtube-dl, gallery-dl, clipster, readability-cli (node 12), mailx
]]

YT_DIR = '~/Videos/YouTube/'
WGET_DIR = '~/Downloads/wget' -- can't have spaces
AUDIO_DIR = '~/Musics/PODCASTS/' 
GALLERY_DIR = '~/Pictures/gallery-dl/'
LINK_REGEX = "^https?://(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w%w%w?%w?)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))"
TOR_REGEX = "xt=urn:btih:([^&/]+)"
action = arg[1]
urlArg = arg[2] and arg[2] or 1

function notify(msg)
	print(msg)
	os.execute("dunstify '" .. msg .. "'")
end 

function errorHandling(msg)
	notify(msg)
	error(msg)
end

function execXargs(args, cmd)
	args = table.concat(args, '\n')
	local status = os.execute('echo "' .. args .. '" ' .. cmd)
	if status == 0 then
		return "Executed"
	else
		error("Could not execute command")
	end
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

-- require node 12
function sendToKindle(linkTab)
	local tmpDir = '/tmp/kindle/'
	local kindleEmail = io.input(os.getenv('PRIVATE') .. '/kindle_email'):read('*a'):gsub('%s', '')
	local articlesWithErrors = {}
	os.execute('mkdir -p ' .. tmpDir)

	for i, link in ipairs(linkTab) do
		local title = io.popen('readable -q true -p title ' .. link):read('*a'):gsub('%s', '-')
		if #title == 0 then error("Can not get title form readable") end
		local createFile, ss = os.execute('readable -q true "' .. link .. '" -p html-title,length,html-content | pandoc --from html --to docx --output ' .. tmpDir .. title .. '.docx')
		local sendFile = os.execute('echo "' .. title .. '\nKindle article from readability-cli" | mailx -v -s "Kindle" -a' .. tmpDir .. title .. '.docx ' .. kindleEmail)

		if createFile ~= 0 or sendFile ~= 0 then -- readability-cli return 0 in error 
			table.insert(articlesWithErrors, link)
		end
	end
	if #articlesWithErrors > 0 then
		error('Could not send ' .. table.concat(articlesWithErrors, '\n'))
	end
	return 'Sent ' .. #linkTab .. ' articles'
end

function readable(linkTab)
	local tmpname = os.tmpname()
	for i, link in ipairs(linkTab) do
		local createFile = os.execute('readable -q true "' .. link .. '" -p html-title,length,html-content | pandoc --from html --to asciidoc --output ' .. tmpname .. '.adoc')
		os.execute('st -t read -e nvim ' .. tmpname .. '.adoc') -- can read form evns
		if createFile ~= 0 then 
			error('Could not create file')
		end
	end
	return 'Created file ' .. tmpname
end 

function wget(linkTab)
	os.execute('mkdir -p ' .. WGET_DIR)
	local cmd =	 "| xargs -P 0 -I {} wget -P " .. WGET_DIR .. " {}"
	return execXargs, cmd
end

function audio()
	os.execute('mkdir -p ' .. AUDIO_DIR)
	local cmd = "| xargs -P 0 -I {} youtube-dl -f bestaudio -x --audio-format mp3 -o '".. AUDIO_DIR .. "%(title)s.%(ext)s' {}"
	return execXargs, cmd
end

function yt()
	os.execute('mkdir -p ' .. YT_DIR)
	local cmd = "| xargs -P 0 -I {} youtube-dl -o '".. YT_DIR .. "%(title)s.%(ext)s' {}"
	return execXargs, cmd
end

function gallery()
	os.execute('mkdir -p ' .. GALLERY_DIR)
	local cmd =	 "| xargs -P 0 -I {} gallery-dl -d '" .. GALLERY_DIR .. "' {}"
	return execXargs, cmd
end

local switch = (function(name,args)
	local sw = {
		["audio"]= audio,
		["yt"]= yt,
		["tor"]= function() return createTorrent end,
		["kindle"]= function() return sendToKindle end,
		["read"]= function() return readable end,
		["wget"]= wget,
		["video"]= function() return execXargs, "| xargs -P 0 -I {} mpv {}" end,
		["gallery"]= gallery,
		["-h"]= function() print(HELP); os.exit() end,
		["#default"]= audio
	}
	return (sw[name]and{sw[name]}or{sw["#default"]})[1](args)
end)

function filtrLinks(clipboardStream, regex)
	local links = {}
	for line in clipboardStream:lines() do
		local match = line:match(regex)
		if match then table.insert(links, line) end
	end
	if #links  == 0 then errorHandling('No link provided') end
	return links
end

linkTab = {}
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
notify(val)
