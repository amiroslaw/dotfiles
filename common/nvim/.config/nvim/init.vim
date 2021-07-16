""""""""""""""""""""""""""
"""""" PLUGINS

" vim-plug plugin manager
call plug#begin()
" Plug 'https://github.com/ctrlpvim/ctrlp.vim'
" Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle'}
Plug 'vifm/vifm.vim'
Plug '907th/vim-auto-save'
" Plug 'vifm/neovim-vifm'
Plug 'mbbill/undotree'
Plug 'rking/ag.vim' " silver search I don't need it if I use 
Plug 'junegunn/goyo.vim', { 'on': 'Goyo'} " zen mode
Plug 'dbmrq/vim-ditto' "plugin that highlights overused words.
Plug 'ryanoasis/vim-devicons'
Plug 'vim-scripts/CSApprox'  
Plug 'justincampbell/vim-eighties' " Automatically resizes your windows
Plug 'junegunn/vim-peekaboo' "extended register
Plug 'tpope/vim-surround'
Plug 'raimondi/delimitmate' "closing brackets and quotes
Plug 'tpope/vim-commentary' 
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
" Plug 'terryma/vim-multiple-cursors' deprecated
" Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-repeat'
Plug 'easymotion/vim-easymotion'
" Plug 'justinmk/vim-sneak'
Plug 'mhinz/vim-startify' "start screen
Plug 'kabbamine/lazyList.vim' 
Plug 'aserebryakov/vim-todo-lists', {'tag': '0.7.1'}
Plug 'MattesGroeger/vim-bookmarks'
Plug 'itchyny/calendar.vim'
"tests
" Plug 'ashisha/image.vim'
" syntax
Plug 'potatoesmaster/i3-vim-syntax'
Plug 'leafgarland/typescript-vim'

" asciidoctor
Plug 'habamax/vim-asciidoctor'
Plug 'SirVer/ultisnips'
" markdown 
Plug 'plasticboy/vim-markdown', { 'for': 'markdown', 'frozen': 1}
Plug 'kannokanno/previm', { 'for': 'markdown'}
Plug 'godlygeek/tabular', { 'for': 'markdown'}
" do wyrównywania np w tabelach
" http://vimcasts.org/episodes/aligning-text-with-tabular-vim/
" :Tab /|
Plug 'majutsushi/tagbar'
" Plug 'lvht/tagbar-markdown'

" for neovim 
Plug 'shougo/denite.nvim' "ctrlpish 
Plug 'brooth/far.vim' "find and replace in few files
Plug 'rafi/awesome-vim-colorschemes'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'BurningEther/nvimux'
"Plug 'euclio/vim-markdown-composer'
" Plug 'cazador481/fakeclip.neovim'
" TextYankPost insted plugin from 5 version of nvim
" Plug 'machakann/vim-highlightedyank'
" colorschemes
" Plug 'arcticicestudio/nord-vim', { 'branch': 'develop' }
Plug 'https://github.com/rakr/vim-one'
" Plug 'iCyMind/NeoSolarized'
"completion 
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
" Plug 'roxma/nvim-completion-manager'
call plug#end()

""""""""""""""""""""""""""
"""""" SETTINGS

