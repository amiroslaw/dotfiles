-- most functions copied from 
-- https://github.com/marcotrosi/init.lua
--
--[[
printt(table, file) to print tables on screen or to file
copyt(table) copy table
readf(file) read file, return table
writef(string|table, file, [readmode]) write table/string to file
eq compares 2 values for equality
run(cmd) executes external command and optionally capture the output
str converts any non-string type to string, and strings to quoted strings

switch(cases, pattern)
log(logMsg, [ level ], [ file ])
trim
isArray
enum({ 'a', 'b' })
split(string, separator)
splitFlags(string)
notify(string)
notifyError(string)
rofiMenu(optionTab, [prompt], [menuHeight])
rofiInput([prompt], [width]) 
rofiNumberInput([prompt])
--]]


-- printt <<<
--[[
A simple function to print tables or to write tables into files.
Great for debugging but also for data storage.
When writing into files the 'return' keyword will be added automatically,
so the tables can be loaded with 'dofile()' into a variable.
The basic datatypes table, string, number, boolean and nil are supported.
The tables can be nested and have number and string indices.
This function has no protection when writing files without proper permissions and
when datatypes other then the supported ones are used.

t = table
f = filename (optional)
--]]
function printt(t, f)

   local function printTableHelper(obj, cnt)

      local cnt = cnt or 0

      if type(obj) == "table" then

         io.write("\n", string.rep("\t", cnt), "{\n")
         cnt = cnt + 1

         for k,v in pairs(obj) do

            if type(k) == "string" then
               io.write(string.rep("\t",cnt), '["'..k..'"]', ' = ')
            end

            if type(k) == "number" then
               io.write(string.rep("\t",cnt), "["..k.."]", " = ")
            end

            printTableHelper(v, cnt)
            io.write(",\n")
         end

         cnt = cnt-1
         io.write(string.rep("\t", cnt), "}")

      elseif type(obj) == "string" then
         io.write(string.format("%q", obj))

      else
         io.write(tostring(obj))
      end 
   end

   if f == nil then
      printTableHelper(t)
   else
      io.output(f)
      io.write("return")
      printTableHelper(t)
      io.output(io.stdout)
   end
end -- >>>
-- copyt <<<
--[[
This is a simple copy table function. It uses recursion so you may get trouble
with cycles and too big tables. But in most cases this function is absolutely enough.

t = table to copy
--]]
function copyt(t)

   if type(t) ~= "table" then return nil end

   local Copy_t = {}
 
   for k,v in pairs(t) do
      if type(v) == "table" then
         Copy_t[k] = copyt(v)
      else
         Copy_t[k] = v
      end
   end
 
   return Copy_t
end -- >>>
-- readf <<<
--[[
readf reads a file and returns the content as a table with one line per index.
if the file was not readable readf returns nil.

f = filename
--]]
function readf(f)

   if (type(f) ~= "string") then
      return nil
   end

   local File_t = {}
   local File_h = io.open(f)

   if File_h then
      for l in File_h:lines() do
         table.insert(File_t, (string.gsub(l, "[\n\r]+$", "")))
      end
      File_h:close()
      return File_t
   end

   return nil
end -- >>>
-- writef <<<
--[[
writef takes a table or string and writes it to a file and returns true if writing was successful, otherwise nil.
If t is a table it shall contain numerical indices (1 to n) with strings as values, and no nil values in-between.

t = table or string containing file lines
f = filename
n = newline character (optional, default is "\n")
m = write mode ["w"|"a"|"w+"|"a+"] (optional, default is "w") - a mode, doesn't add new line after secoundary append
--]]
function writef(t, f, n, m)

   local n = n or "\n"
   local m = m or "w"

   if (type(t) ~= "table") and (type(t) ~= "string")              then return nil end
   if (type(f) ~= "string")                                       then return nil end
   if (type(n) ~= "string")                                       then return nil end
   if (type(m) ~= "string") or (not string.match(m, "^[wa]%+?$")) then return nil end
	local existed = exist(f)
   local File_h = io.open(f, m)
   if File_h then
	   if existed and ( m == 'a' or m == 'a+' ) then
            File_h:write('\n')
	   end
      if (type(t) == "table") then
         for _,l in ipairs(t) do
            File_h:write(l)
            File_h:write(n)
         end
      else
         File_h:write(t)
      end
      File_h:close()
      return true
   end
   return nil
end -- >>>

