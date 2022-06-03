require 'plugins'

-- S-k - jump to help page
local HOME = os.getenv 'HOME'
--"""""""""""""""""""""""""

-- COLORSCHEMES
--let scheme = strftime("%H") > 5 && strftime("%H") < 18 ? "one" : "dracula"
--execute 'colorscheme ' . scheme
--let &background =strftime("%H") > 5 && strftime("%H") < 18 ? "light" : "dark"
-- vim.cmd 'colorscheme dracula'
-- vim.cmd 'colorscheme moonfly'
-- Lua
require('onedark').setup {
    style = 'deep',
  colors = { -- https://github.com/navarasu/onedark.nvim/blob/master/lua/lualine/themes/onedark.lua
    fg = "#fffffe",
  },
}
require('onedark').load()
-- vime-one - support dark and light theme
-- vim.cmd("set background=light")
-- let g:one_allow_italics = 1

--"""""""""""""""""""""""""
--""""" SETTINGS

-- if vim.fn.has 'termguicolors' == 1 then
vim.o.termguicolors = true
-- end
vim.b.buftype = '' -- fix Cannot write buftype option is set
vim.o.laststatus = 3
-- podpowiedzi
vim.o.wildmode = 'longest,list,full'
--" Status bar
vim.cmd 'filetype plugin indent on'
vim.o.encoding = 'utf-8'
vim.o.fileencoding = 'utf-8'
vim.o.fileencodings = 'utf-8', 'latin1'
vim.o.linebreak = true
vim.cmd 'syntax enable'
vim.o.foldlevelstart = 9 -- unfold at start - don't work after changes

-- -------------------------------------------------------------------------
--                       Autocommands
-- -------------------------------------------------------------------------
vim.api.nvim_create_autocmd( -- go to last loc when opening a buffe
	"BufReadPost",
    { command = [[if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]] })
vim.api.nvim_create_autocmd(
	"FileType", {
	pattern = {'lua','java','javascript','typescript','css','scss'},
	command = [[setlocal foldmethod=syntax]] 
	})
vim.api.nvim_create_autocmd(
	"FileType", {
	pattern = {'asciidoc'},
	command = [[setlocal foldmethod=expr]] 
	})
vim.api.nvim_create_autocmd(
	{"BufRead","BufNewFile"}, {
	pattern = {'*.json'},
	command = [[set filetype=json]] 
	})
vim.api.nvim_create_autocmd(
	{"BufRead","BufNewFile"}, {
	pattern = {'/tmp/*'},
	command = [[set filetype=text]] 
	})
vim.api.nvim_create_autocmd(
	{"BufRead","BufNewFile"}, {
	pattern = {'*.{md,mdwn,mkd,mkdn,mark,markdown}'},
	command = [[set filetype=markdown]] 
	})
vim.api.nvim_create_autocmd( -- Prefer Neovim terminal insert mode to normal mode. IDK if it's default mode
	"BufEnter", {
	pattern = {'term://*'},
	command = [[startinsert]]
	})
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = {'plugins.lua'},
	command = "source <afile> | PackerCompile",
	group = vim.api.nvim_create_augroup("packerCompile", { clear = true }) -- clear true is default
})
vim.api.nvim_create_autocmd("TextYankPost", {
  command = "silent! lua vim.highlight.on_yank {timeout=600}",
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }) -- clear true is default
})
-- doesn't work with keybinding in zsh
	-- autocmd BufDelete * if len(filter(range(1, bufnr('$')), '! empty(bufname(v:val)) && buflisted(v:val)')) == 1 | quit | endif

-- IncSearch
vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.number = true
-- substitution
--
vim.o.inccommand = 'split'
vim.o.clipboard = 'unnamedplus'
--vim.o.clipboard^='unnamedplus'
--vim.opt.clipboard:append('unnamedplus')

vim.o.smartindent = true
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.o.scrolloff = 5 -- margin
vim.o.hidden = true

--" highlighting cursor
vim.wo.cursorline = true
vim.wo.cursorcolumn = true

--""""""""""""""""""
--""""" SHORTCUTS
function map(mode, shortcut, command, opts)
	local options = { noremap = true, silent = true }
	-- if opts ~= nil and opts.nowait then options.nowait = true end
	if opts then
		options = vim.tbl_extend('force', options, opts)
	end
	vim.api.nvim_set_keymap(mode, shortcut, command, options)
