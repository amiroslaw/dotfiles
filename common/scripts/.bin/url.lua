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
		wget - downlad file via wget
		video - play video in video player (mpv)
		gallery - downlad images via gallery-dl 

List of the options:
		number - number of line from clipboard-default is 1
		input - show form input for the number
		url - link of the website
		-h help - show help

dependencies: mpv, youtube-dl or yt-dlp, gallery-dl, clipster, readability-cli (node 12), mailx, speedread
]]

YT_DIR = '~/Videos/YouTube/'
WGET_DIR = '~/Downloads/wget' -- can't have spaces
AUDIO_DIR = '~/Musics/PODCASTS/' 
GALLERY_DIR = '~/Pictures/gallery-dl/'
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

-- require node 12
function sendToKindle(linkTab)
	local tmpDir = '/tmp/kindle/'
	local kindleEmail = io.input(os.getenv('PRIVATE') .. '/kindle_email'):read('*l'):gsub('%s', '')
	local articlesWithErrors = {}
	os.execute('mkdir -p ' .. tmpDir)

	for i, link in ipairs(linkTab) do
		local readableCmd =  'readable --user-agent="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" "' .. link .. '" '
		
		local title = io.popen(readableCmd .. ' -p title'):read('*a'):gsub("\n", ""):gsub('/', '')
		if #title == 0 then 
			title = 'untitled-' .. os.date('%Y-%m-%dT%H:%M:%S')
		end 
		-- converting to pdf has error in pandoc, html need to have <html> <body> tags and has problem with encoding
		-- epub has nice metadata options but I don't know how to create few of them.
		local date = os.date('%Y-%m-%d')
		local htmlExe = run(readableCmd .. ' -p length,html-content -o "' .. tmpDir .. title .. '"')
		local epubExe = run('pandoc --from html --to epub --output "' .. tmpDir .. title .. '.epub" --toc --metadata rights=' .. link .. ' --metadata date='..date..' --metadata title="'.. title .. '" "' .. tmpDir .. title .. '"')
		local sendFile = run('echo "' .. title .. '\nKindle article from readability-cli" | mailx -v -s "Convert" -a"' .. tmpDir .. title .. '.epub" ' .. kindleEmail)
		if not epubExe or not htmlExe or not sendFile then
			table.insert(articlesWithErrors, link)
		end
	end
	assert(#articlesWithErrors == 0, 'Could not send ' .. #articlesWithErrors .. ' articles\n' .. table.concat(articlesWithErrors, '\n'))
	return 'Sent ' .. #linkTab .. ' articles'
		-- local epubExe = run('pandoc --from html --to docx --output "' .. tmpDir .. title .. '.doxc" "' .. tmpDir .. title .. '"') -- docx
		-- local title = os.time() - special chars in filename
		-- local epubExe = run('pandoc --from html --to epub --output "' .. tmpDir .. title .. '.epub" --toc --metadata rights=' .. link .. ' --metadata date='..date..' --metadata title="'.. title .. '" "' .. tmpDir .. title .. '"')
			-- creating docx
			-- local createFile = os.execute('readable -A "Mozilla" -q true "' .. link .. '" -p html-title,length,html-content | pandoc --from html --to docx --output ' .. tmpDir .. titleUrl .. '.docx')
			-- local sendFile = os.execute('echo "' .. titleUrl .. '\nKindle article from readability-cli" | mailx -v -s "Convert" -a' .. tmpDir .. titleUrl .. '.docx ' .. kindleEmail)
		-- local titleUrl = title:gsub('[^a-zA-Z0-9-_]', '-')
			--[[ 
			append link to the article - I have to do it before pandoc
			doc = io.open(tmpDir .. title, "a+")
			doc:write(link)
			doc:close() ]]
		-- else
			-- table.insert(articlesWithErrors, link)
		-- end
end

function readable(linkTab)
	local tmpname = os.tmpname()
	for i, link in ipairs(linkTab) do
		local createFile = os.execute('readable -A "Mozilla" -q true "' .. link .. '" -p html-title,length,html-content | pandoc --from html --to asciidoc --output ' .. tmpname .. '.adoc')
		os.execute('st -c read -n read -e nvim ' .. tmpname .. '.adoc') -- can read form evns
		assert(createFile == 0, 'Could not create file')
	end
	return 'Created file ' .. tmpname
end 

function speed(linkTab)
	local tmpname = os.tmpname()
	for i, link in ipairs(linkTab) do
		local createFile = os.execute('readable -A "Mozilla" -q true "' .. link .. '" -p html-title,length,html-content | pandoc --from html --to plain --output ' .. tmpname)
		-- os.execute('st -c rsvp -n rsvp -e sh -c "cat ' .. tmpname .. ' | speedread -w 330"') 
		os.execute('wezterm --config font_size=19.0 start --class rsvp -- sh -c "cat ' .. tmpname .. ' | speedread -w 330"') 
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
	local cmd = "| xargs -P 0 -I {} yt-dlp -f bestaudio -x --audio-format mp3 -o '".. AUDIO_DIR .. "%(title)s.%(ext)s' {}"
	return execXargs, cmd
end

function yt()
	os.execute('mkdir -p ' .. YT_DIR)
	local cmd = "| xargs -P 0 -I {} yt-dlp -o '".. YT_DIR .. "%(title)s.%(ext)s' {}"
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
	["kindle"]= function() return sendToKindle end,
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
	urlArg = rofiInput('No. urls')	
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
