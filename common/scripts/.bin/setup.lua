#!/usr/bin/luajit
local SETUP_PATH = os.getenv 'SETUP'

-- add transaction 
if arg[1] then
	local assets = M(M.tabulate(io.lines(SETUP_PATH)))
		:map(M.fun.match('^===%s%w+/?%w+'))
		:values():value()

	local selectedAsset, code = rofiMenu(assets, {prompt = 'select asset', width = '25ch'})
	assert(code, 'select asset')

	local entry = rofiInput { prompt = 'Setup', width = '40%' }
	entry = entry .. ' ' .. os.date('%Y/%m/%d_%H:%M')
	selectedAsset = selectedAsset[1]:gsub('/', '\\/')
	print('sed -i "/^'.. selectedAsset .. '/a '.. entry .. '" ' .. SETUP_PATH)
	local  out, ok, err = run('sed -i "/^'.. selectedAsset .. '/a '.. entry .. '" ' .. SETUP_PATH, "Can't write setup")
	if ok then
		notify('added: ' .. entry)
	else
		notifyError(err)
	end
	return
end

-- calculate profit

-- for _, line in ipairs(setup) do
-- 	local matchWon = line:match 'won'
-- 	local matchLoss = line:match 'loss'
-- 	if matchWon or matchLoss then
-- 		local price = line:match '%d+'
-- 		local multiple = mutlipleDefault
-- 		local matchMultiple = line:match '%d+r'
-- 		if matchMultiple then
-- 			multiple = matchMultiple:gsub('r', '')
-- 		end
-- 		if matchWon then
-- 			profit = profit + price * multiple
-- 			wonCount = wonCount + 1
-- 		else
-- 			profit = profit - price
-- 			lossCount = lossCount + 1
-- 		end
-- 	end
-- end
-- local profit = 0
-- local wonCount = 0
-- local lossCount = 0

local mutlipleDefault = 3

local type = enum({ WON ='won' , LOSS = 'loss' })

local function toPrice(line, operation)
	local price = line:match '%d+'
	if type.WON == operation then
		local multiple = mutlipleDefault
		local matchMultiple = line:match '%d+r'
		if matchMultiple then
			multiple = matchMultiple:gsub('r', '')
		end
		return price * multiple
	else
		return price
	end
end

local function calculateProfit(transactions, type)
	local chain = M(transactions[type]):map(M.bind2(toPrice, type))
	local count  = chain:count():value()
	local profit =  chain:reduce(M.operator.add):value()
	return profit, count
end

local wonAndLoss = M(M.tabulate(io.lines(SETUP_PATH)))
	:groupBy(function(line) return
				line:match 'won' and 'won' or 
				line:match 'loss' and 'loss' or 'irrelevant'
				end):value()


lossProfit, lossCount = calculateProfit(wonAndLoss, type.LOSS)
wonProfit, wonCount = calculateProfit(wonAndLoss, type.WON)

print('profit: ' .. wonProfit - lossProfit)
print(string.format('ratio: %.0f', wonCount / lossCount * 100) .. '%', wonCount .. '/' ..lossCount)
print('orders: ' .. wonCount + lossCount)
