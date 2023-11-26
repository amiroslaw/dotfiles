-- S-k - jump to help page
-- free keybinding leader-b/B
-- TODO
-- add shortcuts like in shell imap('<C-e>', 'normal A')
-- VARIABLES
local HOME = os.getenv 'HOME'

--{{{ lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- }}} 

-- Autocommands {{{
vim.api.nvim_create_autocmd( -- go to last loc when opening a buffe
	'BufReadPost',
	{
		command = [[if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]],
	}
)
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
	pattern = { '*.json' },
	command = [[set filetype=json]],
})
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
	pattern = { '/tmp/*' },
	command = [[set filetype=text]],
})
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
	pattern = { 'qutebrowser-editor-*', 'tmpcompose.txt', '/tmp/txt/*' },
	command = [[setlocal spell spelllang=en | startinsert]],
})
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
	pattern = { '*.{md,mdwn,mkd,mkdn,mark,markdown}' },
	command = [[set filetype=markdown]],
})
vim.api.nvim_create_autocmd( -- Prefer Neovim terminal insert mode to normal mode. IDK if it's default mode
	'BufEnter', {
	pattern = { 'term://*' },
	command = [[startinsert]],
})
vim.api.nvim_create_autocmd('TextYankPost', {
	command = 'silent! lua vim.highlight.on_yank {timeout=600}',
	group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }), -- clear true is default
})
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
	pattern = { '*.todo' },
	command = [[set filetype=todo]],
})
-- compile and execute 
local lang_maps = {
	python = { exec = "python %" },
	lua = { exec = "lua %" },
	java = { build = "javac %", exec = "java %:r" },
	sh = { exec = "./%" },
	-- TODO
	typescript = { build = "deno compile %", exec = "deno run %" },
	javascript = { build = "deno compile %", exec = "deno run %" },
}
for lang, data in pairs(lang_maps) do
	if data.build ~= nil then
		vim.api.nvim_create_autocmd(
			"FileType",
			{ command = "nnoremap <Leader>c :!" .. data.build .. "<CR>", pattern = lang }
		)
	end
	vim.api.nvim_create_autocmd(
		"FileType",
		{ command = "nnoremap <Leader>e :split<CR>:terminal " .. data.exec .. "<CR>", pattern = lang }
	)
end
-- doesn't work with keybinding in zsh
-- autocmd BufDelete * if len(filter(range(1, bufnr('$')), '! empty(bufname(v:val)) && buflisted(v:val)')) == 1 | quit | endif 
-- }}} 

-- SETTINGS {{{
-- vim.o.ch = 0 -- hide command, from v8
vim.o.foldlevelstart = 9 -- unfold at start - don't work after changes
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.termguicolors = true
vim.b.buftype = '' -- fix Cannot write buftype option is set
vim.o.laststatus = 3
-- vim.b.timeoutlen = 500 -- Time in milliseconds to wait for a mapped sequence to complete.
-- podpowiedzi
vim.o.wildmode = 'longest,list,full'
--" Status bar
vim.cmd 'filetype plugin indent on'
vim.o.encoding = 'utf-8'
vim.o.fileencoding = 'utf-8'
vim.o.fileencodings = 'utf-8', 'latin1'
vim.o.linebreak = true
vim.cmd 'syntax enable'
vim.o.startofline = true -- for nvim-origami plugin

-- IncSearch
vim.o.ignorecase = true
vim.o.smartcase = true
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
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
-- vim.o.expandtab = true -- convert tab to spaces
vim.o.scrolloff = 5 -- margin
vim.o.hidden = true

--" highlighting cursor
vim.wo.cursorline = true
vim.wo.cursorcolumn = true

vim.opt.iskeyword:append('-') -- words separeted by - will recognise as a one word

-- }}} 

