-- https://github.com/folke/lazy.nvim
return {
	--{{{ Productive
	{ 'anuvyklack/windows.nvim', -- Automatically resizes your windows
		dependencies = 'anuvyklack/middleclass',
		config = true,
	},
	{ 'mg979/vim-visual-multi', branch = 'master' },
	'tpope/vim-repeat',
	'chentoast/marks.nvim',
	'mhinz/vim-startify', -- start screen
	{ 'mbbill/undotree', cmd = { 'UndotreeToggle' } },
	{ 'gbprod/yanky.nvim', config = true },
	{ 'lalitmee/browse.nvim', dependencies = { 'nvim-telescope/telescope.nvim' } },
	{ 'amiroslaw/fm-nvim', cmd = { 'Vifm', 'Broot', 'Fzf', 'Ranger', 'Lazygit', 'TaskWarriorTUI' } },
	{ 'okuuva/auto-save.nvim',
		cmd = 'ASToggle', -- optional for lazy loading on command
		event = { 'InsertLeave', 'TextChanged' }, -- optional for lazy loading on trigger events
		opts = { trigger_events = { 'InsertLeave' } }
	},
	{ 'folke/which-key.nvim',
		event = 'VeryLazy',
		opts = { spelling = { enabled = true, sugesstions = 20, ignore_missing = true }, },
	},
	'liangxianzhe/nap.nvim', -- jumps between buffer, tab, file, quickfix
	'ggandor/lightspeed.nvim',
	{ 'nvim-telescope/telescope.nvim',
		cmd = 'Telescope',
		dependencies = {
			{ 'nvim-lua/popup.nvim', lazy = true },
			{ 'fhill2/telescope-ultisnips.nvim' },
			{ 'crispgm/telescope-heading.nvim', pin = true }, -- I added asciidoc support
			{ 'nvim-lua/plenary.nvim' },
			{ 'amiroslaw/telescope-changes.nvim' },
			-- { 'gbprod/yanky.nvim'},
		},
	},
	{ 'danielfalk/smart-open.nvim', branch = '0.2.x', dependencies = { 'kkharji/sqlite.lua' } },
	--}}}

	--{{{ Note
	{ 'uga-rosa/translate.nvim', cmd = { 'Translate' } },
	{ 'rhysd/vim-grammarous', cmd = { 'GrammarousCheck' } },
	{ 'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = { -- https://github.com/topics/nvim-cmp list of the sources
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
			-- { 'amarakon/nvim-cmp-buffer-lines' },
			config = function()
				require('cmp-nvim-ultisnips').setup {}
			end,
		},
	},
	'SirVer/ultisnips',
	{ 'itchyny/calendar.vim', cmd = 'Calendar' }, -- problem with api; maybe delete
	{ 'amiroslaw/taskmaker.nvim', cmd = { 'TaskmakerAddTasks', 'TaskmakerToggle' } },
	'aserebryakov/vim-todo-lists', -- , version = '0.7.1'
	-- 'dbeniamine/todo.txt-vim',
	{ 'kabbamine/lazyList.vim', cmd = 'LazyList' },
	{ 'axieax/urlview.nvim',
		opts = {
			default_picker = 'telescope', -- native,
			sorted = false,
		},
		cmd = 'UrlView',
	},

	-- asciidoctor
	{ 'habamax/vim-asciidoctor' }, -- ft = { 'asciidoctor' } }, -- doesn't work with lazy
	-- markdown
	{ 'plasticboy/vim-markdown', ft = { 'markdown' } },
	{ 'previm/previm', ft = { 'markdown' } },
	{ 'godlygeek/tabular', cmd = { 'Tab' } }, -- do wyrównywania np w tabelach http://vimcasts.org/episodes/aligning-text-with-tabular-vim/ :Tab /| ft = { 'markdown', 'asciidoctor' }
	{ 'majutsushi/tagbar', cmd = 'TagbarToggle' },
	--}}}

	--{{{ Code
	{ 'lewis6991/gitsigns.nvim', event = { 'BufReadPre', 'BufNewFile' } },
	'kylechui/nvim-surround',
	{ 'sbdchd/neoformat', cmd = { 'Neoformat' } },
	{ 'gennaro-tedesco/nvim-jqx', ft = { 'json' } },
	{ 'numToStr/Comment.nvim', event = { 'BufReadPost', 'BufNewFile' }, config = true },
	-- test after and wants
	-- { 'abecodes/tabout.nvim', dependencies = { 'nvim-treesitter', 'nvim-cmp' }, event = 'InsertEnter' }, -- doesn't support asciidoc
	{ 'windwp/nvim-autopairs', config = true },
	{ 'NTBBloodbath/rest.nvim', branch = 'main', ft = { 'http' }, dependencies = { 'nvim-lua/plenary.nvim' } }, -- maybe delete
	{ 'jose-elias-alvarez/null-ls.nvim', branch = 'main', dependencies = { 'nvim-lua/plenary.nvim' } },
	{ 'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			require('nvim-treesitter.configs').setup {
				ensure_installed = {
					'java',
					'scala',
					'kotlin',
					'javascript',
					'typescript',
					'lua',
					'markdown',
					'http',
					'json',
					'css',
					'html',
					'scss',
					'toml',
					'yaml',
					'bash',
					'http',
					'python',
				}, -- TSInstall css html; "asciidoc" doesn't support yet
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
			}
		end,
	},
	--}}}

	--{{{ UI
	{ 'kyazdani42/nvim-web-devicons', lazy = true },
	{ 'folke/zen-mode.nvim',
		branch = 'main',
		cmd = { 'ZenMode' },
		opts = {
			window = { width = 0.80 },
			plugins = { wezterm = { enabled = true, font = '+1' } },
		},
	},
	{ 'alvarosevilla95/luatab.nvim', dependencies = 'kyazdani42/nvim-web-devicons', config = true, event = 'VeryLazy' }, -- tabline
	{ 'nvim-lualine/lualine.nvim', event = 'VeryLazy' },
	--}}}
	--{{{ COLORSCHEMES and Syntax
	'baskerville/vim-sxhkdrc',
	'rafi/awesome-vim-colorschemes', -- https://vimcolorschemes.com/rafi/awesome-vim-colorschemes
	-- not used
	{ 'dracula/vim', lazy = false, priority = 1000, name = 'dracula', enabled = false },
	{ 'bluz71/vim-moonfly-colors', lazy = false, priority = 1000, enabled = false },
	--}}}
}
-- vim: foldmethod=marker