"""" colour settings
" https://www.dunebook.com/best-vim-themes/
" https://vimcolorschemes.com/top
" ayu, nord, vim-one, one-half, drakula NeoSolarized, pepertheme
" let g:neosolarized_italic = 1
if (empty($TMUX))
  if (has("termguicolors"))
    set termguicolors
  endif
endif
" vime-one - support dark and light theme
let g:one_allow_italics = 1 " I love italic for comments
set background=light   
colorscheme one
if &term == "screen"
  set t_Co=256
endif
syntax enable
set laststatus=2
" podpowiedzi
set wildmode=longest,list,full
" tmux  for version before 2.2
" set t_8f=[38;2;%lu;%lu;%lum
" set t_8b=[48;2;%lu;%lu;%lum
"" Status bar
" CSApprox plugin
let g:CSApprox_loaded = 1
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
set number relativenumber
" substitution 
set inccommand=split
set clipboard^=unnamedplus
" set clipboard=unnamed,unnamedplus almost good
" set clipboard=unnamed "second clipboard
" I don't work in tmux
" set clipboard+=unnamedplus
" set tab to 4 columns 
set shiftwidth=4 tabstop=4 softtabstop=4

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
" nmap <leader>/ :set hlsearch!<cr>
nnoremap <leader>/ :nohlsearch<cr>
" move lines up and down
nnoremap <c-a-j> :m .+1<CR>
nnoremap <c-a-k> :m .-2<CR>
inoremap <c-A-j> <Esc>:m .+1<CR>==gi
inoremap <c-A-k> <Esc>:m .-2<CR>==gi
vnoremap <c-a-j> :m '>+1<CR>gv=gv
vnoremap <c-a-k> :m '<-2<CR>gv=gv

" buffers
:nnoremap <leader>b :buffers<CR>:buffer<Space>
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
"zyy 
" "zyyggO- (pbi#bi[po
" zapisywanie kliknij 2x esc
map <Esc><Esc> :w<CR>
" leader to backslash \w zapisywanie jako root
map <leader>sudo :w !sudo tee % <CR><CR>
" NERDTree 
" let NERDTreeShowBookmarks=1
" map <C-n> :NERDTreeToggle <cr>
" vifm
map <leader>n :Vifm <cr>
let g:vifmSplitWidth = 10
" coping and pasting 
nmap Y y$
nmap P :pu<CR>

"save 
nmap <Leader>w <Esc>:w<CR>

"" insert mode
" move to the nesxt previous word
inoremap <C-a> <C-o>b
inoremap <C-d> <C-o>w
"change word
inoremap <C-e> <Esc>ciw
" poruszanie linii w insert mode może powodować problemy z wklejaniem 
" inoremap II <Esc>I
" inoremap AA <Esc>A
" inoremap OO <Esc>O

" Tabs
nnoremap <C-t> :tabnew<CR>
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabnext<CR>
nnoremap tk  :tabprev<CR>
nnoremap tl  :tablast<CR>
nmap <tab> gt
nmap <s-tab> gT
" nnoremap tt  :tabnext<CR> - ctag

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
" calculator c-s-a in insert mode 2+2 alt a
ino <M-a> <C-O>yiW<End>=<C-R>=<C-R>0<CR>
" Prefer Neovim terminal insert mode to normal mode.
autocmd BufEnter term://* startinsert

" bookmarks
" nnoremap mn ]'  <CR>
" nnoremap mp ['  <CR>

"""""""""""""""""""
"""""" NOTE TAKING
nnoremap ,t :silent !ctags -R . <CR>:redraw!<CR>:Denite tag<CR>
" open typora
silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)
nnoremap <leader>m :exe ':silent !typora %'<CR>
"slownik
syntax spell toplevel
au BufReadPost *.md setlocal spell spelllang=pl_pl,en_us
" au BufReadPost *.txt setlocal spell spelllang=pl
" togle spellcheck
nmap <leader>s :set spell!<cr>
nmap <leader>ss :setlocal spell! spelllang=pl<CR>
" nmap <leader>se :set spelllang=en_us<CR>
nmap <leader>se :setlocal spell! spelllang=en_us<CR>
"  
nnoremap <C-e> z= 
nnoremap <S-e> [s 
nnoremap <C-]> ]s
" don't work <C-[> 

"""""""""""""""""""
"""""" makra
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
" noremap <Leader>ee :%s/$/  /g <CR>  
" don't work map <Leader>ev :'<,'>s/$/  /g <CR>  
" vnoremap <Leader>ee :%s/\%V$/  /g  
" vnoremap <Leader>ee :s/$/  /g <CR>  

"adding empty line 
" let @e='o'

" AUTOSAVE I don't know if it is from plugin
" set updatetime=200
" autocmd CursorHoldI * silent w
"""""""""""""""""""
"""" PLUGINS
"""""""""""""""""""
"""""""""""""""""""
" AutoSave plugin
let g:auto_save = 1  " enable AutoSave on Vim startup
let g:auto_save_silent = 1  " do not display the auto-save notification
" calendar.vim
let g:calendar_google_calendar = 1
let g:calendar_google_task = 1
let g:calendar_first_day = 'monday'

