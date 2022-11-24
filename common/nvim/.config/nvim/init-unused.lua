
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


	use {
		'phaazon/hop.nvim',
		branch = 'v1', -- optional but strongly recommended
		config = function()
			require('hop').setup { keys = 'etovxqpdygfblzhckisuran' }
		end,
	}

--""""""""""""""""""
-- hop, easymotion alternative
-- https://github.com/phaazon/hop.nvim
nmap('F', '<cmd>HopChar1 <cr>')
nmap('f', '<cmd>HopChar2 <cr>')
nmap('<leader>w', '<cmd>HopWordAC <cr>')
nmap('<leader>W', '<cmd>HopWordBC <cr>')
nmap('s', '<cmd>HopLineStartAC <cr>')
nmap('S', '<cmd>HopLineStartBC <cr>')
omap('F', '<cmd>HopChar1 <cr>')
omap('f', '<cmd>HopChar2 <cr>')
omap('<leader>w', '<cmd>HopWordAC <cr>')
omap('<leader>W', '<cmd>HopWordBC <cr>')
omap('s', '<cmd>HopLineStartAC <cr>')
omap('S', '<cmd>HopLineStartBC <cr>')


--""""""""""""""""""
-- vim-bookmarks
vim.g.bookmark_auto_close = 1
vim.g.bookmark_display_annotation = 1
vim.g.bookmark_auto_save_file = HOME .. '/.local/share/nvim/vim-bookmarks'
vim.g.bookmark_show_toggle_warning = 0

telescope
{ 'tom-anders/telescope-vim-bookmarks.nvim' },
use 'MattesGroeger/vim-bookmarks'

	telescope.load_extension 'vim_bookmarks'
	nmap('tm', '<cmd>Telescope vim_bookmarks current_file <cr>')
	nmap('tM', '<cmd>Telescope vim_bookmarks all <cr>')

-- -------------------------------------------------------------------------
--                       colorschemes
-- -------------------------------------------------------------------------

	use {'rakr/vim-one', as = 'one'}
	use 'iCyMind/NeoSolarized'
	use 'patstockwell/vim-monokai-tasty'
use 'ayu-theme/ayu-vim'
use 'navarasu/onedark.nvim'
vim.cmd 'colorscheme dracula'
vim.cmd 'colorscheme moonfly'
require('onedark').setup {
	style = 'deep',
	colors = { -- https://github.com/navarasu/onedark.nvim/blob/master/lua/lualine/themes/onedark.lua
		fg = '#fffffe',
	},
}
require('onedark').load()

-- let g:one_allow_italics = 1 

use { 'kdheepak/lazygit.nvim', branch = 'main', cmd = { 'LazyGit' } }

-- NvimTreeToggle {{{
--  https://github.com/kyazdani42/nvim-tree.lua
	use {
		'kyazdani42/nvim-tree.lua',
		cmd = { 'NvimTreeToggle' },
		config = function()
			require('nvim-tree').setup {}
		end,
	}
nmap('<F3>', ':NvimTreeToggle<CR>')
nmap('<leader>n', ':NvimTreeToggle<CR>') -- }}} 


use 'bfredl/nvim-miniyank'
-- miniyank {{{
-- https://github.com/bfredl/nvim-miniyank
vim.g.miniyank_filename = HOME .. '/.local/share/nvim/miniyank.mpack'
nmap('p', '<Plug>(miniyank-autoput)', { noremap = false })
nmap('<A-n>', '<Plug>(miniyank-cycle)', { noremap = false })
nmap('<A-p>', '<Plug>(miniyank-cycleback)', { noremap = false }) -- }}} 


use 'justincampbell/vim-eighties' 
-- eighties automatyczne dostosowanie okien {{{
vim.g.eighties_enabled = 1
vim.g.eighties_minimum_width = 80
vim.g.eighties_extra_width = 0 -- Increase this if you want some extra room
vim.g.eighties_compute = 1 -- Disable this if you just want the minimum + extra
vim.g.eighties_bufname_additional_patterns = { 'fugitiveblame' } -- Defaults to [], 'fugitiveblame' is only an example. Takes a comma delimited list of bufnames as strings. -- }}} 


-- cmp plugin buffer-lines
-- nie działał w lua i nie mogłem wyłączyć go dla adoc
		{ name = "buffer-lines", keyword_length = 4, },
-- Only enable `buffer-lines` for filetypes
cmp.setup.filetype({ "lua", "java", "bash", "css", "html", "javascript", "typescript" }, {
    sources = {
        { name = "buffer-lines" }
    }
})

-- -------------------------------------------------------------------------
--                       https://github.com/cbochs/portal.nvim[GitHub - cbochs/portal.nvim: Neovim plugin for improved jumplist navigation]
-- -------------------------------------------------------------------------

use {
    "cbochs/portal.nvim",
    config = function()
        require("portal").setup({
		query = { "modified", "valid" },
		-- query = { "modified", "different", "valid" },
        })
    end,
}
vim.keymap.set("n", "<LocalLeader>o", require("portal").jump_backward, {})
vim.keymap.set("n", "<LocalLeader>i", require("portal").jump_forward, {})