end
function nmap(shortcut, command, opts)
	map('n', shortcut, command, opts)
end
function imap(shortcut, command, opts)
	map('i', shortcut, command, opts)
end
function vmap(shortcut, command, opts)
	map('v', shortcut, command, opts)
end
function tmap(shortcut, command, opts)
	map('t', shortcut, command, opts)
end
function xmap(shortcut, command, opts)
	map('x', shortcut, command, opts)
end
function omap(shortcut, command, opts)
	map('o', shortcut, command, opts)
end

vim.g.mapleader = ';'
nmap('<leader>/', ':nohlsearch<cr>') -- from nvim 0.6 it's by default c-l
nmap('<F5>', ':source' .. HOME .. '/.config/nvim/init.lua <cr>')
nmap('Zz', ' :q! <cr>')
-- nmap('ZZ', ' :write | bdelete!<cr>')

-- move lines up and down
nmap('<c-a-j>', ':m .+1<CR>')
nmap('<c-a-k>', ':m .-2<CR>')
imap('<c-A-j>', '<Esc>:m .+1<CR>==gi')
imap('<c-A-k>', '<Esc>:m .-2<CR>==gi')
vmap('<c-a-j>', ":m '>+1<CR>gv-gv")
vmap('<c-a-k>', ':m .-2<CR>gv=gv')

nmap('gf', '<c-w>gF') -- open file in a new tab
nmap('gF', '<c-w>F')

-- page scroll, disable half-page because I'll use hop plugin
nmap('<Space>', '<C-f> <cr>', { nowait = true })
nmap('<C-u>', '<C-b> <cr>')
--folds
nmap('zn', ']z <cr>')
nmap('zp', '[z <cr>')
nmap('zo', 'zO <cr>')
nmap('zO', 'zo <cr>')

nmap('<Esc><Esc>', ':w<CR>') -- saving 2x esc
nmap('<leader>sudo ', ':w !sudo tee % <CR><CR>') -- leader to backslash \w saving as root
nmap('<S-X>', '<C-^>') -- alternate-file file that was last edited in the current window.

