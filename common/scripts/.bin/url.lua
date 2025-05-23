#!/bin/luajit

HELP = [[
Utils for URLs.
url.lua actions [options] url|clipItems
List of the actions:
		--menu -m show rofi with available actions
		--dlAudio -d downlad audio via youtube-dl 
		--dlVideo -y downlad video via youtube-dl 
		--tor -t create torrent file form a magnetlink
		--kindle -k downlad video via gallery-dl 
		--read -r convert website to asciidoc and show it in 'reader view' mode
		--speed -s convert website to text for rsvp
		--wget -w downlad file via wget
		--gallery -g downlad images via gallery-dl 
		--mpvPopup -p  add to a queue and open it in a popop window
		--mpvFullscreen, -f add to a queue and open it in a fullscreen window
		--mpvAudio, -a add to a queue and open it in as a audio
		--mpvVideo, -v play video in a fullscreen window
		--help -h - show help

List of the options:
		--number -n number of line from clipboard. In default it will grab one item from CLIPBOARD clipboard
		--primary -p → takes url from the PRIMARY clipboard, instead of the CLIPBOARD clipboard
		--input -i show form input for the number
		--email -e → option for kinde, ebook will be send to a kindle device via email. You need to setup mailx and create $PRIVATE/kindle_email file with an email address
		url - link for a website/video

Examples:
Convert a website to asciidoc and show it a terminal.
url.lua --read url
download torrent form clipboard
url.lua --tor --number 1
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

local YT_DIR = '~/Videos/YouTube/'
local WGET_DIR = '~/Downloads/wget'
local AUDIO_DIR = '~/Musics/PODCASTS/' 
local GALLERY_DIR = '~/Pictures/gallery-dl/'
local KINDLE_TMP_DIR = '/tmp/kindle/'
local LINK_REGEX = "^https?://(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w%w%w?%w?)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))"
local TOR_REGEX = "xt=urn:btih:([^&/]+)"

local function help() print(HELP); os.exit() end

local args = cliparse(arg, 'url')
local linkTab = args.url

local function startQueue(group)
	local _, startStatus, err = run(('pueue start -g %s'):format(group))
	assert(startStatus, err)
end

local function execQueue(cmd, group, url)
	if type(url) == 'string' then
		cmd = (cmd .. ' "%s"'):format(url)
		assert(os.execute(cmd) == 0, 'Can not run: ' .. cmd)
		return
	end
	local url, title = next(url)
	cmd = (cmd .. '"%s"'):format(title, url)
	assert(os.execute(cmd) == 0, 'Can not run: ' .. cmd)
	startQueue(group)
end

local function createTorrent(linkTab)
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
	_, ok, err = run('echo "' .. title .. '\nKindle article from reader" | mailx -v -s "Convert" -a"' .. KINDLE_TMP_DIR .. title .. '.epub" ' .. kindleEmail, "Can't send book: " .. title)
	assert(ok,err)
end

-- execute script in order to have atomic job
local function kindle(linkTab)
	for _, link in ipairs(linkTab) do
		if args.email or args.e then
			os.execute('pueue add -g kindle url.lua --sendKindle ' .. link)
		else
			os.execute('pueue add -g kindle url.lua --createEpub ' .. link)
		end
	end
	startQueue('kindle')
end

local function urlToDoc(url, filePath, docFormat)
	local cmd = ('rdrview -H -A "Mozilla" "%s" -T title | pandoc --from html --to %s --output "%s"'):format(url, docFormat, filePath)
	assert(os.execute(cmd) == 0, 'Could not create file')
end

local function readable(linkTab)
	-- I assume that `linkTab` will have only one element
	local tmpPath, tmpName = createTmpFile({prefix = 'readable', format = 'adoc'})
	for _, link in ipairs(linkTab) do
		urlToDoc(link, tmpPath, 'asciidoc')
		local termCmd = (os.getenv 'TERM_LT' .. os.getenv 'TERM_LT_RUN'):format('read', 'nvim ' .. tmpPath)
		os.execute(termCmd)
	end
	return 'Created file ' .. tmpName
end 

local function speed(linkTab)
	local tmpPath, tmpName = createTmpFile({prefix = 'rsvp'})
	for _, link in ipairs(linkTab) do
		urlToDoc(link, tmpPath, 'plain')
		local cmd = ('sh -c "cat %s | speedread -w 330"'):format(tmpPath)
		os.execute((os.getenv 'TERM_LT' .. os.getenv 'TERM_LT_FONT' .. os.getenv 'TERM_LT_RUN'):format(20, 'rsvp', cmd))
	end
	return 'RSVP finished ' .. tmpName
end 

local function wget(linkTab)
	os.execute('mkdir -p ' .. WGET_DIR)
	local cmd = ('pueue add -- wget -P "%s" '):format(WGET_DIR)
	M(linkTab):each(M.bindn(execQueue, cmd, 'default'))
 -- -U "Mozilla"
end

local function gallery(linkTab)
	os.execute('mkdir -p ' .. GALLERY_DIR)
	local cmd = ('pueue add -g dl-gallery -- gallery-dl -d "%s" '):format(GALLERY_DIR)
	M(linkTab):each(M.bindn(execQueue, cmd, 'dl-gallery'))
end

--------------------------------------------------
--                    yt-dlp                    --
--------------------------------------------------

local function getTitle(url)
	local out, ok = run('yt-dlp -i --print title "' .. url .. '"')
	if ok and out[1] then
		return {[url] = out[1]:gsub('"', "'") } -- escape "
	end
	return {[url] = ''}
end

local function dlAudio(linkTab)
	os.execute('mkdir -p ' .. AUDIO_DIR)
	local cmdDlp = 'yt-dlp -q --embed-metadata -f bestaudio -x --audio-format mp3 -o "' .. AUDIO_DIR .. '%%(title)s.%%(ext)s" '
	local cmd = 'pueue add --escape --label "%s" -g dl-audio -- ' .. cmdDlp
	M(linkTab):map(getTitle)
		:each(M.bindn(execQueue, cmd, 'dl-audio'))
end

local function dlVideo(linkTab)
	os.execute('mkdir -p ' .. YT_DIR)
	local cmdDlp = "yt-dlp -q --embed-metadata -f 'bestvideo[height<=1440]+bestaudio/best' -o '" .. YT_DIR .. "%%(title)s.%%(ext)s' "
	local cmd = 'pueue add --escape --label "%s" -g dl-video -- ' .. cmdDlp
	M(linkTab):map(getTitle)
		:each(M.bindn(execQueue, cmd, 'dl-video'))
end

local function removeListParam(link)
	return split(link,"&list=" )[1]
end

local function mpvPopup(linkTab)
	local cmd = 'pueue add --label "%s" -g mpv-popup -- mpv --x11-name=videopopup --profile=stream-popup '
	M(linkTab):map(removeListParam)
		:map(getTitle)
		:each(M.bindn(execQueue, cmd, 'mpv-popup'))
end

local function mpvAudio(linkTab)
	local termCmd = (os.getenv 'TERM_LT' .. os.getenv 'TERM_LT_RUN'):format('audio', 'mpv --profile=stream-audio ')
	local cmd = 'pueue add -e --label "%s" -g mpv-audio -- ' .. termCmd
	M(linkTab):map(removeListParam)
		:map(getTitle)
		:each(M.bindn(execQueue, cmd, 'mpv-audio'))
end

local function mpvFullscreen(linkTab)
	local cmd = 'pueue add  --label "%s" -g mpv-fullscreen -- mpv --profile=stream '
	M(linkTab):map(removeListParam)
		:map(getTitle)
		:each(M.bindn(execQueue, cmd, 'mpv-fullscreen'))
end

local function mpvVideo(linkTab)
	local cmd = 'pueue add  --label "%s" -g default -- mpv --profile=stream '
	M(linkTab):map(removeListParam)
		:map(getTitle)
		:each(M.bindn(execQueue, cmd, 'default'))
end

local options = {
	["dlAudio"]= dlAudio, ["d"]= dlAudio,
	["dlVideo"]= dlVideo, ["y"]=dlVideo,
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
	["mpvVideo"]= mpvVideo, ["v"]= mpvVideo,
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
	action = switch(options, selection[1])
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

local status, val = pcall(action, linkTab)
if status then
	notify(val)
else
	log(val, 'ERROR')
	notifyError(val)
end
