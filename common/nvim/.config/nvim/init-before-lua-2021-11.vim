" S-k - jump to help page 
""""""""""""""""""""""""""
"""""" PLUGINS

" vim-plug plugin manager
call plug#begin()
Plug 'Pocco81/AutoSave.nvim', {'branch': 'main'}
Plug 'justincampbell/vim-eighties' " Automatically resizes your windows
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'tpope/vim-repeat'
Plug 'MattesGroeger/vim-bookmarks'
Plug 'majutsushi/tagbar'
Plug 'SirVer/ultisnips'
Plug 'mhinz/vim-startify' "start screen
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'} 
Plug 'vim-scripts/YankRing.vim' " fix keybinding
" CODE
Plug 'tpope/vim-surround'
Plug 'sbdchd/neoformat', { 'on': 'Neoformat'}
Plug 'dense-analysis/ale', {'on': 'ALELint'}

" NOTE
Plug 'itchyny/calendar.vim', {'on': 'Calendar'} " problem with api
Plug 'aserebryakov/vim-todo-lists', {'tag': '0.7.1'}
Plug 'kabbamine/lazyList.vim', { 'on': 'LazyList'}
" asciidoctor
Plug 'habamax/vim-asciidoctor', {'for': 'asciidoctor'}
" markdown 
Plug 'plasticboy/vim-markdown', { 'for': 'markdown', 'frozen': 1}
Plug 'kannokanno/previm', { 'for': 'markdown'}
Plug 'godlygeek/tabular', { 'for': 'markdown'} " do wyrównywania np w tabelach http://vimcasts.org/episodes/aligning-text-with-tabular-vim/ :Tab /|

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"Syntax
Plug 'baskerville/vim-sxhkdrc'

" for neovim and lua
Plug 'gennaro-tedesco/nvim-jqx', {'for': 'json'}
Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua', {'on': 'NvimTreeToggle'}
Plug 'b3nj5m1n/kommentary', {'branch': 'main'}
Plug 'windwp/nvim-autopairs'
Plug 'NTBBloodbath/rest.nvim', {'branch': 'main'}
Plug 'phaazon/hop.nvim'
Plug 'hrsh7th/nvim-compe'
Plug 'folke/zen-mode.nvim', {'branch': 'main', 'on': 'ZenMode'}

" for telescope
Plug 'nvim-lua/popup.nvim' | Plug 'nvim-lua/plenary.nvim' | Plug 'nvim-telescope/telescope.nvim'

" COLORSCHEMES
" https://www.dunebook.com/best-vim-themes/
" https://vimcolorschemes.com/top
" ayu, vim-one, one-half, drakula NeoSolarized, pepertheme
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'https://github.com/rakr/vim-one'
" Plug 'iCyMind/NeoSolarized'
" Plug 'patstockwell/vim-monokai-tasty'

call plug#end()

" COLORSCHEMES
let scheme = strftime("%H") > 5 && strftime("%H") < 18 ? "one" : "dracula"
execute 'colorscheme ' . scheme
let &background =strftime("%H") > 5 && strftime("%H") < 18 ? "light" : "dark"

" colorscheme dracula
" vime-one - support dark and light theme
" set background=dark
" let g:one_allow_italics = 1 

""""""""""""""""""""""""""
"""""" SETTINGS

if (empty($TMUX))
  if (has("termguicolors"))
    set termguicolors
  endif
endif
if &term == "screen"
  set t_Co=256
endif
syntax enable
set laststatus=2
" podpowiedzi
set wildmode=longest,list,full
"" Status bar
filetype plugin indent on
set encoding=utf-8 fileencoding=utf-8 fileencodings=utf-8,latin1
set linebreak
" foldmethod for config files but it folds when you open the file
" set foldmethod=marker
" set foldmarker={{{,}}}

if exists('$SHELL')
    set shell=$SHELL
else
    set shell=/bin/sh
endif

autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif 
" filetype assossiation
au BufRead,BufNewFile *.txt set filetype=zim
au BufRead,BufNewFile *.json set filetype=json
autocmd BufNewFile,BufRead \*.{md,mdwn,mkd,mkdn,mark,markdown\*} set filetype=markdown
" nie trzeba dodawac spacji na koniec pliku dla markdown
" autocmd Filetype markdown setlocal linebreak
" autocmd Filetype markdown setlocal wrap
" will be in 5 version of the nvim
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank {timeout=600}
augroup END
" IncSearch
set ignorecase smartcase hlsearch incsearch
set number " relativenumber
" substitution 
set inccommand=split
set clipboard^=unnamedplus
" set clipboard=unnamed,unnamedplus almost good
" set clipboard=unnamed "second clipboard
" I don't work in tmux
" set clipboard+=unnamedplus
" set tab to 4 columns 
set shiftwidth=4 tabstop=4 softtabstop=4
set scrolloff=5 " margin
set hidden
"" highlighting cursor
set cursorline cursorcolumn

" maybe 
"set nobackup
"set mouse=a
"""""""""""""""""""
"""""" SHORTCUTS
"" change leader key from \ to ;
let mapleader=";"
nnoremap <leader>/ :nohlsearch<cr>
map <F5> :source $HOME/.config/nvim/init.vim <cr>
nnoremap Zz :q! <cr> 
" move lines up and down
nnoremap <c-a-j> :m .+1<CR>
nnoremap <c-a-k> :m .-2<CR>
inoremap <c-A-j> <Esc>:m .+1<CR>==gi
inoremap <c-A-k> <Esc>:m .-2<CR>==gi
vnoremap <c-a-j> :m '>+1<CR>gv=gv
vnoremap <c-a-k> :m '<-2<CR>gv=gv
" jump to last edited location
nnoremap <C-i> g; <cr> 
nnoremap <C-o> g, <cr> 
" page scroll
nnoremap <Space> <C-f> <cr> 
nnoremap <C-k> <C-b> <cr> 
"folds
nnoremap zn z] <cr> 
nnoremap zp z[ <cr> 
nnoremap zo zO <cr> 
nnoremap zO zo <cr> 
" open file with folds
" set foldlevelstart=1
" saving 2x esc
map <Esc><Esc> :w<CR>
" leader to backslash \w zapisywanie jako root
map <leader>sudo :w !sudo tee % <CR><CR>
" coping and pasting 
nmap Y y$
nmap P :pu<CR>
"" insert mode
" move to the nexst/previous word
inoremap <C-a> <C-o>b
inoremap <C-d> <C-o>w
"change word
inoremap <C-e> <Esc>ciw

" Tabs
nmap <tab> gt
nmap <s-tab> gT
nnoremap <C-t> :tabnew<CR>

" windows split also in terminal mode
:tnoremap <A-h> <C-\><C-N><C-w>h
:tnoremap <A-j> <C-\><C-N><C-w>j
:tnoremap <A-k> <C-\><C-N><C-w>k
:tnoremap <A-l> <C-\><C-N><C-w>l
:inoremap <A-h> <C-\><C-N><C-w>h
:inoremap <A-j> <C-\><C-N><C-w>j
:inoremap <A-k> <C-\><C-N><C-w>k
:inoremap <A-l> <C-\><C-N><C-w>l
:nnoremap <A-h> <C-w>h
:nnoremap <A-j> <C-w>j
:nnoremap <A-k> <C-w>k
:nnoremap <A-l> <C-w>l

" go to the line 
:nnoremap <A-S-j> gj
:nnoremap <A-S-k> gk
:inoremap <A-S-j> <Esc>gj
:inoremap <A-S-k> <Esc>gk

" Terminal
" Make escape work in the Neovim terminal.
tnoremap <Esc> <C-\><C-n>
" Prefer Neovim terminal insert mode to normal mode.
autocmd BufEnter term://* startinsert
map <F2> :vsplit term://zsh<cr>
map <S-F2> :split term://zsh<cr>

"""""""""""""""""""
"""""" NOTE TAKING
" open typora
silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)
nnoremap <F8> :exe ':silent !typora %'<CR>
"dictionary
syntax spell toplevel
" au BufReadPost *.adoc,*.md setlocal spell spelllang=pl_PL,en_us
"togle spellcheck
nmap <leader>s :set spell!<cr> 
" nmap <leader>sp :setlocal spell! spelllang=pl<cr> :syntax spell toplevel<cr>
nmap <leader>sp :setlocal spell! spelllang=pl<cr>
" nmap <leader>se :set spelllang=en_us<CR>
nmap <leader>se :setlocal spell! spelllang=en_us<CR>
nnoremap <C-e> z= 
nnoremap <S-e> [s 
nnoremap <C-]> ]s
" doesn't work <C-[> 
"replace from selection/ substitution
vnoremap <A-r> "hy:%s/<C-r>h//g<left><left><left> 

