#!/usr/bin/luajit
local SETUP_PATH = os.getenv 'SETUP'
local setup = readf(SETUP_PATH)

if arg[1] then
	local entry = rofiInput { prompt = 'Setup', width = '40%' }

	file = io.open(SETUP_PATH, 'a+')
	file:write('\n' .. entry)
	file:close()
else
	local mutlipleDefault = 3
	local profit = 0
	local wonCount = 0
	local lossCount = 0
	local sum = 0
	for _, line in ipairs(setup) do
		local matchWon = line:match 'won'
		local matchLoss = line:match 'loss'
		if matchWon or matchLoss then
			local price = line:match '%d+'
			sum = sum + price
			local multiple = mutlipleDefault
			local matchMultiple = line:match '%d+r'
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
	print(string.format('ratio: %.0f', wonCount / lossCount * 100) .. '%')
	print('orders: ' .. #setup)
end