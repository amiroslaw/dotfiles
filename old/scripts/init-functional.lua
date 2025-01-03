-- most functions copied from 
-- can load module
-- https://github.com/marcotrosi/init.lua
--https://github.com/pocomane/luasnip
--https://github.com/jhoonb/functional-lua
--https://github.com/Yonaba/Moses/tree/master

--[[
FUNCTIONAL
max,min- → math.max(unpack(seq))

bind2
both
flatten
curry
head
tail
map(f, ...) -> table
reduce(x[, op]) -> number
filter(f, x) -> table
range(from[, to, [step] ] ) -> table
any(f, x) -> boolean
all(f, x) -> boolean
replicate(x,y) -> table
isArray
groupBy
partition
keys
values

UTILS
printt(table, file) to print tables on screen or to file
copyt(table) deep copy table
readf(file) read file, returns table
writef(string|table, file, [readmode]) write table/string to file, can't have nil
eq compares 2 values for equality
status,out,err = run(cmd, msgErr) - status is boolean; out is a table; executes external command and optionally capture the output
str converts any non-string type to string, and strings to quoted strings

filenamesplit( filepathStr ) --> pathStr, nameStr, extStr
jsonish
jsonishout 
jsonishout{{a=1},{1,"b"}} == '[{"a":1},[1,"b"]\]'
keysort This function return the list of all the keys of the input inTab table. The keys are alphabetically sorted.
keysort( inTab ) --> outArr
cliparse cliparse({'-aib','--key','defKey','--opt=2'}, 'defKeyArg'); value option can have space even in a quote

SCRIPTING
switch(cases, pattern)
log(logMsg, [ level ], [ file ])
trim(s) - trim string from whitespaces
enum({ a =1 , b =1 }) returns table; problems with deep copy or loops
split(string, separator) returns table;
splitFlags(string)
notify(string)
notifyError(string)
rofiNumberInput([prompt])
rofiInput([rofiOptions]) 
rofiMenu(entriesTab, [rofiOptions]), returns table if selected multiple items or string otherwise. For the second argument returns keybinding, if custom keys were provided.
editor(path|text, [editorName]) Opens file or text in editor. 
dialog(msg, [style]) - show rofi's dialog
optionTab - Options can be parser form an array (ordered table) or a dictionary.
rofiInput - optional arguments that can be passed via table
	prompt (string)
	height (number)-  max lines than rofi can show
	width (string)- It accepts width with unit. It accepts following units: 80px;80%;80ch
	multi (boolean)- If true rofi will allow to select multiple rows, and it will return table with selected options
--]]

--- FUNCTIONAL <<<
--- operator <<<
operator = {
     mod = function(n,m) return n % m end;
     pow = math.pow;
     add = function(n,m) return n + m end;
     sub = function(n,m) return n - m end;
     mul = function(n,m) return n * m end;
     div = function(n,m) return n / m end;
     gt  = function(n,m) return n > m end;
     lt  = function(n,m) return n < m end;
     eq  = function(n,m) return n == m end;
     le  = function(n,m) return n <= m end;
     ge  = function(n,m) return n >= m end;
     ne  = function(n,m) return n ~= m end;
	 -- than 
	 -- example of grater than: filter(operator.gtt(4), seq)
     gtt  = function(n) return function(m) return m > n end end;
     ltt  = function(n) return function(m) return m < n end end;
     eqt  = function(n) return function(m) return m == n end end;
     net  = function(n) return function(m) return m ~= n end end;
 }
-- >>>

--- reduce, head tail <<<
 -- head(table)
 -- e.g: head({1,2,3}) -> 1
 function head(tbl)
     return tbl[1]
 end

 -- tail(table)
 -- e.g: tail({1,2,3}) -> {2,3}
 function tail(tbl)
     if #tbl < 1 then
         return nil
     else
         local newtbl = {}
         local tblsize = #tbl
         local i = 2
         while (i <= tblsize) do
             table.insert(newtbl, i-1, tbl[i])
             i = i + 1
         end
        return newtbl
     end
 end
 -- foldr(function, default_value, table)
 -- e.g: foldr(operator.mul, 1, {1,2,3,4,5}) -> 120
 function foldr(func, val, tbl)
     for i,v in pairs(tbl) do
         val = func(val, v)
     end
     return val
 end

 -- reduce(function, table)
 -- e.g: reduce(operator.add, {1,2,3,4}) -> 10
 function reduce(func, tbl)
     return foldr(func, head(tbl), tail(tbl))
 end