"""""""""""""""""""
" TEXT OBJECTS
"""""""""""""""""""
" current line - doesn't work ^vg_ triming spaces in the end
" TODO ^o$h doesn't work
" xnoremap il ^o$h 
xnoremap il ^vg_
onoremap il :normal vil<CR>

"""""""""""""""""""
"""""" MAKRA
"""" kindle put cursor on ===
let @k='V3jd2j'

"""""" adoc
" plus na koncu linii p
let @p='$a  +j0'
let @l='pA['

"""""" markdown
" dwie spacje na koncu linii s  
let @s='$a  j0'
" bookmarks should copy word
let @z='ggO- (pbi#bi[po'
" add hiperlink, start from last sing of the word
"links
let @h='a]()hp0i['
let @t='f)a kb  '
" listy generowane z pluginu
" lista numerowana n  
" let @n='ll0i1. j0'
" lista nienumerowana i 
" let @i='0i- j0'

"""""""""""""""""""
"""" PLUGINS
"""""""""""""""""""

"""""""""""""""""""
" calendar.vim
let g:calendar_google_calendar = 1
let g:calendar_google_task = 1
let g:calendar_first_day = 'monday'

nmap <F9> :Calendar <CR>
nmap <S-F9> :Calendar -view=year -split=horizontal -position=below -height=10 <CR>

"""""""""""""""""""
" vim-bookmarks
let g:bookmark_auto_close = 1

"""""""""""""""""""
" undo tree
nnoremap <A-u> :UndotreeToggle<cr>

if has("persistent_undo")
	set undodir=$HOME/.local/share/nvim/undo
	set undofile
endif

"""""""""""""""""""
" lazyList 
nnoremap gll :LazyList '- '<CR>
vnoremap gll :LazyList '- '<CR>
nnoremap gl* :LazyList '* '<CR>
vnoremap gl* :LazyList '* '<CR>
nnoremap gln :LazyList '1. '<CR>
vnoremap gln :LazyList '1. '<CR>
nnoremap glz :LazyList '[ ] '<CR>
vnoremap glz :LazyList '[ ] '<CR>
nnoremap gl1 :LazyList '# '<CR>
vnoremap gl1 :LazyList '# '<CR>
nnoremap gl2 :LazyList '## '<CR>
vnoremap gl2 :LazyList '## '<CR>
nnoremap gl3 :LazyList '### '<CR>
vnoremap gl3 :LazyList '### '<CR>
nnoremap gl4 :LazyList '#### '<CR>
vnoremap gl4 :LazyList '#### '<CR>
nnoremap gl5 :LazyList '##### '<CR>
vnoremap gl5 :LazyList '##### '<CR>


"""""""""""""""""""
" startify disable changing dir
let g:startify_change_to_dir = 0

""""""""""""""""""
" repeat 
silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)

" ZenMode more readable text
nmap <F6> :ZenMode <CR>

"""""""""""""""""""
" TAGBAR
nmap <leader>t :TagbarToggle<CR>
" nmap tt :Toc<CR>
let g:tagbar_autoclose = 1
let g:tagbar_autofocus = 1
let g:tagbar_zoomwidth = 0
let g:tagbar_sort = 0
set conceallevel=3

"""""""""""""""""""
" vim-asciidoctor  https://github.com/habamax/vim-asciidoctor
nnoremap <F7> :silent !preview-ascii.sh % <CR>
nnoremap <S-F7> :silent Asciidoctor2DOCX<CR>

