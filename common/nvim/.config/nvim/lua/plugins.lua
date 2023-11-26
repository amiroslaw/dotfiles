-- https://github.com/folke/lazy.nvim
return {
	--{{{ Productive
	{ 'anuvyklack/windows.nvim', -- Automatically resizes your windows
		dependencies = 'anuvyklack/middleclass',
		config = true,
		event = 'VeryLazy',
	},
	{ 'mg979/vim-visual-multi', branch = 'master' },
	{ "tpope/vim-repeat", event = "VeryLazy" },
	'chentoast/marks.nvim',
	'mhinz/vim-startify', -- start screen
	{ 'mbbill/undotree', cmd = { 'UndotreeToggle' } },
	{ 'gbprod/yanky.nvim', config = true },
	{ 'lalitmee/browse.nvim',event = 'VeryLazy', dependencies = { 'nvim-telescope/telescope.nvim' } },
	{ 'amiroslaw/fm-nvim', cmd = { 'Vifm', 'Broot', 'Fzf', 'Ranger', 'Lazygit', 'TaskWarriorTUI' },
		opts = { app = 'taskwarrior', -- {'taskwarrior', 'todo.txt'}
				feedback = true,
				sync = true,
			}
	},
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
	{ "folke/flash.nvim",
	  event = "VeryLazy",
	  opts = {
		  search = {
			mode = function(str) -- only match at the beginning of a word
			  return "\\<" .. str
			end,
		  },
		modes = { 
			char = { jump_labels = true, -- for actions d/y
			keys = { "f", "F", ";", "," }, -- removed t and T
			}
		  }
	  },
	  keys = {
		{ "s", mode = { "n", "o", "x" }, function() require("flash").jump() end, desc = "Flash" },
		{ "<s-a-d>", mode = { "n", "o", "x" }, function() require("flash").jump({ pattern = vim.fn.expand("<cword>") }) end, desc = "Under cursor" },
		{ "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
		{ "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
		{ "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
		{ "<a-f>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
		{ "<a-g>", mode = { "n", "o", "x" }, function() require("flash").jump( { 
			  search = { mode = "search", max_length = 0 },
			  label = { after = { 0, 0 } },
			  pattern = "^"
			}) end, desc = "Jump line" },
	  },
	},
	{ 'nvim-telescope/telescope.nvim',
		cmd = 'Telescope',
		dependencies = {
			{ 'nvim-lua/popup.nvim', lazy = true },
			-- { 'fhill2/telescope-ultisnips.nvim' },
			{ 'crispgm/telescope-heading.nvim' },
			{ 'nvim-lua/plenary.nvim' },
			{ 'amiroslaw/telescope-jumps.nvim' },
			{ "benfowler/telescope-luasnip.nvim",   module = "telescope._extensions.luasnip",}, 
			-- { 'gbprod/yanky.nvim'},
		},
	},
	{ 'nvim-telescope/telescope-fzf-native.nvim', 
		build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
		dependencies = 'nvim-telescope/telescope.nvim',
	},
	{ 'danielfalk/smart-open.nvim', branch = '0.2.x', dependencies = { 'kkharji/sqlite.lua' } },
	{ "chrisgrieser/nvim-origami",
		event = "BufReadPost", 
		opts = true,
	},
	{ "huynle/ogpt.nvim",
		event = "VeryLazy",
		opts = {
			actions_paths = { '~/.config/nvim/custom/ogpt-actions.json'}
		},
		dependencies = {
		  "MunifTanjim/nui.nvim",
		  "nvim-lua/plenary.nvim",
		  "nvim-telescope/telescope.nvim"
		}
	},
	--}}}

	--{{{ Note
	{ 'uga-rosa/translate.nvim', cmd = { 'Translate' }, opts = {
			default = { output = 'insert', -- split, floating, insert, replace, register
					lang_abbr = { pl = "polish", },
					end_marks = { polish = { ".", "?", "!", }, },
			},
		}
	},
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
			{ 'hrsh7th/cmp-nvim-lua' }, -- vim.api
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'uga-rosa/cmp-dictionary' },
			{ 'saadparwaiz1/cmp_luasnip' },
			-- { 'amarakon/nvim-cmp-buffer-lines' },
		},
	},
	{ "L3MON4D3/LuaSnip",
		version = "2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		event = 'InsertEnter', 
		-- install jsregexp (optional!).
		-- build = "make install_jsregexp"
		-- dependencies = 'honza/vim-snippets',  -- remove if can't exclude
		config = function() 
		require('luasnip.loaders.from_snipmate').lazy_load({ 
			-- include = { 'all', 'java', 'kotlin', 'lua', 'md', 'asciidoctor' }, -- need to include even for custom
			path = { "./snippets" } -- doesn't work
		})
		require('luasnip.loaders.from_lua').lazy_load({ })
		-- custom envs
		local function select() return vim.fn.getreg('*', 1, true) end
		local function clipboard() return vim.fn.getreg('+', 1, true) end
		require('luasnip').env_namespace("CLIP", { vars = { CLIP = clipboard, SELECT = select } })
		require('luasnip').config.setup({ 
			update_events = 'TextChanged,TextChangedI',
			history = true, -- keep around last sniiiet local to jump back
			enable_autosnippets = true,
			store_selection_keys = "<Tab>",
			ext_opts = {
				[require("luasnip.util.types").choiceNode] = {
					active = { virt_text = { { "🟢", "GruvboxOrange" } } }
					},
				[require("luasnip.util.types").insertNode] = {
					active = { virt_text = { { "✏️", "GruvboxOrange" } } }
					}}
			})
		end
	},
	{ 'itchyny/calendar.vim', cmd = 'Calendar' }, -- problem with api; maybe delete
	{ 'amiroslaw/taskmaker.nvim', cmd = { 'TaskmakerAddTasks', 'TaskmakerToggle' } },
	-- 'aserebryakov/vim-todo-lists', -- , version = '0.7.1'
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
	{ "roobert/surround-ui.nvim",
		dependencies = { "kylechui/nvim-surround", "folke/which-key.nvim", },
		opts = { root_key = "S" }, -- leader S
	},
	{ "sustech-data/wildfire.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts =  { filetype_exclude = { "qf", 'asciidoctor' }, } -- exclude unil treesitter will support asciidoc
	},
	{ 'sbdchd/neoformat', cmd = { 'Neoformat' } },
	{ 'gennaro-tedesco/nvim-jqx', ft = { 'json' } },
	{ 'numToStr/Comment.nvim', event = { 'BufReadPost', 'BufNewFile' }, config = true },
	{ 'windwp/nvim-autopairs', event = 'InsertEnter', config = true },
	{ 'jose-elias-alvarez/null-ls.nvim', branch = 'main', dependencies = { 'nvim-lua/plenary.nvim' } },
	{ 'NTBBloodbath/rest.nvim', branch = 'main', ft = { 'http' }, dependencies = { 'nvim-lua/plenary.nvim' } }, -- maybe delete
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
					'vim',
					'dockerfile',
				}, -- TSInstall css html; "asciidoc" doesn't support yet
				auto_install = true,
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
	{ 'nvim-lualine/lualine.nvim', event = 'VeryLazy',
		config = function()
			local function line_total()
				return tostring(vim.api.nvim_buf_line_count(vim.fn.winbufnr( vim.g.statusline_winid))) 
			end
			local spellang = function ()
				if vim.opt.spell:get() ~= true then return '[]' end
				local lang = table.concat(vim.opt_local.spelllang:get(), '/')
				return lang == '' and '--' or lang
			end
			local permissions = function ()
				local the_file = vim.fn.expand('%:p')
				local rw = vim.opt_local.readonly:get() == true and 'r' or 'rw'
				local x = vim.fn.executable(the_file) == 1 and 'x' or ''
				local m = vim.api.nvim_buf_get_option(0, 'modified') == true and '+' or ''
				return the_file == '' and '[]'..m or rw..x..m
			end
			require'lualine'.setup {
			 options = { theme = 'dracula', component_separators = '|', globalstatus = true }, 
			 sections = {
				lualine_x = {'selectioncount', 'searchcount'}, -- redundant
				lualine_y = {spellang, permissions, 'filetype'},
				 lualine_z = {line_total, 'progress', 'location'}}
		 }
		-- opts = { options = { theme = 'dracula', component_separators = '|', globalstatus = true }, -- sections = {lualine_a = {'buffers'}} - takes too much space
	-- }
	end },
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