-- >>>

--- map <<<
-- Function: Map: applies the function f on each table passed as argument  
-- map( f, ...)
--
-- Example:
-- f = function(a,b) return a + b end
-- x, y = {2,4}, {2,4}
-- map(f,x,y) ==> table: {4,16}
--
-- param f: function
-- param ... : multiples parameters of lists(table) 
-- return: table or nil

function mapOneArray(func, array)
  local new_array = {}
  for i,v in ipairs(array) do
    new_array[i] = func(v)
  end
  return new_array
end
function map(func, ...)
  local new_array = {}
  local i=1
  local arg = {...}
  local arg_length = #arg
  while true do
    local arg_list = mapOneArray(function(arr) return arr[i] end, arg)
    if #arg_list < arg_length then return new_array end
    new_array[i] = func(unpack(arg_list))
    i = i+1
  end
end

-- >>>
--- filter <<<
-- Function: filter, creates a list starting from x where x a for
-- each function f is true
-- filter(f, x)
-- Example:
-- f = function(a) if type(a) == 'number' then return true end return false end
-- filter(f, {'aa','bc',123, '1567', 5, 8, 0, 'a'}) -> {123, 5, 8, 0}
--
-- param: f: function
-- param: x: table
-- return: table
--
function filter(f, x)
	assert(f and x and #x > 0, 'nil function/table or empty table')
	assert(type(f) == 'function', 'first param has to be a function')
	local aux = {}
	for i = 1, #x do
		if f(x[i]) then table.insert(aux,x[i]) end
	end

	return aux
end
-- >>>

--- curry <<< 
-- curry(f,g)
-- can replace curring with annonymous function
-- e.g: printf = curry(io.write, string.format)
--          -> function(...) return io.write(string.format(unpack(arg))) end
function curry(f,g)
 return function (...)
	 return f(g(unpack(arg)))
 end
end
-- >>>

--- random <<<
-- Function: Generate list of elements
-- range(from[, to[, step]])
-- Examples:
-- range(10)     => {1,2,3,4,5,6,7,8,9,10}
-- range(2,5)    => {2,3,4,5}
-- range(-2,4,2) => {-2,0,2,4}
--
-- param from: number
-- param to: number (optional)
-- param step: number  (optional, default: 1)
-- return: table
function range(from, to, step)
	assert(from and type(from) == 'number', '1st param has to be a number')

	local step = step or 1
	if not to then
		from, to = 1, from
	end

	assert(type(to) == 'number' and type(step) == 'number', '2th param has to be a number') 
	assert(from <= to, '1st param <= 2th')

	local aux = {}
	for i = from, to, step do table.insert(aux, i) end
	return aux
end
-- >>>

--- any <<<
-- Function: Returns true if any element of x is true for the function f(x)
-- any(f, x)
-- Example:
-- function f(a) if type(a) == 'number' then return true end return false end
-- any(f, {2,3,4,5}) 			-> true
-- any(f, {2,3,4,'aba'}) -		-> true
-- any(f, {'lol', 'test', '2'}) -> false
--
-- param f: function
-- param x: table 
-- return: boolean
function any(f, x)
	assert(f and x and #x > 0, 'nil function/table or empty table')
	assert(type(f) == 'function', 'first param has to be a function')

	for i = 1, #x do 
		if f(x[i]) then return true end
	end
	return false
end
-- >>>

-- all <<<
-- Function: Returns true if all element of x is true for the function f(x)
-- all(f, x)
--
-- Example:
-- function f(a) if type(a) == 'number' then return true end return false end
-- all(f, {2,3,4,5}) 			-> true
-- all(f, {2,3,4,'aba'}) -		-> false
-- all(f, {'lol', 'test', '2'}) -> false
--
-- param f: function
-- param x: table 
-- return: boolean
function all(f, x)
	assert(f and x and #x > 0, 'nil function/table or empty table')
	assert(type(f) == 'function', 'first param has to be a function')

	for i = 1, #x do
		if not f(x[i]) then return false end
	end
	return true
end
-- >>>

--- replicate <<<
-- Function: generates a list of elements x of y
-- replicate(x, y)
--
-- Example:
-- replicate('a',5) 	-> {'a', 'a', 'a', 'a'}
-- replicate({2}, 3) 	-> {{2}, {2}}
-- replicate(2, 4) 		-> {2, 2, 2, 2} 

-- param x: number, string, table, function
-- param y: number > 0
-- return: table
function replicate(x, y)
	assert(x and y and y > 0)
	assert(type(y) == 'number', '2th param has to be a number')
	
	local aux = {}
	for i = 1, y do 
		table.insert(aux, x)
	end
	return aux
end
-- >>>

--- flatten <<<
--- Flattens a nested array. Passing `shallow` will only flatten at the first level.
-- @name flatten
-- @param array an array
-- @param[opt] shallow specifies the flattening depth. Defaults to `false`.`
-- @return a flattened array
--flatten({1,{2,3},{4,5,{6,7}}}) -- => "{1,2,3,4,5,6,7}"
function flatten(array, shallow)
  shallow = shallow or false
  local new_flattened
  local _flat = {}
  for key,value in ipairs(array) do
    if type(value) == 'table' then
      new_flattened = shallow and value or flatten (value)
      for k,item in ipairs(new_flattened) do _flat[#_flat+1] = item end
    else _flat[#_flat+1] = value
    end
  end
  return _flat
end
-- >>>


--- partition <<<
function partition(predicate, sequence)
	assert(type(predicate) == 'function', '1st param has to be a function')
	assert(type(sequence) == 'table', '2th param has to be a table')

    local left = { }
    local right = { }
    for i, v in ipairs(sequence) do
        if (predicate(v)) then
            table.insert(left, v)
        else
            table.insert(right,v)
        end
    end
    return left, right
end
-- >>>

-- isArray <<<
-- if a table is a dictionary it will return false. 
--]]
function isArray(obj)
  if not (type(obj) == 'table') then return false end
  local i = 0
  for k in pairs(obj) do
     i = i + 1
     if obj[i] == nil then return false end
  end
  return true
end
-- >>>

-- groupBy <<<
-- groupBy (t, iter)
-- Splits a table into subsets groups.
-- Parameters:
-- t a table
-- iter an iterator function, prototyped as iter (v, k)
-- Returns: a table of subsets groups
-- local byGrade = groupBy(function(score) 
-- 			return score < 65 and 'F' or
-- 					score < 80 and 'C' or
-- 					score < 90 and 'B' or 'A'
-- 		end, range(40,100,5))

function groupBy(iter, t)
  local _t = {}
  for k,v in pairs(t) do
    local _key = iter(v,k)
    if _t[_key] then _t[_key][#_t[_key]+1] = v
    else _t[_key] = {v}
    end
  end
  return _t
end


-- >>>

--- bind2 <<<
--- Binds `v` to be the second argument to `f`. Calling `f (a, ...)` will result to `f (a, v, ...)`.
-- @param f a function
-- @param v a value
-- @return a function
-- can replace curring
-- function add(a,b) return a+b end
-- b = bind2(add,3)
-- print(b(4))
function bind2(f, v)
  return function (t, ...)
    return f(t, v, ...)
  end
end
-- >>>


--- both <<<
--- Returns a validation function. Given a set of functions, the validation function evaluates
-- to `true` only when all its funcs returns `true`.
-- @param ... an array list of functions
-- @return `true` when all given funcs returns true with input, false otherwise
-- local f = M.both(
--     function(x) return x > 0 end,
--     function(x) return x < 10 end,
--     function(x) return x % 2 == 0 end
-- )
-- f(2) -- => true
-- f(8) -- => true
-- f(9) -- => false
function both(...)
  local funcs = {...}
  return function (...)
    for k, f in ipairs(funcs) do
      if not f(...) then return false end
    end
    return true
  end
end
-- >>>

-- >>>


-- notify <<<
--[[
Send notification.
usage - type of the quotation marsks are important
style = { [' red '] = 'red', 'default', }
notify("title", 'first pattern is red and the second has a default color', style)
TODO add time option??
--]]
local function applyStyle(text, style)
	local defaultColor = '#08D9D6'
	for key,val in pairs(style) do
		local pattern
		local color = defaultColor
		if tonumber(key) then
			pattern = val
		else
			pattern = key
			color = val
			-- if text:match(pattern) ~= key then
				-- print(text:match(pattern))
			-- end
		end
		text = text:gsub(pattern, "<span color='" .. color .. "'>" .. pattern .. "</span>")
	end
	return text
end

function notify(msg, body, style)
	if type(body) == 'table' then
		body = table.concat(body, '\n')
	end
	if body and  msg then
		msg = msg:gsub('"', '\\"')
		body = body:gsub('"', '\\"')
		printt(style)
		if style then
			body = applyStyle(body, style)
		end
		os.execute('notify-send "' .. msg .. '" "' .. body .. '"')
	elseif msg then
		msg = msg:gsub('"', '\\"')
		os.execute('notify-send "' .. msg .. '"')
	end
end 

function notifyError(msg)
	if msg ~= nil then
		if type(msg) == 'table' then
			msg = msg[1] and msg[1] or 'empty error msg'
		end
		msg = msg:gsub('"', '\\"')
		os.execute('notify-send -u critical Error: "' .. msg .. '"')
		-- os.execute("notify-send -u critical Error: '" .. msg .. "'")
		print(msg)
		-- error(msg) -- does not work?
	end
end -- >>>


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
  --  else
	 --  notifyError('test - readf file is not string?')
  -- end

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
			 -- if l then -- allow nil values and exclude them, IDK if it's necessary 
			 -- end
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
Warning: can't be execute in parallel, also sometimes have problem with reading output from tmp files. - fix with tmp file name

This is kind of a wrapper function to os.execute and io.popen.
The problem with os.execute is that it can only return the
exit status but not the command output. And io.popen can provide
the command output but not an exit status. This function can do both.
It will return the same return valus as os.execute plus table for output and error message.
The output table contain the command output, 1 line per numeric index.
Line feed and carriage return are removed from each line.
The error output is a join of our error msg and the stderr stream.

cmd     = command to execute, can be string or table
status,out,err = run("ls -l", "error msg")
printt(out)
print(err)
--]]
function run(cmd, errorMsg)
   if (type(cmd) ~= "string") and (type(cmd) ~= "table") then return nil end
 
   local OutFile_s = os.tmpname()
   local ErrFile_s = os.tmpname()
   local Command_s
   local Out_t
   local Err

   if type(cmd) == "table" then
      Command_s = table.concat(cmd, " ")
   else
      Command_s = cmd
   end

      Command_s = "( " .. Command_s .. " )" .. " 1> " .. OutFile_s .. " 2> " .. ErrFile_s
   local Status_code = os.execute(Command_s)
  Out_t = readf(OutFile_s) -- sometimes is nil
	local err_f  = io.open(ErrFile_s, "r")
	local status = Status_code == 0
	if not status and err_f then
		if errorMsg then
			Err = errorMsg .. '\n' .. err_f:read("*all")
		else
			Err = err_f:read("*all")
		end
		err_f:close()
	end

	-- for testing a bug
  if not Out_t then
	  notifyError('test - run command can not read output')
  end

  os.remove(OutFile_s)
  os.remove(ErrFile_s)
  return status, Out_t, Err, Status_code
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
--[[ keys = {
	['Alt-m'] = 'modify',
	[false] = 'default',
} 
local action = switch(keys, 'Alt-o')
--]]
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

--- keys <<<
--- Returns the keys of the object properties.
-- @name keys
-- @param obj an object
-- @return an array
-- keys({x = 0, y = 1}) -- => "{'y','x'}"
function keys(obj)
  local keys = {}
  for key in pairs(obj) do keys[#keys+1] = key end
  return keys
end
-- >>>

--- values <<<
--- Returns the values of the object properties.
-- @name values
-- @param obj an object
-- @return an array of values
function values(obj)
  local values = {}
  for key, value in pairs(obj) do values[#values+1] = value end
  return values
end
-- >>>

-- split <<<
function split(str, delimiter)
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
	return result
end -- >>>

-- enum <<<
-- Enum table. Takes "map" as a parameter. When accessing or modifying an entry of existing or notexisting value, the error will be thrown.
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

-- rofi <<<
--[[
Opens file or text in editor. If provides only text - it will open in temporary file with asciidoc extension.
--]]
function editor(text, editorName)
	local editorName = editorName and editorName or  os.getenv('GUI_EDITOR')
	if os.execute( "test -f " .. text ) == 0 then
		local ok = os.execute(editorName .. ' ' .. text )
		assert(ok == 0, 'Could not open ' .. text)
		return 0
	end

	if type(text) == 'table' then
		text = table.concat(text, '\n')
	end

	if text and editorName then
		local fileName = os.tmpname() .. '.adoc'
		io.open(fileName, 'w'):write(text)
		local ok = os.execute(editorName .. ' ' .. fileName )
		assert(ok == 0, 'Could not open ' .. fileName)
	end
end 
--- >>>

-- rofi <<<
local function combineOptions(opt)
local ACCENT_COLOR = 'purple'
local defaultOpt = {prompt = 'Select', width = '500px', height = 24, multi = '', keys = '', msg = ''}
local keys = {}
if opt then
	local keybindingCmd = ''
	local keyMsgCmd = ''
	for name,val in pairs(opt) do
		if name == 'multi' and val then
			defaultOpt[name] = ' -multi-select '
		elseif name == 'keys' then
			local numberKey = 1
			local keysOpt = opt.keys
			local _, keyVal = next(keysOpt)
			if type(keyVal) == 'table' then
				for k,tab in pairs(opt.keys) do
					keysOpt[k] = tab[1]
				end
			end
			for keybinding, description in pairs(keysOpt) do
				keybindingCmd = keybindingCmd .. ' -kb-custom-' .. numberKey .. ' "' .. keybinding .. '" '
				keyMsgCmd = keyMsgCmd .. " <span color='" .. ACCENT_COLOR .. "'>" .. keybinding .. "</span>:" .. description .. ";"
				keys[numberKey] = keybinding
				numberKey = numberKey +1
			end
		else
			defaultOpt[name] = val
		end
	end
	if opt.msg or opt.keys then
		defaultOpt.msg = ' -markup -mesg "' .. defaultOpt.msg .. keyMsgCmd  .. '" ' .. keybindingCmd
	end
end
return defaultOpt, keys
end

--[[
Shows a rofi dialog.
	msg (string) - Message information, accepts pango markup(html like).
style = { [' red '] = 'red', 'default', }
--]]
function dialog(msg, style)
	if type(msg) == 'table' then
		msg = table.concat(msg, '\n')
	end
	if  msg then
		msg = msg:gsub('"', '\\"')
		if style then
			msg = applyStyle(msg, style)
		end
		os.execute('rofi -e "' .. msg .. '"')
	end
end 

--[[
Shows a rofi string input 
Returns provided string.
opt - optional arguments that can be passed via table
	prompt (string)
	width (string)- It accepts width with unit. It accepts following units: 80px;80%;80ch
	msg (string) - Message information, accepts pango markup(html like).
--]]
function rofiInput(options) 
	local opt = combineOptions(options)
	return io.popen('rofi -monitor -4 -theme-str "window {width:  ' .. opt.width .. ';}" -l 0 -dmenu -p "'.. opt.prompt .. '"' .. opt.msg):read('*a'):gsub('\n', '')
end 

--[[
Shows the rofi input for a number. Input will be appear until it will get valid type.
Returns provided value.
optional arguments that can be passed
	prompt (string)
--]]
function rofiNumberInput(prompt)
	prompt = prompt and prompt or 'Enter number'
	local input
	repeat
		input = rofiInput({prompt = prompt, width = #prompt + 11 .. 'ch'})
	until tonumber(input)
	return input
end 

--[[
Shows a rofi menu. Returns string or table if multiple-select option was enabled. If custom keys were provided, it will return a keybind a second argument, otherwise 0. If nothing was selected it returns empty string and false for output and exit code.
params:
entriesTab - Options can be parser form an array (ordered table) or a dictionary.
opt - optional arguments that can be passed via table
	prompt (string)
	height (number)-  max lines than rofi can show; default: 24
	width (string)- It accepts width with unit. It accepts following units: 80px;80%;80ch
	multi (boolean)- If true, rofi will allow to select multiple rows, and it will return table with selected options
	keys (table) - Custom keys. Keys in table are keybindings, and values are descriptions for them. Example: keys = { ['Alt-p'] = 'popup', ['Alt-a'] = 'audio',}. If value is a table with function, it will extract description (it has to be in the first index) {['Alt-p'] = {'popup', function() return ..end },}
	msg (string) - Message information, accepts pango markup(html like). Msg should fit in one line otherwise it will show less entries, use width to adjust.
--]]
-- TODO default option for not existence and exit??
function rofiMenu(entriesTab, options)
	local opt, keys = combineOptions(copyt(options))
	local entries = ''
	local lines = 0
	local isArray = isArray(entriesTab)

	for key,val in pairs(entriesTab) do
		if isArray then
			entries = entries  .. val	.. '|'
		else
			entries = entries  .. key	.. '|'
		end
		lines = lines + 1
	end
	entries = entries:sub(1, #entries -1)
	if lines > opt.height then
		lines = opt.height
	end

	local _, selected, err, code= run('echo "' .. entries .. '" | rofi -monitor -4 -i ' .. opt.multi .. ' -l ' .. lines .. ' -sep "|" -dmenu -p "' .. opt.prompt .. '" -theme-str "window {width:  ' .. opt.width .. ';}" ' .. opt.keys .. opt.msg)

	-- rofi returns error code for hooks and returns error code for not selecting - it would be a rofi error
	if err and err ~= '' then
		notifyError(err)
		return '', false
	end
	-- only luajit returns different status code
	if code == 256 then
		return '', false
	end
	if next(keys) and code > 256 then
		code = code/256 - 9
		code = keys[code] 
	end
	if options and options.multi then
		if selected[#selected] == "" then
			selected[#selected] = nil
		end
		return selected, code
	else
		return selected[1], code
	end

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
	local date = '[' .. os.date '%Y-%m-%d %H:%M:%S' .. '] '
	local logPrefix = date .. '[' .. level .. '] '
	local log = ''

	if type(input) == 'table' then
		for i, l in ipairs(input) do
			log = log .. '\n'
		end
	else
		log = input
	end

	writef(logPrefix .. log, file, '\n', 'a+')
end -- >>>

-- >>>

-- luaSnip <<<
-- https://github.com/pocomane/luasnip/blob/master/documentation.adoc
-- IDK what lua version is supported
-- keysort <<<
--This function return the list of all the keys of the input inTab table. The keys are alphabetically sorted.
function keysort( inTab ) --> outArr
  local outArr = {}
  local nonstring = {}
  for k in pairs(inTab) do
    if type(k) == 'string' then
      outArr[1+#outArr] = k
    else
      local auxkey = tostring(k)
      nonstring[1+#nonstring] = auxkey
      nonstring[auxkey] = k
    end
  end
  table.sort(outArr)
  table.sort(nonstring)
  for _,v in ipairs(nonstring) do
    outArr[#outArr+1] = nonstring[v]
  end
  return outArr
end
-- >>>
-- jsonish <<<
--This function parses the json-like string jsonStr to the lua table dataTab. It does not perform any validation. The parser is not fully JSON compliant, however it is very simple and it should work in most the cases.
local function json_to_table_literal(s)

  s = s:gsub([[\\]],[[\u{5C}]])
  s = (' '..s):gsub('([^\\])(".-[^\\]")', function( prefix, quoted )
    -- Matched string: quoted, non empty

    quoted = quoted:gsub('\\"','\\u{22}')
    quoted = quoted:gsub('\\[uU](%x%x%x%x)', '\\u{%1}')
    quoted = quoted:gsub('%[','\\u{5B}')
    quoted = quoted:gsub('%]','\\u{5D}')
    return prefix .. quoted
  end)

  s = s:gsub('%[','{')
  s = s:gsub('%]','}')
  s = s:gsub('("[^"]-")%s*:','[%1]=')

  return s
end

function jsonish(s)
  local loader, e = load('return '..json_to_table_literal(s), 'jsondata', 't', {})
  if not loader or e then return nil, e end
  return loader()
end
-- >>>
-- jsonishout <<<
-- table to json
--jsonishout{{a=1},{1,"b"}} == '[{"a":1},[1,"b"]]'

local function quote_json_string(str)
  return '"'
    .. str:gsub('(["\\%c])',
      function(c)
        return string.format('\\x%02X', c:byte())
      end)
    .. '"'
end

local table_to_json

local function table_to_json_rec(result, t)

  if 'number' == type(t) then
    result[1+#result] = tostring(t)
    return
  end

  if 'table' ~= type(t) then
    result[1+#result] = quote_json_string(tostring(t))
    return
  end

  local isarray = false
  if not getmetatable(t) then
    local hasindex, haskey = false, false
    for _ in ipairs(t) do hasindex = true break end
    for _ in pairs(t) do haskey = true break end
    isarray = hasindex or not haskey
  end

  if isarray then
    result[1+#result] = '['
    local first = true
    for _,v in ipairs(t) do
      if not first then result[1+#result] = ',' end
      first = false
      table_to_json_rec(result, v)
    end
    result[1+#result] = ']'

  else
    result[1+#result] = '{'
    local first = true
    for k,v in pairs(t) do

      if 'number' ~= type(k) or 0 ~= math.fmod(k) then -- skip integer keys
        k = tostring(k)
        if not first then result[1+#result] = ',' end
        first = false

        -- Key
        result[1+#result] = quote_json_string(k)
        result[1+#result] = ':'

        -- Value
        table_to_json_rec(result, v)
      end
    end

    result[1+#result] = '}'
  end
end

jsonishout = function(t)
  local result = {}
  table_to_json_rec(result, t)
  return table.concat(result)
end
-- >>>

-- filenamesplit <<<
--Split a file path string filepathStr into the following strings: the folder path pathStr, filename nameStr and extension extStr.
--filenamesplit( filepathStr ) --> pathStr, nameStr, extStr
function filenamesplit( str ) --> pathStr, nameStr, extStr
  if not str then str = '' end

  local pathStr, rest = str:match('^(.*[/\\])(.-)$')
  if not pathStr then
    pathStr = ''
    rest = str
  end

  if not rest then return pathStr, '', '' end

  local nameStr, extStr = rest:match('^(.*)(%..-)$')
  if not nameStr then
    nameStr = rest
    extStr = ''
  end

  return pathStr, nameStr, extStr
end

-- >>>
-- cliparse <<<
--Simple function to parse command line arguments, that must be passed as the array of string arrArg.
-- each flag can have multiple values. Arguments are saved to args[''], but you can provide default key.
--local opt = cliparse{'-a','-b','c','-xy','d'} multiple flags
-- local opt = cliparse{'--aa','--bb','c','--dd','e','f'} -- long name flags
-- local opt = cliparse{'--aa=x','--bb:y','--cc=p','--cc=q','u'} values; value option can have space even in a quote

local function addvalue( p, k, value )
  local prev = p[k]
  if not prev then prev = {} end
  if 'table' ~= type(value) then
    prev[1+#prev] = value
  else
    for v = 1, #value do
      prev[1+#prev] = value[v]
    end
  end
  p[k] = prev
end

function cliparse( args, default_option )

  if not args then args = {} end
  if not default_option then default_option = '' end
  local result = {}

  local append = default_option
  for _, arg in ipairs(args) do
    if 'string' == type( arg ) then
      local done = false

      -- CLI: --key=value, --key:value, -key=value, -key:value
      if not done then
        local key, value = arg:match('^%-%-?([^-][^ \t\n\r=:]*)[=:]([^ \t\n\r]*)$')
        if key and value then
          done = true
          addvalue(result, key, value)
        end
      end

      -- CLI: --key
      if not done then
        local keyonly = arg:match('^%-%-([^-][^ \t\n\r=:]*)$')
        if keyonly then
          done = true
          if not result[keyonly] then
            addvalue(result, keyonly, {})
          end
          -- append = keyonly
        end
      end

      -- CLI: -kKj
      if not done then
        local flags = arg:match('^%-([^-][^ \t\n\r=:]*)$')
        if flags then
          done = true
          for i = 1, #flags do
            local key = flags:sub(i,i)
            addvalue(result, key, {})
          end
        end
      end

      -- CLI: value
      if not done then
        addvalue(result, append, arg)
        append = default_option
      end
    end
  end

  return result
end
-- >>>
-- >>>

-- vim: fmr=<<<,>>> fdm=marker