nmap <leader>c :Calendar <CR>
nmap <leader>cs :Calendar -view=year -split=horizontal -position=below -height=10 <CR>
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

" Easy Motion
let g:EasyMotion_smartcase = 1
map f <Plug>(easymotion-f)
map F <Plug>(easymotion-F)
map t <Plug>(easymotion-w)
map T <Plug>(easymotion-b)
map <nowait> s <Plug>(easymotion-j)
map S <Plug>(easymotion-k)
nmap <leader>. <Plug>(easymotion-repeat)

" sneak 
" map ' <Plug>Sneak_;
" let g:sneak#label = 1
" let g:sneak#s_next = 1
" let g:sneak#use_ic_scs = 1
" map f <Plug>Sneak_s
" map F <Plug>Sneak_S
"""""""""""""""""""
" startify disable changing dir
let g:startify_change_to_dir = 0
"""""""""""""""""""
" denite 
" search files
" file/rec - files under search dir
map <c-f> :Denite grep:.<cr>
nnoremap <c-p> :Denite buffer file/rec<cr>
nnoremap <leader>p :Denite file/old<cr> i
nnoremap <leader>b :Denite buffer<cr>
" nnoremap <leader>b :Denite mark<cr>
nnoremap <leader>r :Denite register<cr>
" jump and lines  
nnoremap <leader>j :Denite jump<cr>
nnoremap <leader>l :Denite line<cr>
" Define mappings
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  nnoremap <silent><buffer><expr> p
  \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> v
  \ denite#do_map('do_action', 'vsplit')
  nnoremap <silent><buffer><expr> h
  \ denite#do_map('do_action', 'split')
  nnoremap <silent><buffer><expr> t
  \ denite#do_map('do_action', 'tabopen')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  nnoremap <silent><buffer><expr> i
  \ denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space>
  \ denite#do_map('toggle_select').'j'
endfunction

call denite#custom#source('grep', 'max_candidates', 3000)

" autocmd FileType denite-filter call s:denite_filter_my_settings()
" function! s:denite_filter_my_settings() abort
"   imap <silent><buffer> <C-o> <Plug>(denite_filter_quit)
" endfunction

" old version
" call denite#custom#map('insert', '<C-j>', '<denite:move_to_next_line>', 'noremap')
" call denite#custom#map('insert', '<C-k>', '<denite:move_to_previous_line>', 'noremap')
" call denite#custom#map('insert', '<C-t>', '<denite:do_action:tabopen>', 'noremap')
" call denite#custom#map('insert', '<C-v>', '<denite:do_action:vsplit>', 'noremap')
" call denite#custom#map('insert', '<C-h>', '<denite:do_action:split>', 'noremap')
""""""""""""""""""
" repeat 
silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)
" Goyo more readable text
nmap <leader>g :Goyo<CR>
" ditto' plugin that highlights overused words.
nmap <leader>d :ToggleDitto<CR>
"""""""""""""""""""

" Tagbar
nmap <leader>t :TagbarToggle<CR>
" nmap tt :Toc<CR>
let g:tagbar_autoclose = 1
let g:tagbar_autofocus = 1
let g:tagbar_zoomwidth = 0
let g:tagbar_sort = 0
set conceallevel=3
" asciidoctor
let g:asciidoctor_syntax_conceal = 1
let g:asciidoctor_folding = 1
let g:asciidoctor_folding_level = 6
let g:asciidoctor_fenced_languages = ['java', 'typescript', 'javascript']
" let g:asciidoctor_syntax_indented = 0
" let g:asciidoctor_fold_options = 0


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
" your style
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
" VIM DEVICONS and gui, terminal configuration will cover it
" fc-list :lnag=pl list of all fonts 
" set guifont=Monospace:h10
" set guifont=RoboMono\ Nerd\ Font\ 10
" set guifont=DroidSansMono\ Nerd\ Font\ Book:h11
" set guifont=Ubuntu\ Nerd\ Font:h10
"""""""""""""""""""
" vim-airline
let g:airline_theme = 'one'
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline_skip_empty_sections = 1


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
" DEOPLETE
"NEOCONPLETE to deople conversion 
set runtimepath+=~/.config/nvim/plugged/deoplete.nvim/
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use deoplete.
let g:deoplete#enable_at_startup = 1
" Set minimum syntax keyword length.
let g:deoplete#sources#syntax#min_keyword_length = 3
let g:deoplete#lock_buffer_name_pattern = '\*ku\*'