let g:asciidoctor_syntax_conceal = 1
let g:asciidoctor_folding = 1
let g:asciidoctor_folding_level = 6
let g:asciidoctor_fenced_languages = ['java', 'typescript', 'javascript']
" let g:asciidoctor_syntax_indented = 0
" let g:asciidoctor_fold_options = 0
let g:asciidoctor_img_paste_command = 'xclip -selection clipboard -t image/png -o > %s%s'
nnoremap <A-p> :AsciidoctorPasteImage<CR>

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

"vim-markdown syntax
" let g:vim_markdown_fenced_languages = ['java=java']
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_folding = 0
let g:vim_markdown_fold_options = 0
" let g:vim_markdown_folding_level = 6
" let g:vim_markdown_folding_style_pythonic = 1
let g:tagbar_type_markdown = {
    \ 'ctagstype' : 'markdown',
    \ 'kinds' : [
        \ 'h:table of contents',
    \ ]
\ }


"""""""""""""""""""
" previm
let g:previm_open_cmd = 'firefox'
nmap <leader>v :PrevimOpen <CR>
" let g:previm_enable_realtime =  1
" to change style turn 0 to 1 in previm_disable_default_css and put path to
let g:previm_disable_default_css = 1
let g:previm_custom_css_path = '~/.config/nvim/custom/md-prev.css'

"""""""""""""""""""
" eighties automatyczne dostosowanie okien
let g:eighties_enabled = 1
let g:eighties_minimum_width = 80
let g:eighties_extra_width = 0 " Increase this if you want some extra room
let g:eighties_compute = 1 " Disable this if you just want the minimum + extra
let g:eighties_bufname_additional_patterns = ['fugitiveblame'] " Defaults to [], 'fugitiveblame' is only an example. Takes a comma delimited list of bufnames as strings.

"""""""""""""""""""
" vim-airline
let g:airline_theme='dracula'
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1

" ALE
let g:airline#extensions#ale#enabled = 0

"vim-airline toolbar
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

if !exists('g:airline_powerline_fonts')
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'
  let g:airline_left_sep          = '▶'
  let g:airline_left_alt_sep      = '»'
  let g:airline_right_sep         = '◀'
  let g:airline_right_alt_sep     = '«'
  let g:airline#extensions#branch#prefix     = '⤴' "➔, ➥, ⎇
  let g:airline#extensions#readonly#symbol   = '⊘'
  let g:airline#extensions#linecolumn#prefix = '¶'
  let g:airline#extensions#paste#symbol      = 'ρ'
  let g:airline_symbols.linenr    = '␊'
  let g:airline_symbols.branch    = '⎇'
  let g:airline_symbols.paste     = 'ρ'
  let g:airline_symbols.paste     = 'Þ'
  let g:airline_symbols.paste     = '∥'
  let g:airline_symbols.whitespace = 'Ξ'
else
  let g:airline#extensions#tabline#left_sep = ''
  let g:airline#extensions#tabline#left_alt_sep = ''

  " powerline symbols
  let g:airline_left_sep = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''
  let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ''
endif

"""""""""""""""""""
" ultisnips
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsExpandTrigger='<c-l>'
" shortcut to go to next position
let g:UltiSnipsJumpForwardTrigger='<c-l>'
" shortcut to go to previous position
let g:UltiSnipsJumpBackwardTrigger='<c-k>'
" let g:UltiSnipsSnippetDirectories=["custom-snip"]
"
"""""""""""""""""""
" hop, easymotion alternative
"https://github.com/phaazon/hop.nvim
lua require'hop'.setup()

map F <cmd>HopChar1 <cr>
map f <cmd>HopChar2 <cr>
map <leader>w <cmd>HopWordAC <cr>
map <leader>W <cmd>HopWordBC <cr>
map s <cmd>HopLineStartAC <cr>
map S <cmd>HopLineStartBC <cr>


"""""""""""""""""""
" compe https://github.com/hrsh7th/nvim-compe
set completeopt=menuone,noselect
let g:compe = {}
let g:compe.enabled = v:true
let g:compe.default_pattern = '\k\+'
let g:compe.source = {}
let g:compe.source.path = v:true
let g:compe.source.buffer = v:true
let g:compe.source.calc = v:true
let g:compe.source.emoji = v:true
let g:compe.source.nvim_lsp = v:true
let g:compe.source.nvim_lua = v:true
let g:compe.source.ultisnips = v:true
" let g:compe.source.spell = v:true

inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <A-Space>     compe#close('<A-Space>')
inoremap <silent><expr> <CR>      compe#confirm({ 'keys': '<CR>', 'select': v:true })
inoremap <silent><expr> <C-j>     compe#scroll({ 'delta': +1 }) " doesn't work
inoremap <silent><expr> <C-k>     compe#scroll({ 'delta': -1 })

"""""""""""""""""""
"  Telescope
" https://github.com/nvim-telescope/telescope.nvim#pickers
nnoremap <c-s> <cmd>Telescope live_grep<cr>
nnoremap <c-f> <cmd>Telescope find_files<cr>
nnoremap tp <cmd>Telescope find_files find_command=rg,--hidden,--files<cr>
nnoremap tl <cmd>Telescope<cr>
" nnoremap tl <cmd>Telescope loclist<cr> 
nnoremap tj <cmd>Telescope jumplist<cr> 
nnoremap tf <cmd>Telescope file_browser<cr>
nnoremap tz <cmd>Telescope current_buffer_fuzzy_find<cr>
nnoremap tb <cmd>Telescope buffers<cr>
nnoremap to <cmd>Telescope oldfiles<cr>
nnoremap tr <cmd>Telescope registers<cr>
nnoremap ts <cmd>Telescope spell_suggest<cr>
nnoremap th <cmd>Telescope search_history<cr> 
nnoremap tH <cmd>Telescope command_history<cr> 
nnoremap tt :silent !ctags -R . <CR>:redraw!<cr>:Telescope current_buffer_tags<CR>
nnoremap T :silent !ctags -R . <CR>:redraw!<cr>:Telescope tags<CR>
nnoremap tm <cmd>Telescope marks<cr>
nnoremap tM <cmd>Telescope man_pages<cr>
nnoremap tg <cmd>Telescope git_status<cr>
nnoremap tk <cmd>Telescope keymaps<cr>
nnoremap tc <cmd>Telescope colorscheme<cr>

lua require('telescope').setup({ defaults = {file_ignore_patterns = {"tags"}, layout_strategy = 'flex', width_padding = 0, layout_config = { horizontal = { width = 0.99 }, vertical = {width = 0.9, height = 0.99, preview_height = 0.75 } }}})
set maxmempattern=3000 " fix pattern uses more memory than 'maxmempattern', default is 2000

"""""""""""""""""""
" NvimTreeToggle https://github.com/kyazdani42/nvim-tree.lua
nnoremap <F3> :NvimTreeToggle<CR>

"""""""""""""""""""
" jqx https://github.com/gennaro-tedesco/nvim-jqx
nmap <leader>x <Plug>JqxList

"""""""""""""""""""
" rest https://github.com/NTBBloodbath/rest.nvim#usage
lua require('rest-nvim').setup()
nmap <leader>r <Plug>RestNvim<cr>
nmap <leader>rr <Plug>RestNvimLast<cr>
nmap <leader>rp <Plug>RestNvimPreview<cr>

"""""""""""""""""""
" turn on plugins
lua require('nvim-autopairs').setup()
lua require('autosave').setup({ enabled = true, events = {"InsertLeave"} })

"""""""""""""""""""
" visual multi https://github.com/mg979/vim-visual-multi/wiki/Mappings
let g:VM_maps = {}
let g:VM_maps['Find Under']                  = '<A-n>'
let g:VM_maps['Find Subword Under']          = '<A-n>'
let g:VM_maps["Select All"]                  = '<C-A-n>' 
let g:VM_maps["Visual All"]                  = '<C-A-n>' 

"""""""""""""""""""
" YankRing https://github.com/vim-scripts/YankRing.vim
let g:yankring_history_dir = '~/.local/share/nvim'
let g:yankring_min_element_length = 3
let g:yankring_default_menu_mode = 3

"""""""""""""""""""
" https://github.com/sbdchd/neoformat
noremap  <a-f> :Neoformat! java astyle <CR>
vnoremap  <a-f> :Neoformat! java astyle <CR>


"https://github.com/dense-analysis/ale
" disable checking, can by run by saving or ALELint
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_enter = 0
let g:ale_lint_on_save = 1

