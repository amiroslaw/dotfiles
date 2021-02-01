" komentarze !!
" USTAWIENIA
" pathegen must by first
execute pathogen#infect()
set encoding=utf8
filetype plugin on
filetype on
set wildmenu
set omnifunc=syntaxcomplete#Complete
" kolorowanie 
syntax enable

" filetype assossiation
au BufRead,BufNewFile *.txt set filetype=zim
au BufRead,BufNewFile *.json set filetype=json
autocmd BufNewFile,BufRead \*.{md,mdwn,mkd,mkdn,mark,markdown\*} set filetype=markdown
" nie trzeba dodawac spacji na koniec pliku dla markdown
" autocmd Filetype markdown setlocal linebreak
" autocmd Filetype markdown setlocal wrap

 colorscheme solarized
 set background=dark 
  let g:solarized_termcolors=256
  let g:solarized_contrast="hight"
" zwijanie tekstu
" set foldenable 
" set foldmethod=syntax
" zapamietywanie widoku bez pluginu restore
"au BufWinLeave * mkview
"au BufWinEnter * silent loadview
:set ic 
set hlsearch

:command! -complete=file -nargs=1 Rpdf :r !pdftotext -nopgbrk <q-args> -
:command! -complete=file -nargs=1 Rpdf :r !pdftotext -nopgbrk <q-args> - |fmt -csw78
:set number
:set clipboard=unnamed
:set lbr!
" size of a hard tabstop
set tabstop=4
" size of an indent
set shiftwidth=4


" SHORTCUTS
" move lines up and down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
" nnoremap dK d$ → jest D
"makra
" lista numerowana n  
" lista nienumerowana i 
" dwie spacje na ko�cu linii s  
" zak�adka z 
let @n='ll0i1. j0'
let @i='0i- j0'
let @t='f)a�kb  '
let @s='$a  j0'
let @z='ggO- (pbi#bi[po'
let @l='o^[p'
" bookmarks
map <leader>b :marks<cr>
" page scroll
nnoremap <Space> <C-f> <cr> 
nnoremap <C-k> <C-b> <cr> 
"folds
nnoremap zn z] <cr> 
nnoremap zp z[ <cr> 
nnoremap zo zO <cr> 
nnoremap zO zo <cr> 
" nnoremap zm zM <cr> 
" nnoremap zM zm <cr> 
" nnoremap zr zR <cr> 
" nnoremap zR zr <cr> 
" zapisywanie kliknij 2x esc
map <Esc><Esc> :w<CR>
" leader to backslash \w zapisywanie jako root
map <leader>sudo :w !sudo tee % <CR><CR>
" silver search ag
map <C-f> :Ag!
" włączanie NERDTree i zawsze widoczne zakładki
let NERDTreeShowBookmarks=1
" map <silent>  <F11> NERDTreeToggle 
map <C-n> :NERDTreeToggle <cr>
" kopiowanie
nmap P "1p
:map <C-c>  "+y
:map <C-v>  "+p
:map <C-S-A> ggyG
:map <C-S-y> "zy
:map <C-S-p> "zp
:map Y y$

"slownik
syntax spell toplevel
au BufReadPost *.txt setlocal spell spelllang=pl
au BufReadPost *.md setlocal spell spelllang=pl
:map <leader>se :setlocal spell! spelllang=en_us<CR>
map <leader>s :set spell!<cr>
nnoremap <C-e> z= 
:map <C-a> ]s
":map <C-e> [s 
"au BufRead,BufNewFile *.txt set filetype=json
"set spelllang=pl

" na koniec i początek linii w insert mode
inoremap II <Esc>I
inoremap AA <Esc>A
inoremap OO <Esc>O
" bookmarks
inoremap <C-t> <Esc>:tabnew<CR>
nnoremap <C-t> :tabnew<CR>
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabnext<CR>
nnoremap tt  :tabnext<CR>
nnoremap tk  :tabprev<CR>
nnoremap tl  :tablast<CR>
"don't work
nnoremap <C-S-tab> :tabprevious<CR>
nnoremap <C-Tab> :tabnext<CR>
"inoremap <C-S-Tab> <Esc>:tabprevious<CR>i
"inoremap <C-Tab> <Esc>:tabnext<CR>i
" okna split 
noremap <C-J> <C-W>w
noremap <C-K> <C-W>W
noremap <C-L> <C-W>l
noremap <C-H> <C-W>h

" dodanie 2 spacji  
noremap <Leader>ee :%s/$/  /g <CR>  
" don't work map <Leader>ev :'<,'>s/$/  /g <CR>  
" vnoremap <Leader>ee :%s/\%V$/  /g  
vnoremap <Leader>ee :s/$/  /g <CR>  


