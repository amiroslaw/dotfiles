#!/bin/luajit

HELP = [[
Utils for URLs.
url.lua actions [options] url|clipItems
List of the actions:
		--menu -m show rofi with available actions
		--dlAudio -a downlad audio via youtube-dl 
		--dlVideo -v downlad video via youtube-dl 
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
url.lua --dlVideo --input 
Convert a website to epub and send it via email
url.lua --kindle --email url
Choose action from menu, and pass url from PRIMARY clipboard
url.lua --menu --primary

dependencies:  clipster, yt-dlp, gallery-dl, rdrview, mailx, speedread, pandoc, pueue
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


local function exec(cmd, url)
	if M.isArray(url) then
		assert(os.execute(cmd .. url) == 0, 'Can not run: ' .. cmd)
	end
	local url, title = next(url)
	print(url, title)
	print(cmd:format(title) .. url)
	assert(os.execute(cmd:format(title) .. url) == 0, 'Can not run: ' .. cmd)
end

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
	local args = cliparse(arg, 'url')
	local link = args.url[1] and args.url[1] or link

	local readerCmd =  'rdrview -A "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" "' .. link .. '" '
	
	local title = io.popen(readerCmd .. ' -M | head -1 | cut -d ":" -f 2'):read('*a'):gsub("\n", ""):gsub('/', ''):gsub('\"',''):gsub('^%s', '')
	if #title == 0 then 
		title = 'untitled-' .. os.date('%Y-%m-%dT%H:%M:%S')
	end 
	-- pandoc has error when converting to pdf, html need to have <html> <body> tags and has problem with encoding
	-- metadata title is required by the kindle server. excerpt can be add
	local date = os.date('%Y-%m-%d')
	os.execute('mkdir -p ' .. KINDLE_TMP_DIR)
	local ok = os.execute(readerCmd .. ' -H -T url,sitename,byline | pandoc --from html --to epub --output "' .. KINDLE_TMP_DIR .. title .. '.epub" --toc --metadata title="' .. title .. '" --metadata date='..date)
	assert(ok == 0, "Can't create ebook: " .. title)
	return title
end

local function sendKindle()
	local link = args[1]
	local kindleEmail = io.input(os.getenv('PRIVATE') .. '/kindle_email'):read('*l'):gsub('%s', '')
	local title = createEpub(link)
	ok, _, err = run('echo "' .. title .. '\nKindle article from reader" | mailx -v -s "Convert" -a"' .. KINDLE_TMP_DIR .. title .. '.epub" ' .. kindleEmail, "Can't send book: " .. title)
	assert(ok,err)
end

-- execute script in order to have atomic job
local function kindle()
	for _, link in ipairs(linkTab) do
		if args.email or args.e then
			os.execute('pueue add -g kindle url.lua --sendKindle ' .. link)
		else
			os.execute('pueue add -g kindle url.lua --createEpub ' .. link)
		end
	end
end

local function readable()
	local tmpPath, tmpName = createTmpFile({prefix = 'readable', format = 'adoc'})
	for _, link in ipairs(linkTab) do
		local createFile = os.execute('rdrview -H -A "Mozilla" "' .. link .. '" -T title | pandoc --from html --to asciidoc --output ' .. tmpPath)
		local termCmd = (os.getenv 'TERM_LT' .. os.getenv 'TERM_LT_RUN'):format('read', 'nvim ' .. tmpPath)
		os.execute(termCmd)
		assert(createFile == 0, 'Could not create file')
	end
	return 'Created file ' .. tmpName
end 

local function speed()
	local tmpPath, tmpName = createTmpFile({prefix = 'rsvp'})
	for _, link in ipairs(linkTab) do
		local createFile = os.execute('rdrview -H -A "Mozilla" "' .. link .. '" -T title | pandoc --from html --to plain --output ' .. tmpPath)
		local cmd = ('sh -c "cat %s | speedread -w 330"'):format(tmpPath)
		os.execute((os.getenv 'TERM_LT' .. os.getenv 'TERM_LT_FONT' .. os.getenv 'TERM_LT_RUN'):format(20, 'rsvp', cmd))
		assert(createFile == 0, 'Could not create file')
	end
	return 'RSVP finished ' .. tmpName
end 

local function wget()
	os.execute('mkdir -p ' .. WGET_DIR)
	local cmd = 'pueue add -- wget -P ' .. WGET_DIR
	M(linkTab):each(M.bindn(exec, cmd))
 -- -U "Mozilla"
end

local function gallery()
	os.execute('mkdir -p ' .. GALLERY_DIR)
	local cmd = 'pueue add -g dl-gallery -- gallery-dl -d ' .. GALLERY_DIR
	M(linkTab):each(M.bindn(exec, cmd))
end

--------------------------------------------------
--                    yt-dlp                    --
--------------------------------------------------

local function getTitle(url)
	local ok, out, err = run('yt-dlp -i --print title "' .. url .. '"')
	if ok and out[1] then
		return {[url] = out[1] }
	end
	return {[url] = ''}
end

local function dlAudio()
	os.execute('mkdir -p ' .. AUDIO_DIR)
	local cmdDlp = 'yt-dlp --embed-metadata -f bestaudio -x --audio-format mp3 -o "' .. AUDIO_DIR .. '%%(title)s.%%(ext)s" '
	local cmd = 'pueue add --escape --label "%s" -g dl-audio -- ' .. cmdDlp
	M(linkTab):map(getTitle)
		:each(M.bindn(exec, cmd))
end

local function dlVideo()
	os.execute('mkdir -p ' .. YT_DIR)
	local cmdDlp = "yt-dlp --embed-metadata -o '" .. YT_DIR .. "%%(title)s.%%(ext)s' "
	local cmd = 'pueue add --escape --label "%s" -g dl-video -- ' .. cmdDlp
	M(linkTab):map(getTitle)
		:each(M.bindn(exec, cmd))
end

local function removeListParam(link)
	return split(link,"&list=" )[1]
end

local function mpvPopup()
	local cmd = 'pueue add --label "%s" -g mpv-popup -- mpv --x11-name=videopopup --profile=stream-popup '
	M(linkTab):map(removeListParam)
		:map(getTitle)
		:each(M.bindn(exec, cmd))
end


local function mpvFullscreen()
	local cmd = 'pueue add  --label "%s" -g mpv-fullscreen -- mpv --profile=stream '
	M(linkTab):map(removeListParam)
		:map(getTitle)
		:each(M.bindn(exec, cmd))
end

local function mpvAudio()
	local termCmd = (os.getenv 'TERM_LT' .. os.getenv 'TERM_LT_RUN'):format('audio', 'mpv --profile=stream-audio ')
	local cmd = 'pueue add  --label "%s" -g mpv-audio -- ' .. termCmd
	M(linkTab):map(removeListParam)
		:map(getTitle)
		:each(M.bindn(exec, cmd))
end

local options = {
	["dlAudio"]= dlAudio, ["d"]= dlAudio,
	["dlVideo"]= dlVideo, ["v"]=dlVideo,
	["tor"]= createTorrent, ["t"]= createTorrent,
	["kindle"]= kindle, ["k"]= kindle,
	["sendKindle"]= sendKindle,
	["createEpub"]= createEpub,
	["read"]= readable, ["r"]= readable,
	["speed"]= speed, ["s"]= speed,
	["wget"]= wget, ["w"]= wget,
	["gallery"]= gallery, ["g"]= gallery,
	["mpvPopup"]= mpvPopup, ["p"]= mpvPopup,
	["mpvFullscreen"]= mpvFullscreen, ["f"]= mpvFullscreen,
	["mpvAudio"]= mpvAudio, ["a"]= mpvAudio,
	["h"]= help, ["help"]= help,
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
