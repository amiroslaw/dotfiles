-- any change requiers :PackerCompile
-- https://github.com/wbthomason/packer.nvim
return require('packer').startup(function()
	use 'ggandor/lightspeed.nvim'
	use { "anuvyklack/windows.nvim", -- Automatically resizes your windows
	   requires = "anuvyklack/middleclass",
	   config = function() require('windows').setup() end
	}
	use { 'mg979/vim-visual-multi', branch = 'master' }
	use 'tpope/vim-repeat'
	use 'chentoast/marks.nvim'
	use 'mhinz/vim-startify' -- start screen
	use { 'mbbill/undotree', cmd = { 'UndotreeToggle' } }
	use {
		'gbprod/yanky.nvim',
		config = function()
			require('yanky').setup {}
		end,
	}
	use 'voldikss/vim-browser-search'
	use 'kyazdani42/nvim-web-devicons'
	use { 'amiroslaw/fm-nvim', cmd = { 'Vifm', 'Broot', 'Fzf', 'Ranger', 'Lazygit', 'TaskWarriorTUI' } }
	use { 'folke/zen-mode.nvim', branch = 'main', cmd = { 'ZenMode' } }
	use 'nvim-lualine/lualine.nvim'
	use { 'akinsho/bufferline.nvim', branch = 'main' }
	use {
		'Pocco81/auto-save.nvim',
		branch = 'main',
		config = function()
			require('auto-save').setup { enabled = true, trigger_events = { 'InsertLeave' } }
		end,
	}
	use {
		'folke/which-key.nvim',
		config = function()
			require('which-key').setup {
				spelling = { enabled = true, sugesstions = 20, ignore_missing = true },
			}
		end,
	}
	use {
		'nvim-telescope/telescope.nvim',
		requires = {
			{ 'nvim-lua/popup.nvim', opt = true },
			{ 'fhill2/telescope-ultisnips.nvim' },
			{ 'crispgm/telescope-heading.nvim', lock = true }, -- I added asciidoc support
			{ 'nvim-lua/plenary.nvim' },
			{ 'amiroslaw/telescope-changes.nvim' },
			-- { 'gbprod/yanky.nvim'},
		},
	}
	use {
		'hrsh7th/nvim-cmp',
		requires = { -- https://github.com/topics/nvim-cmp list of the sources
			{ 'hrsh7th/nvim-cmp' },
			{ 'hrsh7th/cmp-buffer' },
			{ 'hrsh7th/cmp-path' },
			{ 'hrsh7th/cmp-calc' },
			{ 'hrsh7th/cmp-cmdline' },
			{ 'dmitmel/cmp-cmdline-history' },
			{ 'quangnguyen30192/cmp-nvim-ultisnips' },
			{ 'hrsh7th/cmp-nvim-lua' }, -- vim.api
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'uga-rosa/cmp-dictionary' },
			config = function()
				require('cmp-nvim-ultisnips').setup {}
			end,
		},
	}

	use 'SirVer/ultisnips'

	-- NOTE
	use 'amiroslaw/taskmaker.nvim'
	use { 'itchyny/calendar.vim', cmd = { 'Calendar' } } -- problem with api; maybe delete
	use { 'aserebryakov/vim-todo-lists' } -- , tag = '0.7.1'
	-- use 'dbeniamine/todo.txt-vim'
	use { 'kabbamine/lazyList.vim', cmd = { 'LazyList' } }
	use 'axieax/urlview.nvim'
	-- asciidoctor
	use { 'habamax/vim-asciidoctor', ft = { 'asciidoctor' } }
	-- markdown
	use { 'plasticboy/vim-markdown', ft = { 'markdown' } }
	use { 'previm/previm', ft = { 'markdown' } }
	use { 'godlygeek/tabular', cmd = {'Tab'}  } -- do wyrównywania np w tabelach http://vimcasts.org/episodes/aligning-text-with-tabular-vim/ :Tab /| ft = { 'markdown', 'asciidoctor' }
	use 'majutsushi/tagbar'
	-- CODE
	use { 'lewis6991/gitsigns.nvim' }
	use { 'kylechui/nvim-surround' }
	use { 'sbdchd/neoformat', cmd = { 'Neoformat' } }
	use { 'gennaro-tedesco/nvim-jqx', ft = { 'json' } }
	use {
		'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup()
		end,
	}
	use { 'abecodes/tabout.nvim', wants = { 'nvim-treesitter' }, after = { 'nvim-cmp' } } -- doesn't support asciidoc, jump
	use {
		'windwp/nvim-autopairs',
		config = function()
			require('nvim-autopairs').setup()
		end,
	}
	use { 'NTBBloodbath/rest.nvim', branch = 'main', ft = { 'http' }, requires = { 'nvim-lua/plenary.nvim' } } -- maybe delete
	use { 'jose-elias-alvarez/null-ls.nvim', branch = 'main', requires = { 'nvim-lua/plenary.nvim' } }
	use {
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate',
		config = function()
			require('nvim-treesitter.configs').setup {
				ensure_installed = {
					'java',
					'scala',
					'javascript',
					'typescript',
					'lua',
					'markdown',
					'http',
					'json',
					'css',
					'http',
					'kotlin',
					'scss',
					'toml',
					'yaml',
					'bash',
				}, -- TSInstall css html "asciidoc"
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
			}
		end,
	}
	-- COLORSCHEMES and Syntax
	use 'baskerville/vim-sxhkdrc'
	use 'rafi/awesome-vim-colorschemes' -- https://vimcolorschemes.com/rafi/awesome-vim-colorschemes
	use { 'dracula/vim', as = 'dracula' }
	use 'bluz71/vim-moonfly-colors'
end)