-- SHORTCUTS {{{
-- map functions {{{
local key = vim.keymap.set
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
end -- }}} 

vim.g.mapleader = ';'
vim.g.maplocalleader=" " --space
-- nmap('x', '"_x') -- doesn't add to register from `x`, will brake xp
nmap('<C-/>', ':nohlsearch<cr>')
nmap('<F1>', ':term taskwarrior-tui<CR>')
nmap(',l', '<cmd>luafile dev/init.lua<cr>', {}) -- for plugin development
nmap('Zz', ' :q! <cr>')
-- nmap('ZZ', ' :write | bdelete!<cr>')

-- move lines up and down
nmap('<c-a-j>', ':m .+1<CR>')
nmap('<c-a-k>', ':m .-2<CR>')
imap('<c-A-j>', '<Esc>:m .+1<CR>==gi')
imap('<c-A-k>', '<Esc>:m .-2<CR>==gi')
vmap('<c-a-j>', ":m '>+1<CR>gv-gv")
vmap('<c-a-k>', ':m .-2<CR>gv=gv')

nmap('gf', '<c-w>gf') -- open file in a new tab
vmap('gf', '<c-w>gf')
nmap('gF', '<c-w>vgf') -- in vertical split
vmap('gF', '<c-w>vgf')

-- page scroll, override defaults
nmap('<C-d>', '<C-f> <cr>', { nowait = true })
imap('<C-d>', '<C-o><c-d>', { nowait = true })
nmap('<C-u>', '<C-b> <cr>')
imap('<C-u>', '<C-o><c-u>')
nmap('<C-a-d>', '<C-d> <cr>')
nmap('<C-a-u>', '<C-u> <cr>')
--folds
nmap('zn', ']z <cr>')
nmap('zp', '[z <cr>')
nmap('zo', 'zO <cr>')
nmap('zO', 'zo <cr>')

nmap('<Esc><Esc>', ':w<CR>') -- saving 2x esc
nmap('<leader>sudo ', ':w !sudo tee % <CR><CR>') -- leader to backslash \w saving as root
nmap('<S-X>', '<C-^>') -- alternate-file file that was last edited in the current window.

-- coping and pasting
-- nmap('P', ':pu<cr>') -- use yanky
nmap('<leader>P', [["_diwP]]) -- keep pasting over the same thing
nmap('Y', 'y$') -- from nvim 0.6 it's by default
imap('<C-v>', '<Esc>pa ')
-- move to the nexst/previous occurrence
nmap('<A-a>', '#')
nmap('<A-d>', '*')
--" insert, redline bash shortcuts
-- move to the nexst/previous word/char; move to begginig/end of line
imap('<A-f>', '<C-o>w')
imap('<A-b>', '<C-o>b')
imap('<C-f>', '<C-o>l')
imap('<C-b>', '<C-o>h')
imap('<C-a>', '<C-o>0') -- or not blank _
imap('<C-e>', '<C-o>$') -- or not blank g_

-- jump paragraphs next line in insert mode
nmap('<C-j>', 'gj')
nmap('<C-k>', 'gk')
imap('<C-j>', '<Esc>gj')
imap('<C-k>', '<Esc>gk')
nmap('<C-l>', '{')
nmap('<C-h>', '}')
vmap('<C-l>', '{')
vmap('<C-h>', '}')
imap('<C-l>', '<Esc>{') -- can't override
imap('<C-h>', '<Esc>}')


-- LSP {{{
vim.cmd "sign define DiagnosticSignError text= texthl=DiagnosticSignError"
vim.cmd "sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn"
vim.cmd "sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo"
vim.cmd "sign define DiagnosticSignHint text= texthl=DiagnosticSignHint"
nmap(',j', '<cmd>lua vim.diagnostic.goto_next() <CR>' )
nmap(',k', '<cmd>lua vim.diagnostic.goto_prev() <CR> ')
-- }}} 

-- Tabs, windows and terminal{{{

-- Tabs
nmap('<tab>', 'gt')
nmap('<s-tab>', 'gT')
nmap('<C-t>', ':tabnew<CR>')
nmap('<LocalLeader>ss', ':split<CR>')
nmap('<LocalLeader>sv', ':vs<CR>')

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
nmap('<F24>', ':split term://zsh<cr>') -- S-F2
-- }}} 

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
nmap('<LocalLeader>t', ':.!trans -shell pl:en -show-original n  -show-prompt-message n -show-languages n -no-ansi ')
nmap('<LocalLeader>T', ':.!trans -shell en:pl -show-original n  -show-prompt-message n -show-languages n -no-ansi ')
nmap('<C-e>', 'z=')
-- imap('<C-e>', '<C-o>z=') -- wrong? and occupied
nmap('<S-e>', '[s')
nmap('<a-e>', '[s1z=`]') -- auto correction for the last occurrence
vmap('<a-e>', '[s1z=`]')
imap('<a-e>', '<Esc>[s1z=`]a')
-- capitalize the first word in the sentence and the last word
nmap('<LocalLeader>U', '<c-(>~A')
nmap('<LocalLeader>u', 'b~A')
-- imap('<LocalLeader>u', '<Esc><c-(>~A') -- find shortcut

--replace from selection/ substitution, produce error but it's workaround for showing command line mode
vmap('<A-r>', '"hy:%s/<C-r>h//g<left><left><cmd>')
vmap('<S-A-r>', '"hy:%s/<C-r>h/^M/g<left><left><cmd>') -- add special char for enter c-v enter
nmap('yu', ':let @+ = expand("%:p")<cr>') -- copy current file path and name into clipboard
-- }}} 

-- TEXT OBJECTS {{{
-- current line e.g. yol
-- xmap('il', '^vg_')
xmap('ol', '^og_')
omap('ol', ':normal vol<CR>')
-- all document
xmap('oa', ':<c-u>normal! G$Vgg0<cr>')
omap('oa', ':<c-u>normal! GVgg<cr>') -- }}} 

-- MACROS {{{
--"""" kindle put cursor on ===
vim.fn.setreg('k', 'd3joj' )
-- code
vim.fn.setreg('m', 'Vf{%y' ) -- copy method with curry bracket 
-- adoc
vim.fn.setreg('p', '$a  +j0') -- add `+` new line
vim.fn.setreg('h', 'pA[') -- link from selection
-- list l - unordered; o - ordered; z - task
vim.fn.setreg('l', '0i* ')
vim.fn.setreg('o', '0i. ')
vim.fn.setreg('z', '0i* [ ] ')
-- markdown
-- dwie spacje na koncu linii s
vim.fn.setreg('s', '$a  j0')
vim.fn.setreg('b', 'ggO- (pbi#bi[po') -- bookmarks should copy word
vim.fn.setreg('u', 'a]()hp0i[') -- markdown link
vim.fn.setreg('f', 'f)a kb  ') 
-- }}} 

-- PLUGINS {{{ 
	-- Move small configuration to plugins.lua, left only shortcuts
require("lazy").setup("plugins")
nmap('<F11>', ':Lazy<CR>')

-- nmap('<leader>f', '<cmd> !stylua --config-path ~/.config/stylua/stylua.toml % <cr>')
nmap('<leader>f', '<cmd> lua vim.lsp.buf.format() <cr>')
vmap('<leader>f', '<cmd> lua vim.lsp.buf.format() <cr>')

--""""""""""""""""""
-- https://github.com/sbdchd/neoformat
vmap('<a-f>', ':Neoformat! java astyle <CR>')
nmap('<a-f>', ':Neoformat! java astyle <CR>')

--""""""""""""""""""
-- https://github.com/is0n/fm-nvim
nmap(',g', ':Lazygit <cr>')
nmap('<leader>w', ':TaskWarriorTUI <cr>')
nmap('<F3>', ':Vifm<CR>')
nmap('<leader>n', ':Vifm<CR>')
nmap('<leader>N', ':Ranger<CR>')

--""""""""""""""""""
-- surround
-- visual mode  + S"
nmap('<leader>s', 'ysiW', { noremap = false }) -- surround a word
-- <leader>S witch-key
require("nvim-surround").setup({
    surrounds = {
            ["l"] =  { -- surround text and append url in asciidoc
				add = { {vim.fn.getreg("+") .. "["},{ "]"} }
			},
            ["L"] =  {
				add = {"", "[" .. vim.fn.getreg("+") .. "]"} 
			}
    },
})

--"""""""""""""""""""
-- jqx https://github.com/gennaro-tedesco/nvim-jqx
nmap('<leader>x', '<Plug>JqxList', { noremap = false })

--""""""""""""""""""
-- startify disable changing dir
vim.g.startify_change_to_dir = 0

--"""""""""""""""""
-- repeat
vim.cmd 'silent! call repeat#set("\\<Plug>MyWonderfulMap", v:count)'

-- taskmaker {{{
vmap('<LocalLeader>w', '<cmd>TaskmakerAddTasks <CR>')
nmap('<LocalLeader>x', '<cmd>TaskmakerToggle <CR>') -- }}} 

-- Windows {{{
nmap('<leader>M', '<Cmd>WindowsToggleAutowidth<CR>')
nmap('<leader>m', '<Cmd>WindowsMaximize<CR>') -- }}} 

-- calendar.vim {{{
vim.cmd 'source ~/Documents/Ustawienia/stow-private/calendar.vim'
vim.g.calendar_google_calendar = 1
vim.g.calendar_google_task = 1
vim.g.calendar_first_day = 'monday'
vim.g.calendar_calendar_candidates = {'arek', 'warrior', 'inwestycje'}
vim.g.calendar_views = {'month', 'day_7', 'day', 'agenda'} -- I'm not sure about agenda
vim.g.calendar_cyclic_view = 1

nmap('<F9>', ':Calendar -view=day_7<CR>')
nmap('<F21>', ':Calendar -view=year -split=horizontal -position=below -height=10 <CR>') -- shift F9 -- }}} 

-- marks {{{
-- https://github.com/chentoast/marks.nvim
require('marks').setup {
	mappings = {
		preview = 'm;', -- m;a show mark in popup
		set_bookmark0 = 'm0',
		toggle = 'mm', -- set_next = 'mm', it's the same
		delete_buf = 'mx',
		next = 'mn',
		prev = 'mp',
		next_bookmark = 'mN', -- next in the current group
		prev_bookmark = 'mP',
		delete_bookmark = 'mX',
		annotate = 'm/', -- only for groupmarks
	},
	bookmark_0 = { -- groupmarks remove by dm0
		sign = '⚑',
		virt_text = 'TODO',
	},
}
nmap('ml', ':MarksListBuf<cr>')
nmap('mA', ':MarksListAll<cr>')
nmap('mL', ':BookmarksListAll<cr>') -- groupmarks
-- }}} 

-- undo tree {{{
nmap('<A-u>', ':UndotreeToggle<cr>')
if vim.fn.has 'persistent_undo' == 1 then
	vim.o.undodir = HOME .. '/.local/share/nvim/undo'
	vim.o.undofile = true
end -- }}} 

-- lazyList {{{
nmap('glt', ":LazyList '.'<CR>") -- title
vmap('glt', ":LazyList '.'<CR>")
nmap('gll', ":LazyList '* '<CR>") -- unordered list
vmap('gll', ":LazyList '* '<CR>")
nmap('gll2', ":LazyList '** '<CR>")
vmap('gll2', ":LazyList '** '<CR>")
nmap('gll3', ":LazyList '*** '<CR>")
vmap('gll3', ":LazyList '*** '<CR>")
nmap('glo', ":LazyList '. '<CR>") -- ordered list
vmap('glo', ":LazyList '. '<CR>")
nmap('glo2', ":LazyList '.. '<CR>")
vmap('glo2', ":LazyList '.. '<CR>")
nmap('glo3', ":LazyList '... '<CR>")
vmap('glo3', ":LazyList '... '<CR>")
nmap('glz', ":LazyList '* [ ] '<CR>") -- task
vmap('glz', ":LazyList '* [ ] '<CR>")
nmap('glz2', ":LazyList '** [ ] '<CR>")
vmap('glz2', ":LazyList '** [ ] '<CR>")
nmap('glz3', ":LazyList '*** [ ] '<CR>")
vmap('glz3', ":LazyList '*** [ ] '<CR>")
nmap('gln', ":LazyList ':NOTE '<CR>") --asciidoc admonitions
vmap('gln', ":LazyList ':NOTE '<CR>")
nmap('gli', ":LazyList ':IMPORTANT '<CR>")
vmap('gli', ":LazyList ':IMPORTANT '<CR>")
nmap('glw', ":LazyList ':WARNING '<CR>")
vmap('glw', ":LazyList ':WARNING '<CR>")
nmap('glp', ":LazyList ':TIP '<CR>")
vmap('glp', ":LazyList ':TIP '<CR>")
nmap('glc', ":LazyList ':CAUTION '<CR>")
vmap('glc', ":LazyList ':CAUTION '<CR>")
nmap('gl1', ":LazyList '= '<CR>") -- header
vmap('gl1', ":LazyList '= '<CR>")
nmap('gl2', ":LazyList '== '<CR>")
vmap('gl2', ":LazyList '== '<CR>")
nmap('gl3', ":LazyList '=== '<CR>")
vmap('gl3', ":LazyList '=== '<CR>")
nmap('gl4', ":LazyList '==== '<CR>")
vmap('gl4', ":LazyList '==== '<CR>")
nmap('gl5', ":LazyList '===== '<CR>")
vmap('gl5', ":LazyList '===== '<CR>") 
nmap('glmm', ":LazyList '- '<CR>") -- markdown
vmap('glmm', ":LazyList '- '<CR>")
nmap('glmo', ":LazyList '1. '<CR>")
vmap('glmo', ":LazyList '1. '<CR>")
-- }}} 

-- vim-asciidoctor {{{
--  https://github.com/habamax/vim-asciidoctor
nmap('<F19>', ':Asciidoctor2DOCX<CR>') -- S-F7
vim.g.asciidoctor_syntax_conceal = 1
vim.g.asciidoctor_folding = 2
vim.g.asciidoctor_folding_level = 6
vim.g.asciidoctor_fenced_languages = { 'java', 'typescript', 'javascript', 'bash', 'html', 'xml', 'lua', 'css', 'sql' } -- 'kotlin' add syntax TODO
-- vim.g.asciidoctor_syntax_indented = 0
-- vim.g.asciidoctor_fold_options = 0
vim.g.asciidoctor_img_paste_command = 'xclip -selection clipboard -t image/png -o > %s%s'
nmap('<A-p>', ':AsciidoctorPasteImage<CR>') -- }}} 

-- vim-markdown syntax {{{
vim.g.vim_markdown_fenced_languages = 'java=java'
vim.g.vim_markdown_toc_autofit = 1
vim.g.vim_markdown_folding = 0
vim.g.vim_markdown_fold_options = 0
-- vim.g.vim_markdown_folding_level = 6
-- vim.g.vim_markdown_folding_style_pythonic = 1 -- }}} 

-- TAGBAR {{{
nmap('<leader>t', ':TagbarToggle<CR>')
vim.g.tagbar_autoclose = 1
vim.g.tagbar_autofocus = 1
vim.g.tagbar_zoomwidth = 0
vim.g.tagbar_sort = 0
vim.wo.conceallevel = 3
vim.g.tagbar_type_asciidoctor = {
	ctagstype = 'asciidoc',
	kinds =  {
		'h:table of contents',
		'a:anchors:1',
		't:titles:1',
		'n:includes:1',
		'i:images:1',
		'I:inline images:1'
		}
}
vim.g.tagbar_type_markdown = {
    ctagstype = 'markdown',
    kinds = {'h:table of contents' }
 } -- }}} 

-- RestNvim {{{
-- https://github.com/NTBBloodbath/rest.nvim#usage
nmap('<leader>r', '<Plug>RestNvim<cr>', { noremap = false })
nmap('<leader>rr', '<Plug>RestNvimLast<cr>', { noremap = false })
nmap('<leader>rp', '<Plug>RestNvimPreview<cr>', { noremap = false }) -- }}} 

-- browser.nvim {{{
-- https://github.com/lalitmee/browse.nvim 
local bookmarks = {
    ['youtube'] = 'https://www.youtube.com/results?search_query=%s',
	['diki']= 'https://www.diki.pl/slownik-angielskiego?q=%s',
	['deepl'] ='https://www.deepl.com/en/translator#en/pl/%s',
    ['translator'] = 'https://translate.google.pl/?hl=pl#pl/en/%s',
    ['cambridge'] = 'https://dictionary.cambridge.org/spellcheck/english/?q=%s', 
    ['thesaurus'] = 'https://www.thesaurus.com/browse/%s?s=t',
    ['allegro']= 'https://allegro.pl/listing?string=%s',
	['ceneo']= 'https://www.ceneo.pl/;szukaj-%s',
    ['wiki-pl'] = 'https://pl.wikipedia.org/wiki/%s',
    ['wiki-en'] = 'https://en.wikipedia.org/wiki/%s',
    ['arch-wiki'] = 'https://wiki.archlinux.org/?search=%s',
    ['piped-videos'] = 'https://piped.kavin.rocks/results?search_query=%s',
    ['brave'] = 'https://search.brave.com/search?q=%s',
	["gh"] = "https://github.com/search?q=%s",
	["gh_repo"] = "https://github.com/search?q=%s&type=repositories",
	-- ["github"] = { -- in groups doesn't work selection 
 --      ["name"] = "Group: github",
 --      ["code_search"] = "https://github.com/search?q=%s&type=code",
 --      ["issues_search"] = "https://github.com/search?q=%s&type=issues",
 --      ["pulls_search"] = "https://github.com/search?q=%s&type=pullrequests",
  -- },
}
local browse = require('browse')
browse.setup({
  provider = "google", -- duckduckgo, bing
  bookmarks = bookmarks
})
nmap('gs', ':execute "normal viw" | lua require"browse".input_search()<cr>')
vmap('gs', '<cmd>lua require"browse".input_search()<cr>')
nmap('go', ':execute "normal viw" | lua require"browse".open_bookmarks()<cr>')
vmap('go', '<cmd>lua require"browse".open_bookmarks()<cr>')
-- maybe chnage order to gbs; gbo; gwd
nmap('<Leader>ga', '<cmd>lua require"browse".browse()<cr>') -- all options
nmap('<Leader>gss', ':execute "normal vis" | lua require"browse".input_search()<cr>') -- sentence
nmap('<Leader>gsb', ':execute "normal vib" | lua require"browse".input_search()<cr>') -- bracket
nmap('<Leader>gs"', [[:execute 'normal vi"' | lua require"browse".input_search()<cr>]])
nmap("<Leader>gs'", [[:execute "normal vi'" | lua require"browse".input_search()<cr>]])
nmap('<Leader>gos', ':execute "normal vis" | lua require"browse".open_bookmarks()<cr>') 
nmap('<Leader>gob', ':execute "normal vib" | lua require"browse".open_bookmarks()<cr>') 
nmap('<Leader>go"', [[:execute 'normal vi"' | lua require"browse".open_bookmarks()<cr>]])
nmap("<Leader>go'", [[:execute "normal vi'" | lua require"browse".open_bookmarks()<cr>]])
nmap('<Leader>gd', ':execute "normal viw" | lua require"browse.devdocs".search_with_filetype()<cr>') -- search devdocs with context of filetype
vmap('<Leader>gd', '<cmd>lua require"browse.devdocs".search_with_filetype()<cr>') -- selection doesn't work
-- }}} 

-- Telescope {{{
--  https://github.com/nvim-telescope/telescope.nvim#pickers
-- excluded files and folders in .ignore
vim.o.maxmempattern = 3000 -- fix pattern uses more memory than 'maxmempattern', default is 2000

local telescope = require 'telescope'
if telescope then
local actions = require "telescope.actions"
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
					['<C-w>'] = 'which_key',
					['<C-n>'] = 'cycle_history_next',
					['<C-p>'] = 'cycle_history_prev',
					['<C-x>'] = actions.close, -- IDK why default c-c doesn't work
					['<C-h>'] = actions.select_horizontal,
					['<C-CR>'] = actions.file_tab,
					['<a-a>'] = actions.add_selected_to_qflist,
					['<a-q>'] = actions.smart_send_to_qflist + actions.open_qflist, -- send all if not selected
						-- ["<cr>"] = function(bufnr) require("telescope.actions.set").edit(bufnr, "tab drop") end  
					},
				},
			},
			pickers = { 
				buffers = { mappings = { i = { ["<CR>"] = actions.select_tab_drop } } },-- go to tab if open
					}
		}

	nmap('<c-s>', '<cmd>Telescope live_grep<cr>')
	nmap('ts', '<cmd>Telescope grep_string<cr>') --  string under your cursor or selection in your current working directory
	nmap('tp', '<cmd>Telescope find_files<cr>')
	-- nmap('tp', '<cmd>Telescope find_files find_command=rg,--hidden,--files<cr>') -- with hidden files
	nmap('to', '<cmd>Telescope oldfiles<cr>')
	nmap('tl', '<cmd>Telescope current_buffer_fuzzy_find skip_empty_lines=true<cr>') -- lines in file
	nmap('tJ', '<cmd>Telescope jumplist sort_lastused=true <cr> ') -- I changed source code for showing only current file, idk if sort_lastused works
	nmap('ta', '<cmd>Telescope buffers ignore_current_buffer=true sort_mru=true show_all_buffers=false<cr>') -- closed files
	nmap('tq', '<cmd>Telescope quickfix<cr> ') -- quickfix history
	nmap('td', '<cmd>Telescope diagnostic<cr> ')
	nmap('tb', '<cmd>Telescope git_branches<cr>')
	nmap('tg', '<cmd>Telescope git_status<cr>')
	nmap('tn', '<cmd>Telescope loclist<cr> ')
	nmap('tc', '<cmd>Telescope commands <cr> ')
	nmap('th', '<cmd>Telescope help_tags<cr> ') -- nivm api
	nmap('tH', '<cmd>Telescope command_history<cr> ')
	nmap('tk', '<cmd>Telescope keymaps<cr>')
	nmap('tf', '<cmd>Telescope file_browser<cr>') -- can go to the parent dir
	nmap('tr', '<cmd>Telescope registers<cr>')
	nmap('tS', '<cmd>Telescope spell_suggest<cr>')
	nmap('t/', '<cmd>Telescope search_history<cr> ')
	nmap('t1', '<cmd>Telescope man_pages<cr>')
	nmap('tC', '<cmd>Telescope colorscheme<cr>')
	nmap('tm', '<cmd>Telescope marks<cr>') -- list of the pickers
	nmap('ti', '<cmd>Telescope<cr>') -- list of the pickers

	-- nmap('tt', ':silent !ctags -R . <CR>:redraw!<cr>:Telescope current_buffer_tags<CR>')
	-- nmap('T', ':silent !ctags -R . <CR>:redraw!<cr>:Telescope tags<CR>') -- jjjj
	telescope.load_extension 'heading'
	nmap('tt', '<cmd>Telescope heading <cr>')
	telescope.load_extension 'jumps'
	nmap('tu', '<cmd>Telescope jumps changes <cr>')
	nmap('tj', '<cmd>Telescope jumps jumpbuff <cr>')
	telescope.load_extension 'luasnip'
	nmap('tU', '<cmd>Telescope luasnip <cr>')
	telescope.load_extension('smart_open')
	-- { cwd_only = true, } limit to current directory; does not support smart-case
	nmap('<c-f>', '<cmd>Telescope smart_open <cr>')
	-- telescope.load_extension("yank_history") 
	-- nmap('ty', '<cmd>Telescope yank_history <cr>')
end -- }}} 

-- urlview {{{ 
-- https://github.com/axieax/urlview.nvim
nmap('<Leader>u', ':UrlView<cr>') 
-- }}} 

-- previm {{{
--  https://github.com/previm/previm
vim.g.previm_open_cmd = 'firefox'
nmap('<leader>v', ':PrevimOpen <CR>')
-- vim.g.previm_enable_realtime =  1
-- to change style turn 0 to 1 in previm_disable_default_css and put path to
vim.g.previm_disable_default_css = 1
vim.g.previm_custom_css_path = HOME .. '/.config/nvim/custom/md-prev.css' -- }}} 

-- yanky {{{
	-- maybe causes crash
-- https://github.com/gbprod/yanky.nvim#%EF%B8%8F-special-put
nmap('p', "<Plug>(YankyPutAfter)", { noremap = false })
nmap('P', "<Plug>(YankyPutAfterLinewise)", { noremap = false })
-- nmap('y', "<Plug>(YankyYank)", { noremap = false }) -- preserve_cursor_position
nmap('<c-p>', ':YankyRingHistory <cr>') -- list; can be manage by Telescope
xmap('p', "<Plug>(YankyPutAfter)", { noremap = false })
nmap("<A-n>", "<Plug>(YankyCycleForward)", { noremap = false })
nmap("<A-p>", "<Plug>(YankyCycleBackward)", { noremap = false }) 
-- }}} 

-- nvim-cmp {{{
-- https://github.com/hrsh7th/nvim-cmp
local cmp = require 'cmp'
cmp.setup {
    snippet = {
      expand = function(args)
        require'luasnip'.lsp_expand(args.body)
      end
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
		{ name = 'luasnip', keyword_length = 1 }, 
		{ name = 'buffer', keyword_length = 2, option = { keyword_pattern = [[\k\+]] } },
		{ name = 'nvim_lua' },
		{ name = 'nvim_lsp' },
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
				luasnip = '',
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

local dict = require("cmp_dictionary")

dict.switcher({
  filetype = {
	asciidoctor = {dirEn, dirPl },
	markdown = {dirEn, dirPl },
	text = {dirEn, dirPl },
  },
 --  filepath = { ["%.tmux.*%.conf"] = { "/path/to/js.dict", "/path/to/js2.dict" }, },
  -- spelllang = { en = "/path/to/english.dict", },
})
dict.setup {
	exact = 4, -- -1 only exact the same prefix; should be gratter than keyword_length
	capacity = 5,
	debug = false,
} 
-- }}} 

-- nullLs {{{
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
-- }}} 

-- gitsigns {{{
require('gitsigns').setup {
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns
		-- Navigation
		vim.keymap.set('n', ',n', function()
			if vim.wo.diff then
				return ',n'
			end
			vim.schedule(function()
				gs.next_hunk()
			end)
			return '<Ignore>'
		end, { expr = true, buffer = bufnr })

		vim.keymap.set('n', ',p', function()
			if vim.wo.diff then
				return ',p'
			end
			vim.schedule(function()
				gs.prev_hunk()
			end)
			return '<Ignore>'
		end, { expr = true, buffer = bufnr })
		-- can be convert to  vim.keymap.set
		-- Actions
		nmap(',r', ':Gitsigns reset_hunk<CR>')
		vmap(',r', ':Gitsigns reset_hunk<CR>')
		nmap(',s', '<cmd>Gitsigns preview_hunk<CR>')
		nmap(',d', '<cmd>Gitsigns diffthis<CR>')
		nmap(',D', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
		nmap(',t', '<cmd>Gitsigns toggle_deleted<CR>')

		-- Text object
		omap('oh', ':<C-U>Gitsigns select_hunk<CR>')
		xmap('oh', ':<C-U>Gitsigns select_hunk<CR>')
	end,
} -- }}} 

-- translate {{{
--https://github.com/uga-rosa/translate.nvim
-- let g:deepl_api_auth_key = 'MY_AUTH_KEY'
-- command = "deepl_free", -- require credit card
xmap('<LocalLeader>ee', '<Cmd>Translate EN -source=PL<CR>')
nmap('<LocalLeader>ee', '<Cmd>Translate EN -source=PL<CR>')
nmap('<LocalLeader>er', 'viw:Translate EN -source=PL -output=replace<CR>') 
xmap('<LocalLeader>er', 'viw:Translate EN -source=PL -output=replace<CR>') 
nmap('<LocalLeader>pp', '<Cmd>Translate PL -source=EN<CR>')
xmap('<LocalLeader>pp', '<Cmd>Translate PL -source=EN<CR>')
nmap('<LocalLeader>pr', 'viw:Translate PL -source=EN -output=replace<CR>') 
xmap('<LocalLeader>pr', 'viw:Translate PL -source=EN -output=replace<CR>') 
-- }}} 

-- grammarous {{{
vim.g['grammarous#use_vim_spelllang'] = 1
-- vim.g['grammarous#enable_spell_check'] = 1
-- https://github.com/rhysd/vim-grammarous/issues/110#issuecomment-1404863074
vim.g['grammarous#jar_url'] = 'https://www.languagetool.org/download/LanguageTool-5.9.zip' 
nmap('<LocalLeader>cc', '<cmd>GrammarousCheck --lang=en<CR>')
nmap('<LocalLeader>cp', '<cmd>GrammarousCheck --lang=pl <CR>')
nmap('<LocalLeader>ch', '<Plug>(grammarous-move-to-previous-error)', { noremap = false }) -- Move cursor to the previous error
nmap('<LocalLeader>cl', '<Plug>(grammarous-move-to-next-error)', { noremap = false }) -- Move cursor to the next error
nmap('<LocalLeader>cf', '<Plug>(grammarous-fixit)', { noremap = false }) --	Fix the error under the cursor automatically
 -- }}} 

-- nap-nvim {{{
require("nap").setup({
    next_prefix = "<a-o>",
    prev_prefix = "<a-i>",
    next_repeat = "<c-o>",
    prev_repeat = "<c-i>",
    operators = {   ["c"] = {
        next = { rhs = '<Plug>(grammarous-move-to-next-error)', opts = {desc = "grammarous-move-to-next", noremap = false} },
        prev = { rhs = '<Plug>(grammarous-move-to-previous-error)', opts = {desc = "grammarous-move-to-prev", noremap = false} },
        mode = { "n" },
    }, },
})
-- }}} 

-- ZenMode {{{
-- https://github.com/folke/zen-mode.nvim
nmap('<F6>', ':ZenMode <CR>')
-- }}} 

-- LuaSnip {{{
nmap('<F5>', '<cmd>lua require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/luasnippets/"})<cr>')
nmap('<F17>', '<cmd>lua require("luasnip.loaders").edit_snippet_files()<CR>') -- S-F5
local ls = require("luasnip")
-- tab in insert mode stopped work
-- vim.keymap.set({"i", "s"}, "<TAB>", function() if ls.expand_or_jumpable() then ls.expand_or_jump() end end, {silent = true})
-- vim.keymap.set({"i", "s"}, "<S-TAB>", function() ls.jump(-1) end, {silent = true})

vim.cmd[[
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>' 
imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>' 
smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>' 
]]

vim.keymap.set({"i", "s"}, "<C-h>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end, {silent = true, desc = 'luasnip next choice' })
-- }}} 

--{{{ ogpt https://github.com/huynle/ogpt.nvim
key('n', '<LocalLeader>oo', '<cmd>OGPT<CR>', {desc = 'OGPT'} )
key('n', '<LocalLeader>oa', '<cmd>OGPTActAs<CR>', {desc = 'OGPTActAs'} )
key({ "n", "v" }, '<LocalLeader>oe', "<cmd>OGPTEditWithInstruction<CR>", { desc = "Edit with instruction",  })
key({ "n", "v" }, '<LocalLeader>oc', "<cmd>OGPTRun grammar-append<CR>", { desc = "Grammar Correction",  })
key({ "n", "v" }, '<LocalLeader>ol', "<cmd>OGPTRun translate-append<CR>", { desc = "Translate to english",  })
key({ "n", "v" }, '<LocalLeader>oL', "<cmd>OGPTRun translate-append polish<CR>", { desc = "Translate to polish",  })
key({ "n", "v" }, '<LocalLeader>ok', "<cmd>OGPTRun keywords<CR>", { desc = "Keywords",  })
key({ "n", "v" }, '<LocalLeader>oj', "<cmd>OGPTRun javdoc<CR>", { desc = "Java documentation",  })
key({ "n", "v" }, '<LocalLeader>ot', "<cmd>OGPTRun add_tests<CR>", { desc = "Add Tests",  })
key({ "n", "v" }, '<LocalLeader>oi', "<cmd>OGPTRun optimize_code<CR>", { desc = "Optimize Code",  })
key({ "n", "v" }, '<LocalLeader>os', "<cmd>OGPTRun summarize<CR>", { desc = "Summarize",  })
key({ "n", "v" }, '<LocalLeader>ob', "<cmd>OGPTRun fix_bugs<CR>", { desc = "Fix Bugs",  })
key({ "n", "v" }, '<LocalLeader>ox', "<cmd>OGPTRun explain_code<CR>", { desc = "Explain Code",  })
key({ "n", "v" }, '<LocalLeader>or', "<cmd>OGPTRun code_readability_analysis<CR>", { desc = "Code Readability Analysis",  })
key({ "n", "v" }, '<LocalLeader>of', "<cmd>OGPTRun format-adoc table<CR>", { desc = "Format asciidoc table",  })
--}}} 

-- COLORSCHEMES {{{
local function getBackground(hour)
		local hour = hour and hour or 20
		local currentHour = tonumber(os.date '%H')
		if currentHour > 5 and currentHour < hour then
			return 'light'
		else
			return 'dark'
		end
end
vim.cmd 'colorscheme solarized8_high'
-- vim.cmd 'colorscheme flattened_light'
vim.o.background = getBackground()
-- vim.cmd [[let ayucolor="light" ]]
-- }}} 
-- vim: foldmethod=marker
-- set complete+=kspell spellcheck complete
