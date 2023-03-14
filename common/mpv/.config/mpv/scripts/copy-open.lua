-- require 'mp'
-- require 'mp.msg'

-- Requirement: xclip
-- Installation: 
-- 'mkdir -p ~/.config/mpv/scripts && cp -i copy-open.lua ~/.config/mpv/scripts'

local function getCWD(s)
    pathTab = {};
	for w in s:gmatch("(.-)/") do 
        table.insert(pathTab, w);
	end
	return table.concat(pathTab, '/')
end

local function copyX(text)
  local pipe = io.popen("xclip -silent -in -selection clipboard", "w")
  pipe:write(text)
  pipe:close()
  mp.osd_message("Copied: " .. text)
end

-- it's a relative path with filename
local function getPath()
	return mp.get_property("path")
end

function copyPath()
	copyX(getPath())
end

-- Copy Filename with Extension
local function getFilename()
    return string.format("%s", mp.get_property_osd("filename"))
end
local function copyFilename()
    copyx(getFilename())
end

local function copyDuration()
    local duration = string.format("%s", mp.get_property_osd("duration"))
	copyX(duration)
end

local function copyMetadata()
    local metadata = string.format("%s", mp.get_property_osd("metadata"))
	copyX(metadata)
end

function openUrl()
	os.execute('xdg-open ' .. mp.get_property("path"))
end

function openFolder()
	local path = getCWD(getPath())
	  mp.osd_message(path)
	os.execute('xdg-open "' .. path  .. '"')
end

-- mp.register_event("copy-path", copyPath)
-- mp.register_script_message("copy-path", copyPath)
-- mp.add_key_binding("ctrl+SPACE", "copy-path", copyPath)
mp.add_key_binding("ctrl+alt+b", "open-folder", openFolder)
mp.add_key_binding("ctrl+b", "open-url", openUrl)
mp.add_key_binding("ctrl+c", "copy-path", copyPath)