-- coping and pasting
nmap('P', ':pu<cr>')
nmap('<leader>P', [["_diwP]]) -- keep pasting over the same thing
nmap('Y', 'y$') -- from nvim 0.6 it's by default
imap('<C-v>', '<Esc>pa ')
--" insert mode
-- move to the nexst/previous word
imap('<C-a>', '<C-o>b')
imap('<C-d>', '<C-o>w')
-- move to the nexst/previous occurrence
nmap('<A-a>', '#')
nmap('<A-d>', '*')

-- go to the line
nmap('<C-j>', 'gj')
nmap('<C-k>', 'gk')
imap('<C-j>', '<Esc>gj')
imap('<C-k>', '<Esc>gk')

-- Tabs
nmap('<tab>', 'gt')
nmap('<s-tab>', 'gT')
nmap('<C-t>', ':tabnew<CR>')

-- windows split also in terminal mode
tmap('<A-h>', '<C-\\><C-N><C-w>h')
tmap('<A-j>', '<C-\\><C-N><C-w>j')
tmap('<A-k>', '<C-\\><C-N><C-w>k')
tmap('<A-l>', '<C-\\><C-N><C-w>l')
imap('<A-h>', '<C-\\><C-N><C-w>h')
imap('<A-j>', '<C-\\><C-N><C-w>j')
imap('<A-k>', '<C-\\><C-N><C-w>k')
imap('<A-l>', '<C-\\><C-N><C-w>l')
nmap('<A-h>', '<C-w>h')
nmap('<A-j>', '<C-w>j')
nmap('<A-k>', '<C-w>k')
nmap('<A-l>', '<C-w>l')

-- Terminal
-- Make escape work in the Neovim terminal.
tmap('<Esc>', '<C-\\><C-n>')
-- Prefer Neovim terminal insert mode to normal mode.
nmap('<F2>', ':vsplit term://zsh<cr>')
nmap('<S-F2>', ':split term://zsh<cr>') -- TODO can't have shift

--""""""""""""""""""
--""""" NOTE TAKING
--dictionary
vim.cmd 'syntax spell toplevel'
--togle spellcheck
nmap('<C-A-s>', ':set spell!<cr> ')
nmap('<S-A-s>', ':setlocal spell spelllang=pl<cr>')
imap('<S-A-s>', '<cmd>setlocal spell spelllang=pl<cr>')
nmap('<A-s>', ':setlocal spell spelllang=en_us<CR>')
imap('<A-s>', '<cmd>setlocal spell spelllang=en_us<CR>')
nmap('<C-e>', 'z=')
imap('<C-e>', 'z=')
nmap('<S-e>', '[s')
--replace from selection/ substitution, produce error but it's workaround for showing command line mode
vmap('<A-r>', '"hy:%s/<C-r>h//g<left><left><cmd>')

--""""""""""""""""""
-- TEXT OBJECTS
--""""""""""""""""""
-- current line
-- xmap('il', '^vg_')
xmap('ol', '^og_')
omap('ol', ':normal vol<CR>')
-- all document
xmap('oa', ':<c-u>normal! G$Vgg0<cr>')
omap('oa', ':<c-u>normal! GVgg<cr>')


--"""""""""""""""""""
--"""""" MACROS
--"""" kindle put cursor on ===
vim.g['@k'] = 'V3jd2j'
-- adoc
vim.g['@p'] = '$a  +j0'
vim.g['@l'] = 'pA['

-- markdown
-- dwie spacje na koncu linii s
vim.g['@s'] = '$a  j0'
-- bookmarks should copy word
vim.g['@z'] = 'ggO- (pbi#bi[po'
--links
vim.g['@h'] = 'a]()hp0i['
vim.g['@f'] = 'f)a kb  '

--""""""""""""""""""
--""" PLUGINS
--""""""""""""""""""

--""""""""""""""""""
-- https://github.com/kdheepak/lazygit.nvim
nmap('<leader>g', ':LazyGit <cr>')

--""""""""""""""""""
-- calendar.vim
vim.g.calendar_google_calendar = 1
vim.g.calendar_google_task = 1
vim.g.calendar_first_day = 'monday'

nmap('<F9>', ':Calendar <CR>')
nmap('<S-F9>', ':Calendar -view=year -split=horizontal -position=below -height=10 <CR>') -- TODO shift, can't be done

--""""""""""""""""""
-- vim-bookmarks
vim.g.bookmark_auto_close = 1
vim.g.bookmark_display_annotation = 1
vim.g.bookmark_auto_save_file = HOME .. '/.local/share/nvim/vim-bookmarks'
vim.g.bookmark_show_toggle_warning = 0

--""""""""""""""""""
-- undo tree
nmap('<A-u>', ':UndotreeToggle<cr>')

if vim.fn.has 'persistent_undo' == 1 then
	vim.o.undodir = HOME .. '/.local/share/nvim/undo'
	vim.o.undofile = true
end

--""""""""""""""""""
-- lazyList
nmap('gll', ":LazyList '- '<CR>")
vmap('gll', ":LazyList '- '<CR>")
nmap('g*', ":LazyList '* '<CR>")
vmap('g*', ":LazyList '* '<CR>")
nmap('gln', ":LazyList '1. '<CR>")
vmap('gln', ":LazyList '1. '<CR>")
nmap('glz', ":LazyList '[ ] '<CR>")
vmap('glz', ":LazyList '[ ] '<CR>")
nmap('gl1', ":LazyList '# '<CR>")
vmap('gl1', ":LazyList '# '<CR>")
nmap('gl2', ":LazyList '## '<CR>")
vmap('gl2', ":LazyList '## '<CR>")
nmap('gl3', ":LazyList '### '<CR>")
vmap('gl3', ":LazyList '### '<CR>")
nmap('gl4', ":LazyList '#### '<CR>")
vmap('gl4', ":LazyList '#### '<CR>")
nmap('gl5', ":LazyList '##### '<CR>")
vmap('gl5', ":LazyList '##### '<CR>")

--""""""""""""""""""
-- startify disable changing dir
vim.g.startify_change_to_dir = 0

--"""""""""""""""""
-- repeat
vim.cmd 'silent! call repeat#set("\\<Plug>MyWonderfulMap", v:count)'

-- ZenMode more readable text
nmap('<F6>', ':ZenMode <CR>')

--""""""""""""""""""
-- vim-asciidoctor  https://github.com/habamax/vim-asciidoctor
nmap('<F7>', ':!preview-ascii.sh % <CR>')
nmap('<S-F7>', ':Asciidoctor2DOCX<CR>') -- TODO shift, can't be bind

vim.g.asciidoctor_syntax_conceal = 1
vim.g.asciidoctor_folding = 2
vim.g.asciidoctor_folding_level = 6
vim.g.asciidoctor_fenced_languages = { 'java', 'typescript', 'javascript', 'bash', 'html' } -- 'kotlin' add syntax TODO
-- vim.g.asciidoctor_syntax_indented = 0
-- vim.g.asciidoctor_fold_options = 0
vim.g.asciidoctor_img_paste_command = 'xclip -selection clipboard -t image/png -o > %s%s'
nmap('<A-p>', ':AsciidoctorPasteImage<CR>')

--vim-markdown syntax
vim.g.vim_markdown_fenced_languages = 'java=java'
vim.g.vim_markdown_toc_autofit = 1
vim.g.vim_markdown_folding = 0
vim.g.vim_markdown_fold_options = 0
-- vim.g.vim_markdown_folding_level = 6
-- vim.g.vim_markdown_folding_style_pythonic = 1

--""""""""""""""""""
-- TAGBAR
nmap('<leader>t', ':TagbarToggle<CR>')
vim.g.tagbar_autoclose = 1
vim.g.tagbar_autofocus = 1
vim.g.tagbar_zoomwidth = 0
vim.g.tagbar_sort = 0
vim.wo.conceallevel = 3

vim.cmd [[
let g:tagbar_type_asciidoctor = {
	\ 'ctagstype' : 'asciidoc',
	\ 'kinds' : [
		\ 'h:table of contents',
		\ 'a:anchors:1',
		\ 't:titles:1',
		\ 'n:includes:1',
		\ 'i:images:1',
		\ 'I:inline images:1'
	\ ]
\ }
]]

vim.cmd [[ 
let g:tagbar_type_markdown = {
    \ 'ctagstype' : 'markdown',
    \ 'kinds' : [
        \ 'h:table of contents',
    \ ]
\ } 
]]

--"""""""""""""""""""
-- rest https://github.com/NTBBloodbath/rest.nvim#usage
nmap('<leader>r', '<Plug>RestNvim<cr>', { noremap = false })
nmap('<leader>rr', '<Plug>RestNvimLast<cr>', { noremap = false })
nmap('<leader>rp', '<Plug>RestNvimPreview<cr>', { noremap = false })

--"""""""""""""""""""
-- jqx https://github.com/gennaro-tedesco/nvim-jqx
nmap('<leader>x', '<Plug>JqxList', { noremap = false })

-- -------------------------------------------------------------------------
--  Telescope https://github.com/nvim-telescope/telescope.nvim#pickers
-- -------------------------------------------------------------------------
vim.o.maxmempattern = 3000 -- fix pattern uses more memory than 'maxmempattern', default is 2000

local telescope = require 'telescope'
if telescope then
	telescope.setup {
		defaults = {
			prompt_prefix = '   ',
			file_ignore_patterns = { 'tags' },
			layout_strategy = 'flex', -- center, cursor
			width_padding = 30,
			layout_config = {
				flex = {
					flip_columns = 150, -- is less than that will act like the vertical strategy, and otherwise like the horizontal strategy.
				},
				horizontal = { width = 0.99, height = 0.99, preview_width = 0.7 },
				vertical = { width = 0.99, height = 0.99, preview_height = 0.7 },
			},
			mappings = { -- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua
				i = {
					['<C-j>'] = 'move_selection_next',
					['<C-k>'] = 'move_selection_previous',
					['<C-Space>'] = 'select_default',
					['<C-h>'] = 'which_key',
					['<C-n>'] = 'cycle_history_next',
					['<C-p>'] = 'cycle_history_prev',
				},
			},
		},
	}

	nmap('<c-f>', '<cmd>Telescope find_files<cr>')
	nmap('<c-s>', '<cmd>Telescope live_grep<cr>')
	nmap('tp', '<cmd>Telescope find_files find_command=rg,--hidden,--files<cr>') -- with hidden files
	nmap('to', '<cmd>Telescope oldfiles<cr>')
	nmap('ti', '<cmd>Telescope current_buffer_fuzzy_find<cr>') -- lines in file
	nmap('tj', '<cmd>Telescope jumplist<cr> ') -- I changed source code for showing only current file
	nmap('tb', '<cmd>Telescope buffers<cr>') -- closed files
	nmap('tc', '<cmd>Telescope commands <cr> ')
	nmap('th', '<cmd>Telescope command_history<cr> ')
	nmap('tH', '<cmd>Telescope help_tags<cr> ')
	nmap('tg', '<cmd>Telescope git_status<cr>')
	nmap('tk', '<cmd>Telescope keymaps<cr>')
	nmap('tf', '<cmd>Telescope file_browser<cr>') -- can go to the parent dir
	nmap('tr', '<cmd>Telescope registers<cr>')
	nmap('ts', '<cmd>Telescope spell_suggest<cr>')
	nmap('t/', '<cmd>Telescope search_history<cr> ')
	nmap('t1', '<cmd>Telescope man_pages<cr>')
	nmap('tC', '<cmd>Telescope colorscheme<cr>')
	nmap('tl', '<cmd>Telescope<cr>') -- list of the pickers
	-- nmap('tl', '<cmd>Telescope loclist<cr> ')

	telescope.load_extension 'heading'
	nmap('tt', '<cmd>Telescope heading <cr>')
	-- nmap('tt', ':silent !ctags -R . <CR>:redraw!<cr>:Telescope current_buffer_tags<CR>')
	nmap('T', ':silent !ctags -R . <CR>:redraw!<cr>:Telescope tags<CR>')

	telescope.load_extension 'vim_bookmarks'
	nmap('tm', '<cmd>Telescope vim_bookmarks current_file <cr>')
	nmap('tM', '<cmd>Telescope vim_bookmarks all <cr>')

	require('telescope').load_extension 'ultisnips'
	nmap('tu', '<cmd>Telescope ultisnips <cr>')
end

--""""""""""""""""""
-- previm https://github.com/previm/previm
vim.g.previm_open_cmd = 'firefox'
nmap('<leader>v', ':PrevimOpen <CR>')
-- vim.g.previm_enable_realtime =  1
-- to change style turn 0 to 1 in previm_disable_default_css and put path to
vim.g.previm_disable_default_css = 1
vim.g.previm_custom_css_path = HOME .. '/.config/nvim/custom/md-prev.css'

--""""""""""""""""""
-- eighties automatyczne dostosowanie okien
vim.g.eighties_enabled = 1
vim.g.eighties_minimum_width = 80
vim.g.eighties_extra_width = 0 -- Increase this if you want some extra room
vim.g.eighties_compute = 1 -- Disable this if you just want the minimum + extra
vim.g.eighties_bufname_additional_patterns = { 'fugitiveblame' } -- Defaults to [], 'fugitiveblame' is only an example. Takes a comma delimited list of bufnames as strings.

--""""""""""""""""""
-- surround
nmap('<leader>s', 'ysiW', { noremap = false }) -- surround a word

--""""""""""""""""""
-- ultisnips
vim.g.UltiSnipsEditSplit = 'vertical'
vim.g.UltiSnipsExpandTrigger = '<c-l>'
-- shortcut to go to next position
vim.g.UltiSnipsJumpForwardTrigger = '<c-l>'
-- shortcut to go to previous position
vim.g.UltiSnipsJumpBackwardTrigger = '<c-k>'
vim.g.UltiSnipsSnippetsDir = HOME .. '~/.config/nvim/UltiSnips'
vim.g.UltiSnipsSnippetDirectories = { 'UltiSnips' }


--""""""""""""""""""
-- NvimTreeToggle https://github.com/kyazdani42/nvim-tree.lua
nmap('<F3>', ':NvimTreeToggle<CR>')

--""""""""""""""""""
-- https://github.com/bfredl/nvim-miniyank
vim.g.miniyank_filename = HOME .. '/.local/share/nvim/miniyank.mpack'

nmap('p', '<Plug>(miniyank-autoput)', { noremap = false })
nmap('<A-n>', '<Plug>(miniyank-cycle)', { noremap = false })
nmap('<A-p>', '<Plug>(miniyank-cycleback)', { noremap = false })

--""""""""""""""""""
-- https://github.com/sbdchd/neoformat
vmap('<a-f>', ':Neoformat! java astyle <CR>')

-- nmap('<leader>f', '<cmd> !stylua --config-path ~/.config/stylua/stylua.toml % <cr>')
nmap('<leader>f', '<cmd> lua vim.lsp.buf.formatting_sync() <cr>')
vmap('<leader>f', '<cmd> lua vim.lsp.buf.range_formatting() <cr>')

-----------------------------
-- Status and tab bars
nmap('<leader><Tab>', ':BufferLineCycleNext <cr>')
nmap('<leader>b', ':BufferLinePick <cr>') -- jumping to tab, like hop
nmap('<leader>B', ':BufferLineSortByDirectory <cr>')
require('bufferline').setup {
	options = {
		show_close_icon = false,
		sort_by = 'relative_directory',
		show_buffer_close_icons = false,
		always_show_bufferline = false,
	},
}

require('lualine').setup { options = { theme = 'onedark', component_separators = '|',  globalstatus = true, } }

-- -------------------------------------------------------------------------
--                       -- nvim-cmp
-- https://github.com/hrsh7th/nvim-cmp
-- -------------------------------------------------------------------------
local cmp = require 'cmp'
cmp.setup {
	snippet = {
		expand = function(args)
			vim.fn['UltiSnips#Anon'](args.body)
		end,
	},
	mapping = {
		-- ['<CR>'] = cmp.mapping(cmp.mapping.confirm { select = true }, { 'i', 'c' }),
		['<C-l>'] = cmp.mapping(cmp.mapping.confirm { select = true }, { 'i', 'c' }),
		['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert }, { 'i', 'c' }),
		['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert }, { 'i', 'c' }),
		['<C-e>'] = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() }, -- cancel autocomplation
		['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }), -- start popup menu
		['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
	},
	sources = { -- order is important
		-- { name = "nvim_lsp" },
		{ name = 'ultisnips', keyword_length = 1 },
		{ name = 'buffer', keyword_length = 2, option = { keyword_pattern = [[\k\+]] } },
		{ name = 'nvim_lua' },
		{ name = 'path' },
		{ name = 'calc' },
		{ name = 'dictionary' },
	},
	completion = {
		completeopt = 'menu,menuone,noinsert',
		keyword_length = 3,
	},

	formatting = {
		format = function(entry, item)
			item.kind = ' '
			item.menu = ({
				buffer = '',
				ultisnips = '',
				nvim_lsp = '',
				nvim_lua = '',
				path = '',
				calc = '',
				dictionary = '',
			})[entry.source.name]
			return item
		end,
	},
}

-- CMD mode - if you are in that mode and put / or : ' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
	sources = {
		{ name = 'buffer' },
	},
})
cmp.setup.cmdline(':', {
	sources = {
		{ name = 'cmdline' },
		{ name = 'cmdline_history' },
		{ name = 'path' },
	},
})
local dirEn = HOME .. '/.config/rofi/scripts/expander/en-popular'
local dirPl = HOME .. '/.config/rofi/scripts/expander/pl-popular'
require('cmp_dictionary').setup {
	dic = { -- ["*"] = { dirEn, dirPl}
		['asciidoctor'] = { dirEn, dirPl },
		['markdown'] = { dirEn, dirPl },
		['text'] = { dirEn, dirPl },
	},
	exact = 4, -- -1 only exact the same prefix; should be gratter than keyword_length
	async = true,
	capacity = 5,
	debug = false,
	-- debug = true,
}

-- -------------------------------------------------------------------------
--                       null-ls
-- -------------------------------------------------------------------------
local nullLs = require 'null-ls'
local formatting = nullLs.builtins.formatting
local diagnostics = nullLs.builtins.diagnostics
nullLs.setup {
	sources = { -- :NullLsLog shows supported sources
		diagnostics.shellcheck.with { method = nullLs.methods.DIAGNOSTICS_ON_SAVE },
		diagnostics.selene.with { method = nullLs.methods.DIAGNOSTICS_ON_SAVE },
		diagnostics.yamllint.with { method = nullLs.methods.DIAGNOSTICS_ON_SAVE },
		formatting.stylua.with {
			extra_args = { '--config-path', vim.fn.expand '~/.config/stylua/stylua.toml' },
		},
		formatting.prettier,
		formatting.clang_format.with {
			filetypes = { 'java', 'asciidoctor' },
		},
	},
	debug = false,
}
