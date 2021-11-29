-- any change requiers :PackerCompile 
-- https://github.com/wbthomason/packer.nvim
return require('packer').startup(
function()
	use {'Pocco81/AutoSave.nvim', branch = 'main', 
		config = function()
			require('autosave').setup({ enabled = true, events = {"InsertLeave"} })
		 end
	 }
	use 'justincampbell/vim-eighties' -- Automatically resizes your windows
	use {'mg979/vim-visual-multi', branch = 'master'}
	use 'tpope/vim-repeat'
	use 'MattesGroeger/vim-bookmarks'
	use 'majutsushi/tagbar'
	use 'mhinz/vim-startify' -- start screen
	use {'mbbill/undotree', cmd = {'UndotreeToggle' }}
	-- use 'vim-scripts/YankRing.vim' -- fix keybinding
	use 'bfredl/nvim-miniyank'
	-- CODE
	use 'tpope/vim-surround'
	use {'sbdchd/neoformat', cmd = {'Neoformat'}}
	use {'dense-analysis/ale', cmd = {'ALELint'}}

	-- NOTE
	use {'itchyny/calendar.vim', cmd = {'Calendar'}} -- problem with api
	use {'aserebryakov/vim-todo-lists', tag = '0.7.1'}
	use {'kabbamine/lazyList.vim', cmd = {'LazyList'}}
	-- asciidoctor
	-- use {'habamax/vim-asciidoctor', ft = {'asciidoctor', 'asciidoc', 'adoc'}}
	use {'habamax/vim-asciidoctor', ft = {'asciidoctor'}}
	-- markdown 
	use {'plasticboy/vim-markdown', ft = {'markdown'}}
	use {'previm/previm',  ft = {'markdown'}}
	use {'godlygeek/tabular',  ft = {'markdown'}} -- do wyrównywania np w tabelach http://vimcasts.org/episodes/aligning-text-with-tabular-vim/ :Tab /|
	--Syntax
	use 'baskerville/vim-sxhkdrc'

	-- for neovim and lua
	use {'gennaro-tedesco/nvim-jqx',  ft = {'json'}}
	use { 'kyazdani42/nvim-tree.lua',
		cmd = {'NvimTreeToggle'},
		requires = {{'kyazdani42/nvim-web-devicons', opt = true}},
		config = function() require'nvim-tree'.setup{} end
	}
	use {'b3nj5m1n/kommentary', branch= 'main'}
	use {'windwp/nvim-autopairs', config = function() require('nvim-autopairs').setup() end}
	use {'NTBBloodbath/rest.nvim', branch= 'main', ft= {'http'}, 
		requires = { "nvim-lua/plenary.nvim" }
	}

	use {
	  'phaazon/hop.nvim',
	  branch = 'v1', -- optional but strongly recommended
	  config = function() require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' } end
	}
    use { "hrsh7th/nvim-cmp",
      requires = { -- https://github.com/topics/nvim-cmp list of the sources
        { "hrsh7th/nvim-cmp" },
        { "hrsh7th/cmp-buffer" }, 
		{ "hrsh7th/cmp-path" },
        { "hrsh7th/cmp-calc" },
		{'dmitmel/cmp-cmdline-history'},
		{  "quangnguyen30192/cmp-nvim-ultisnips"},
        { "hrsh7th/cmp-nvim-lua" }, -- vim.api 
		{ "hrsh7th/cmp-nvim-lsp" }, 
        -- { "f3fora/cmp-spell" },
        -- { "hrsh7th/cmp-cmdline" },
      }
    }

	use 'SirVer/ultisnips'
	use {'folke/zen-mode.nvim', branch= 'main',  cmd = {'ZenMode'}}
	use {'nvim-telescope/telescope.nvim', 
		requires = {{'nvim-lua/popup.nvim', opt = true}, 
		{'tom-anders/telescope-vim-bookmarks.nvim'}, 
		{'fhill2/telescope-ultisnips.nvim'},
		{'crispgm/telescope-heading.nvim'},
		{'nvim-lua/plenary.nvim', opt = true}}
	}

	use { 'nvim-lualine/lualine.nvim',
		requires = {'kyazdani42/nvim-web-devicons', opt = true}, 
	}
	use { 'kdheepak/tabline.nvim',
		requires = {'hoob3rt/lualine.nvim', 'kyazdani42/nvim-web-devicons'}
	}
	-- COLORSCHEMES
	-- https://www.dunebook.com/best-vim-themes/
	-- https://vimcolorschemes.com/top
	-- ayu, vim-one, one-half, drakula NeoSolarized, pepertheme
	use {'dracula/vim', as = 'dracula' }
	use 'https://github.com/rakr/vim-one'
	-- use 'iCyMind/NeoSolarized'
	-- use 'patstockwell/vim-monokai-tasty'

end
)