-- eq <<<
--[[
This function takes 2 values as input and returns true if they are equal and false if not.

a and b can numbers, strings, booleans, tables and nil.
--]]
function eq(a,b)

   local function isEqualTable(t1,t2) -- <<<

      if t1 == t2 then
         return true
      end

      for k,v in pairs(t1) do

         if type(t1[k]) ~= type(t2[k]) then
            return false
         end

         if type(t1[k]) == "table" then
            if not isEqualTable(t1[k], t2[k]) then
               return false
            end
         else
            if t1[k] ~= t2[k] then
               return false
            end
         end
      end

      for k,v in pairs(t2) do

         if type(t2[k]) ~= type(t1[k]) then
            return false
         end

         if type(t2[k]) == "table" then
            if not isEqualTable(t2[k], t1[k]) then
               return false
            end
         else
            if t2[k] ~= t1[k] then
               return false
            end
         end
      end

      return true
   end -- >>>

   if type(a) ~= type(b) then
      return false
   end

   if type(a) == "table" then
      return isEqualTable(a,b)
   else
      return (a == b)
   end
end -- >>>
-- run <<<
--[[
This is kind of a wrapper function to os.execute and io.popen.
The problem with os.execute is that it can only return the
exit status but not the command output. And io.popen can provide
the command output but not an exit status. This function can do both.
It will return the same return valus as os.execute plus two additional tables.
These tables contain the command output, 1 line per numeric index.
Line feed and carriage return are removed from each line.
The first table contains the stdout stream, the second the stderr stream.

cmd     = command to execute, can be string or table
status,out,err = run("ls -l")
printt(out)
printt(err)
--]]
function run(cmd)
 
   if (type(cmd) ~= "string") and (type(cmd) ~= "table") then return nil end
 
   local OutFile_s = "/tmp/init.lua.run.out"
   local ErrFile_s = "/tmp/init.lua.run.err"
   local Command_s
   local Out_t
   local Err_t

   if type(cmd) == "table" then
      Command_s = table.concat(cmd, " ")
   else
      Command_s = cmd
   end

      Command_s = "( " .. Command_s .. " )" .. " 1> " .. OutFile_s .. " 2> " .. ErrFile_s
-- maybe change status when is 0 to nil for better assertion
   local Status_code = os.execute(Command_s)
  Out_t = readf(OutFile_s)
  Err_t = readf(ErrFile_s)
  os.remove(OutFile_s)
  os.remove(ErrFile_s)
  local status = Status_code == 0 and true or false
  return status, Out_t, Err_t, Status_code
end -- >>>
-- str <<<
--[[
This function converts tables, functions, ... to strings.
If the input is a string then a quoted string is returned.

x = input to convert to string
--]]
function str(x)
   if type(x) == "table" then
      local ret_t = {}
      local function convertTableToString(obj, cnt) -- <<<
         local cnt=cnt or 0
         if type(obj) == "table" then
            table.insert(ret_t, "\n" .. string.rep("\t",cnt) .. "{\n")
            cnt = cnt+1
            for k,v in pairs(obj) do
               if type(k) == "string" then
                  table.insert(ret_t, string.rep("\t",cnt) .. '["' .. k .. '"] = ')
               end
               if type(k) == "number" then
                  table.insert(ret_t, string.rep("\t",cnt) .. "[" .. k.. "] = ")
               end
               convertTableToString(v, cnt)
               table.insert(ret_t, ",\n")
            end
            cnt = cnt-1
            table.insert(ret_t, string.rep("\t",cnt) .. "}")
         elseif type(obj) == "string" then
            table.insert(ret_t, string.format("%q",obj))
         else
            table.insert(ret_t, tostring(obj))
         end 
      end -- >>>
      convertTableToString(x)
      return table.concat(ret_t)
   elseif type(x) == "function" then
      local status, result = pcall(string.dump, x, true)
      if status then
         return result
      else
         return "not dumpable function"
      end
   elseif type(x) == "string" then
      return string.format("%q", x)
   else
      return tostring(x)
  end
	 
end -- >>>

--- exist <<<
-- Check if file or directory exist
function exist(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end --- >>> 


--- switch <<<
-- the argument cases is a key-value table. Values can be either variables or functions.
function switch(cases, pattern)
	for k, v in pairs(cases) do
		if k == pattern then
			return v
		end
	end
	return cases[false]
end -- >>>

--- trim <<<
function trim(s)
   return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end -- >>>
-- isArray <<<
-- if a table is a dictionary it will return false
--]]
function isArray(table)
  if type(table) == 'table' and #table > 0 then
    return true
  end
  return false
