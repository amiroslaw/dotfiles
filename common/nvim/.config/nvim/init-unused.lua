
	use {
		'numToStr/Comment.nvim',
		tag = 'v0.6', -- TODO update in 0.7
		config = function()
			require('Comment').setup()
		end,
	}
	-- use {'habamax/vim-asciidoctor', ft = {'asciidoctor', 'asciidoc', 'adoc'}}
-- use { 'goolord/alpha-nvim', config = function () require'alpha'.setup(require'alpha.themes.startify'.opts) end } -- dont know how to opening multiple files
-- use 'vim-scripts/YankRing.vim' -- fix keybinding
use {
	'glacambre/firenvim',
	run = function()
		vim.fn['firenvim#install'](0)
	end,
}
-- use { "folke/which-key.nvim", config = function() require("which-key").setup { } end }


-- -------------------------------------------------------------------------
--                       -- firevim
-- https://github.com/glacambre/firenvim
-- -------------------------------------------------------------------------
function IsFirenvimActive(event)
	if vim.g.enable_vim_debug then
		print('IsFirenvimActive, event: ', vim.inspect(event))
	end
	if vim.fn.exists '*nvim_get_chan_info' == 0 then
		return 0
	end
	local ui = vim.api.nvim_get_chan_info(event.chan)
	if vim.g.enable_vim_debug then
		print('IsFirenvimActive, ui: ', vim.inspect(ui))
	end
	local is_firenvim_active_in_browser = (ui['client'] ~= nil and ui['client']['name'] ~= nil)
	if vim.g.enable_vim_debug then
		print('is_firenvim_active_in_browser: ', is_firenvim_active_in_browser)
	end
	return is_firenvim_active_in_browser
end

function OnUIEnter(event)
	if IsFirenvimActive(event) then
		vim.opt.laststatus = 0 -- Disable the status bar
		vim.opt.lines = 15
		vim.opt.columns = 100
		-- vim.cmd 'set guifont=SauceCodePro\\ Nerd\\ Font:h18' -- Increase the font size
	end
end

vim.g.firenvim_config = {
	globalSettings = {
		ignoreKeys = { all = { '<C-w>', '<C-n>' } },
	},
	localSettings = {
		[ [[.*]] ] = {
			cmdline = 'firenvim',
			priority = 0,
			selector = 'textarea:not([readonly]):not([class="handsontableInput"]), div[role="textbox"]',
			takeover = 'always',
		},
		[ [[^https?://[^/]*youtu\.?be[^/]*/]] ] = {
			selector = '#contenteditable-root',
		},
		[ [[.*mail\.google\.com*]] ] = {
			prioirty = 9,
			takeover = 'never',
		},
		[ [[.*docs\.google\.com.*]] ] = {
			prioirty = 9,
			takeover = 'never',
		},
		[ [[.*facebook\.com*]] ] = {
			prioirty = 9,
			takeover = 'never',
		},
		[ [[.*deepl\.com*]] ] = {
			prioirty = 9,
			takeover = 'never',
		},
	},
}

vim.cmd [[ autocmd UIEnter * :call luaeval('OnUIEnter(vim.fn.deepcopy(vim.v.event))') ]]
