#!/usr/bin/luajit

local setup = readf(os.getenv('SETUP'))

local mutlipleDefault = 3
local profit = 0
local wonCount = 0
local lossCount = 0
local sum = 0
for _,line in ipairs(setup) do
	local matchWon = line:match('won')
	local matchLoss = line:match('loss')
	if matchWon or matchLoss then
		local price = line:match('%d+')
		sum = sum + price
		local multiple =  mutlipleDefault
		local matchMultiple = line:match('%d+r')
		if matchMultiple then
			multiple = matchMultiple:gsub('r', '')	
		end
		if matchWon then
			profit = profit + price * multiple
			wonCount = wonCount + 1
		else
			profit = profit - price
			lossCount = lossCount + 1
		end
	end
end
print('profit: ' .. profit)
print(string.format('ratio: %.0f', wonCount/lossCount *100) .. '%')
print('orders: ' .. #setup)