end -- >>>

-- split <<<
function split(str, delimiter)
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
	return result
end -- >>>

-- enum <<<
-- Enum table. When accessing or modifying an entry of existing or notexisting value, the error will be thrown.
function enum(tab)
	local meta_table = {
		__index = function(self, key)
			if tab[key] == nil then
				error("Attepted access a non existant field: " .. key)
			end
			return tab[key]
		end,
		__newindex = function(self, key, value)
			error("Attepted to modify const table: " .. key .. " " .. value)
		end,
		__metatable = false
	}
	return setmetatable({}, meta_table)
end -- >>>

--- util for scripting <<< 

-- notify <<<
-- Send notification.
function notify(msg)
	print(msg)
	os.execute("dunstify '" .. msg .. "'")
end 

function notifyError(msg)
	os.execute("dunstify -u critical Error: '" .. msg .. "'")
	error(msg) -- does not work?
end -- >>>

-- rofi <<<

--[[
Shows a rofi input. 
Prompt or width can be adjusted. The width accepts following units:
80px;80%;80ch
--]]
function rofiInput(prompt, width) 
	prompt = prompt and prompt or 'Input'
	width = width and width or '500px'
	return io.popen('rofi -monitor -4 -theme-str "window {width:  ' .. width .. ';}" -l 0 -dmenu -p "'.. prompt ..'"'):read('*a'):gsub('\n', '')
end 

--[[
Shows a rofi input for a number. Input will be appear until it will get valid type.
Prompt can be adjusted, default is "Input".
--]]
function rofiNumberInput(prompt)
	local input
	repeat
		input = rofiInput(prompt, #prompt + 11 .. 'ch')
	until tonumber(input)
	return input
end 

--[[
Shows a rofi menu. Option can be parser form an array (ordered table) or a dictionary.
prompt or menuHeight can be adjusted 
--]]
function rofiMenu(optionTab, prompt, menuHeight)
	local prompt = prompt and prompt or 'Select'
	local menuHeight = menuHeight and menuHeight or 25
	local options = ''
	local lines = 0
	local isArray = isArray(optionTab)

	for key,val in pairs(optionTab) do
		if isArray then
			options = options  .. val	.. '|'
		else
			options = options  .. key	.. '|'
		end
		lines = lines + 1
	end
	if lines > menuHeight then
		lines = menuHeight
	end
	return io.popen('echo "' .. options .. '" | rofi -multi-select -monitor -4 -i -l ' .. lines .. ' -sep "|" -dmenu -p "' .. prompt .. '"'):read('*a'):gsub('\n', '')
end -- >>>

-- getConfigProperties <<<
-- Read configuration file with key=value format. Function returns table(map).
function getConfigProperties(path)
	assert(os.execute( "test -f " .. path ) == 0, 'Config file does not exist: ' .. path)
	local properties = {}
	for line in io.lines(path) do
		local property = split(line, '=')
		properties[property[1]:gsub('%s', '')] = property[2]:gsub('%s', '')
	end
	return properties
end -- >>>

-- splitFlags <<<
-- Splits arguments from the script flags. Example:  -a or -abcd.
function splitFlags(optionsTxt)
	local flags = {}
	if not optionsTxt or optionsTxt == '' then return flags end
	optionsTxt:gsub(".", function(char) 
		if char ~= '-' then 
			flags[char] = char 
		end
	end)
	return flags
end -- >>>

-- log <<<
--[[
log takes a table or string and writes it to a file and returns true if writing was successful, otherwise nil.
If t is a table it shall contain numerical indices (1 to n) with strings as values, and no nil values in-between.

input = table or string containing file lines
level(optional) = default 'INFO'
file(optional) = filename or path - default  '/tmp/lua.log'

--]]
function log(input, level, file)
	if (type(input) ~= 'table') and (type(input) ~= 'string') then
		return nil
	end
	local file = file or '/tmp/lua.log'
	local level = level or 'INFO'
	level = '[' .. level .. '] '
	local date = '[' .. os.date '%Y-%m-%d %H:%M:%S' .. '] '
	local logPrefix = date .. level

	if type(input) == 'table' then
		for i, l in ipairs(input) do
			input[i] = logPrefix .. l
		end
	else
		input = logPrefix .. input
	end

	writef(input, file, '\n', 'a+')
end -- >>>

-- >>>
-- vim: fmr=<<<,>>> fdm=marker