set rtp+=$HOME/.local/lib/python2.7/site-packages/powerline/bindings/vim/
set laststatus=2
set t_Co=256



" **** Pluginy
" prievim
let g:previm_open_cmd = 'vivaldi'
map <leader>v :PrevimOpen <CR>
" let g:previm_enable_realtime =  1
" let g:previm_disable_default_css = 1
" let g:previm_custom_css_path = '~/Dokumenty/Ustawienia/sync/vim/bundle/previm/preview/css/themes/newsprint.css'

 " vim-instant-markdown - Instant Markdown previews from Vim
 let g:instant_markdown_autostart = 0    " disable autostart
 map <leader>md :InstantMarkdownPreview<CR>

"vim-markdown syntax
nmap <leader>t :Toc<CR>
" let g:vim_markdown_fenced_languages = ['java=java']
let g:vim_markdown_toc_autofit = 1
" let g:vim_markdown_folding_level = 6
" let g:vim_markdown_folding_style_pythonic = 1

" VIM-BOOKMARKS
" let g:bookmark_auto_save_file = '.vim/vim-bookmarks'
"let g:bookmark_auto_save_file = /workspace/vim-bookmarks
let g:bookmark_auto_save_file = $HOME .'/.vim/bookmarks'
let g:bookmark_auto_close = 1
" AUTOSAVE
set updatetime=200
autocmd CursorHoldI * silent w

"vim-airline toolbar
let g:airline#extensions#tabline#enabled = 1
" VIM DEVICONS
" set guifont=DroidSansMono\ Nerd\ Font\ Book\ 10
" set guifont=DroidSansMono\ Nerd\ Font\  10
set guifont=RoboMono\ Nerd\ Font\ 10

" calendar let g:calendar_google_calendar = 1

" CLOSETAG
" let g:closetag_filenames = "*.html,*.xhtml,*.phtml, *php"
" let g:closetag_html_style=1 

"NEOCONPLETE
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SUPERtAB like snippets behavior.
 imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
 \ "\<Plug>(neosnippet_expand_or_jump)"
 \: pumvisible() ? "\<C-n>" : "\<TAB>"
 smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
 \ "\<Plug>(neosnippet_expand_or_jump)"
 \: "\<TAB>"

" " For snippet_complete marker.
 if has('conceal')
   set conceallevel=2 concealcursor=niv
   endif
" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplete#close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplete#close_popup()
inoremap <expr><C-e>  neocomplete#cancel_popup()
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"

" For cursor moving in insert mode(Not recommended)
"inoremap <expr><Left>  neocomplete#close_popup() . "\<Left>"
"inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
"inoremap <expr><Up>    neocomplete#close_popup() . "\<Up>"
"inoremap <expr><Down>  neocomplete#close_popup() . "\<Down>"
" Or set this.
"let g:neocomplete#enable_cursor_hold_i = 1
" Or set this.
"let g:neocomplete#enable_insert_char_pre = 1

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable OMNI COMPLETION.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'


"visability concealcursor
set cocu=v

"closetag  
"chyba złe bo na wszystkie pliki ?:set ft=html
" :au Filetype html,xml,xsl source ~/.vim/plugin/closetag.vi

" eighties automatyczne dostosowanie okien
let g:eighties_enabled = 1
let g:eighties_minimum_width = 80
let g:eighties_extra_width = 0 " Increase this if you want some extra room
let g:eighties_compute = 1 " Disable this if you just want the minimum + extra
let g:eighties_bufname_additional_patterns = ['fugitiveblame'] " Defaults to [], 'fugitiveblame' is only an example. Takes a comma delimited list of bufnames as strings.

"""""""""""""""""" disabled

"PANDOC
" pandoc folding → nie działa
" let g:pandoc#folding#mode = 'stacked'
" let g:pandoc#folding#fold_yaml = 1
" let g:pandoc#folding#mode = ['syntax']
" let g:pandoc#folding#fdc = 0
" pandoc after
" let g:neosnippet#disable_runtime_snippets = { "_": 1, }
" let g:pandoc#after#modules#enabled = ["neosnippet"]

" pandoc syntax standalone
    " augroup pandoc_syntax
    "     au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
    " augroup END

" RESTORE VIEW
" zapisywanie ustawien widoku pliku z pluginem restore_view; przydatne do
" zapamiętywanie zwijania→ opcje do pluginu restore vim
" set viewoptions=cursor,folds,slash,unix 

"SYNTASTIC
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*
"
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0
"
" " let g:syntastic_html_tidy_exec = 'w3'
" let g:syntastic_html_checkers = ['w3']
" let g:syntastic_json_checkers = ['jsonval']
" let g:syntastic_json_jsonval_exec = 'jsonval'
"
"