" deoplete tab-complete
" inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" Cycle through completion entries with tab/shift+tab
inoremap <expr> <s-tab> pumvisible() ? "\<c-p>" : "\<tab>"

inoremap <silent><expr> <TAB>
		\ pumvisible() ? "\<C-n>" :
		\ <SID>check_back_space() ? "\<TAB>" :
		\ deoplete#mappings#manual_complete()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" tern
autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR>

" don't copy tags
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return deoplete#close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction

" ultisnips
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsExpandTrigger='<c-l>'
let g:asciidoctor_img_paste_command = 'xclip -selection clipboard -t image/png -o > %s%s'
" shortcut to go to next position
let g:UltiSnipsJumpForwardTrigger='<c-l>'
" shortcut to go to previous position
let g:UltiSnipsJumpBackwardTrigger='<c-k>'
" let g:UltiSnipsSnippetDirectories=["custom-snip"]
nnoremap <A-p> :AsciidoctorPasteImage<CR>

" DEPRECATED
" Use smartcase. 
" let g:deoplete#enable_smart_case = 1

"will multiply mem usage
" let g:deoplete#num_processes = 2

" Define keyword.
" if !exists('g:deoplete#keyword_patterns')
"     let g:deoplete#keyword_patterns = {}
" endif
" let g:deoplete#keyword_patterns['default'] = '\h\w*'
"
" polish characters don't work
" if !exists('g:deoplete#keyword_patterns')
"   let g:deoplete#keyword_patterns = {}
" endif
" let g:deoplete#keyword_patterns['default'] = '[A-Za-zżźćńółęąśŻŹĆĄŚĘŁÓŃ][0-9A-Za-zżźćńółęąśŻŹĆĄŚĘŁÓŃ]*'

" let g:deoplete#keyword_patterns.tex = '[A-Za-zżźćńółęąśŻŹĆĄŚĘŁÓŃ][0-9A-Za-zżźćńółęąśŻŹĆĄŚĘŁÓŃ]\+'
" let g:neocomplete#keyword_patterns['markdown'] = '[À-ú[:alpha:]_][À-ú[:alnum:]_]*'
"
"""""""""""""""""""
" neosnippet 
" Plugin key-mappings.
" inoremap <expr><C-g>     deoplete#undo_completion()
" inoremap <expr><C-l>     deoplete#complete_common_string()
" imap <C-k>     <Plug>(neosnippet_expand_or_jump)
" smap <C-k>     <Plug>(neosnippet_expand_or_jump)
" xmap <C-k>     <Plug>(neosnippet_expand_target)

" I am not sure if it is needed
" inoremap <silent><expr><CR> pumvisible() ? deoplete#mappings#close_popup()."\<Plug>(neosnippet_expand_or_jump)" : "\<CR>"
"""""""""""""""""""
" old PLUGINS 
"""""""""""""""""""
"fakeclip	 
" let g:vim_fakeclip_tmux_plus=1 
" silver search ag
" map <C-f> :Ag!

"""""""""""""""""""
" CtrlP
 " let g:ctrlp_map = '<c-p>'
 " let g:ctrlp_cmd = 'CtrlP'


" " multiple cursor fix bug 
" func! Multiple_cursors_before()
"   if deoplete#is_enabled()
"     call deoplete#disable()
"     let g:deoplete_is_enable_before_multi_cursors = 1
"   else
"     let g:deoplete_is_enable_before_multi_cursors = 0
"   endif
" endfunc
" func! Multiple_cursors_after()
"   if g:deoplete_is_enable_before_multi_cursors
"     call deoplete#enable()
"   endif
" endfunc
