" Notes *********************************************************************
" http://github.com/twerth/dotfiles/blob/master/etc/vim/vimrc
" is a very good (and well documented!) vimrc to learn from 


" Pathogen ******************************************************************
set nocompatible
filetype off " Pathogen needs to run before plugin indent on
call pathogen#infect('bundle/{}') " call pathogen#incubate()
call pathogen#helptags() " generate helptags for everything in 'runtimepath'

" vim-plug  *****************************************************************
call plug#begin('~/.vim/plugged')
Plug 'Rip-Rip/clang_complete'
Plug 'XVimProject/XVim'
Plug 'benmills/vimux'
Plug 'bling/vim-airline'
Plug 'dcosson/vimux-nose-test2'
Plug 'duff/vim-scratch'
Plug 'fholgado/minibufexpl.vim'
Plug 'jgoulah/cocoa.vim'
Plug 'jnwhiteh/vim-golang'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'juvenn/mustache.vim'
Plug 'kana/vim-fakeclip'
Plug 'kballard/vim-swift'
Plug 'kortina/crosshair-focus.vim'
Plug 'mileszs/ack.vim'
Plug 'mxw/vim-jsx'
Plug 'mxw/vim-jsx'
Plug 'nelstrom/vim-markdown-folding'
Plug 'nelstrom/vim-markdown-preview'
Plug 'nvie/vim-flake8'
Plug 'pangloss/vim-javascript'
Plug 'pgr0ss/vimux-ruby-test'
Plug 'plasticboy/vim-markdown'
Plug 'rkulla/pydiction'
Plug 'rodjek/vim-puppet'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'shime/vim-livedown'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rails'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-ruby/vim-ruby'
Plug 'vim-scripts/LanguageTool'
Plug 'vim-scripts/fountain.vim'
Plug 'vim-scripts/taglist.vim'
call plug#end()

filetype plugin indent on
filetype on
filetype plugin on
filetype indent on
syntax on


" source local customizations based on $USER name
" eg, use ~/.vimrc.kortina for your local mods
" and one common ~/.vimrc for team
if filereadable($HOME . '/.vimrc.' . $USER)
    exec ':source ' . $HOME . '/.vimrc.' . $USER
endif


" Basics ********************************************************************
set backspace=indent,eol,start " fix backspace in vim 7
set cm=blowfish
set number
set et
set sw=4
set smarttab
set incsearch
set hlsearch
set ignorecase
set smartcase
set cursorline
set cursorcolumn
set title
set ruler
set showmode
set showcmd
set ai " Automatically set the indent of a new line (local to buffer)
set si " smartindent    (local to buffer)

" airline
set laststatus=2 " Show filename at bottom of buffer
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = 'wombat'

:runtime! ~/.vim/

" use either , or \ as <Leader>
let mapleader = ","
nmap \ ,


" Jump to last cursor position unless it's invalid or in an event handler
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \ exe "normal g`\"" |
    \ endif


" Folding *******************************************************************
" use spacebar to toggle folding
nnoremap <silent> <Space> @=(foldlevel('.')?'zA':"\<Space>")<CR>
vnoremap <Space> zf
" it's way too hard to type zR/zM to expand/close all folds, so
nnoremap 88 zR
nnoremap 77 zM


" Search ********************************************************************
set tags=./tags;
set grepprg=ack
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif
" always do very magic search
" :nnoremap / /\v
" :cnoremap %s/ %s/\v

" switch from horizontal to vertical split
:command H2v normal <C-w>t<C-w>H
" switch from vertical to horizontal split
:command V2h normal <C-w>t<C-w>K


" Completion ****************************************************************
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType python setlocal list
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

let g:ctrlp_working_path_mode = 0
set wildignore+=*/node_modules/*

let g:AutoClosePairs = {'(': ')', '{': '}', '[': ']', '"': '"'}

" Map ctrl + p to fzf fuzzy matcher, and customize colors to match vim
nmap <C-p> :FZF<CR>
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" Ack.vim  ******************************************************************
nmap <Leader>f :Ack 

" Buffers *******************************************************************
nmap <Leader>b :buffers<CR>
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l
" make panes equal size
noremap <Leader>w <C-W>=

" change buffer sizes with Shift arrow keys
" Shift worked with these:
noremap <Right> :vertical resize +5<CR>
noremap <Left>  :vertical resize -5<CR>
" why don't these work with Shift?
noremap <Down> :resize +5<CR>
noremap <Up> :resize -5<CR>

" CSS ***********************************************************************
autocmd Filetype css setlocal ts=2 sts=2 sw=2
autocmd Filetype scss setlocal ts=2 sts=2 sw=2

" HTML  *********************************************************************
autocmd Filetype html setlocal ts=2 sts=2 sw=2

" Javascript ****************************************************************
let g:jsx_ext_required = 0
let g:syntastic_javascript_checkers = ['eslint']
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2

" Golang  *******************************************************************
set rtp+=/usr/local/go/misc/vim
autocmd BufWritePost *.go :silent Fmt


" Python ********************************************************************

autocmd FileType python set ft=python.django " For SnipMate
" autocmd FileType html set ft=html.django_template " For SnipMate
" prevent comments from going to beginning of line
autocmd BufRead *.py inoremap # X<c-h>#
" turn on python folding when you open a file
autocmd BufRead *.py set foldmethod=indent
autocmd BufRead *.py set foldlevel=1
" configure pydiction
let g:pydiction_location = '~/.vim/bundle/pydiction/complete-dict'
noremap <Leader>d Oimport pdb; pdb.set_trace()<Esc>


" Ruby **********************************************************************
au BufRead,BufNewFile {Capfile,Gemfile,Rakefile,Vagrantfile,Thorfile,config.ru,.caprc,.irbrc,irb_tempfile*} set ft=ruby
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype eruby setlocal ts=2 sts=2 sw=2
let g:syntastic_ruby_checkers = ['mri', 'rubocop'] 
let g:syntastic_eruby_ruby_quiet_messages = {'regex': 'possibly useless use of a variable in void context'}

" Fountain  *****************************************************************
au BufRead,BufNewFile *.fountain        set filetype=fountain

" Git ***********************************************************************
command! -complete=file -nargs=* Gstaged call s:RunShellCommand('git diff --staged')
" review git diff in vertical split (fugitive doesn't seem to want to do this
:command ReviewGitDiff normal :Gdiff<CR>:H2v<CR>
nmap <Leader>dd :ReviewGitDiff<CR>


" CamelCaseWords ************************************************************
" http://vim.wikia.com/wiki/Moving_through_camel_case_words
" Stop on capital letters.
let g:camelchar = "A-Z"
" Also stop on numbers.
let g:camelchar = "A-Z0-9"
" Include '.' for class member, ',' for separator, ';' end-statement,
" and <[< bracket starts and "'` quotes.
let g:camelchar = "A-Z0-9.,;:{([`'\""
nnoremap <silent><C-Left> :<C-u>call search('\C\<\<Bar>\%(^\<Bar>[^'.g:camelchar.']\@<=\)['.g:camelchar.']\<Bar>['.g:camelchar.']\ze\%([^'.g:camelchar.']\&\>\@!\)\<Bar>\%^','bW')<CR>
nnoremap <silent><C-Right> :<C-u>call search('\C\<\<Bar>\%(^\<Bar>[^'.g:camelchar.']\@<=\)['.g:camelchar.']\<Bar>['.g:camelchar.']\ze\%([^'.g:camelchar.']\&\>\@!\)\<Bar>\%$','W')<CR>
inoremap <silent><C-Left> <C-o>:call search('\C\<\<Bar>\%(^\<Bar>[^'.g:camelchar.']\@<=\)['.g:camelchar.']\<Bar>['.g:camelchar.']\ze\%([^'.g:camelchar.']\&\>\@!\)\<Bar>\%^','bW')<CR>
inoremap <silent><C-Right> <C-o>:call search('\C\<\<Bar>\%(^\<Bar>[^'.g:camelchar.']\@<=\)['.g:camelchar.']\<Bar>['.g:camelchar.']\ze\%([^'.g:camelchar.']\&\>\@!\)\<Bar>\%$','W')<CR>
vnoremap <silent><C-Left> :<C-U>call search('\C\<\<Bar>\%(^\<Bar>[^'.g:camelchar.']\@<=\)['.g:camelchar.']\<Bar>['.g:camelchar.']\ze\%([^'.g:camelchar.']\&\>\@!\)\<Bar>\%^','bW')<CR>v`>o
vnoremap <silent><C-Right> <Esc>`>:<C-U>call search('\C\<\<Bar>\%(^\<Bar>[^'.g:camelchar.']\@<=\)['.g:camelchar.']\<Bar>['.g:camelchar.']\ze\%([^'.g:camelchar.']\&\>\@!\)\<Bar>\%$','W')<CR>v`<o


" Vimux  ********************************************************************
let g:vimux_ruby_file_relative_paths = 1
let g:vimux_nose_options="--nologcapture"

" vimux all languages
map <Leader>ri :call VimuxInspectRunner()<CR>
" e'X'it vimux
map <Leader>rx :call VimuxCloseRunner()<CR>
" last spec 'A'gain
map <Leader>ra :call VimuxRunLastCommand()<CR>
" vimux ruby
" 'S'pecs 'S'uite
autocmd FileType ruby   map <Leader>rs :call VimuxRunCommand("rspec")<CR>
" 'B'uffer
autocmd FileType ruby   map <Leader>rb :RunAllRubyTests<CR>
" 'L'ine
" autocmd FileType ruby   map <Leader>rl :RunRailsFocusedTest<CR>
autocmd FileType ruby   map <Leader>rl :call VimuxRunCommand("clear; RSPEC_CLEAN_WITH_DELETION=1 RSPEC_TRUNCATE_AFTER_SUITE=1 ./bin/rspec " . expand("%.") . ":" . line("."))<CR>
" 'C'ontext
autocmd FileType ruby   map <Leader>rc :RunRubyFocusedContext<CR>
" vimux python
autocmd FileType python map <Leader>rt :call VimuxRunNoseSetup()<CR>
" 'S'pecs 'S'uite
autocmd FileType python map <Leader>rs :call VimuxRunNoseAll()<CR>
" 'B'uffer
autocmd FileType python map <Leader>rb :call VimuxRunNoseFile()<CR>
" 'L'ine
autocmd FileType python map <Leader>rl :call VimuxRunNoseLine()<CR>
" vimux js
" In one tab in docker, start karma and leave it running with
" xvfb-run $NODE_PATH/karma/bin/karma start --single-run=false
" 'L'ine
autocmd FileType javascript map <Leader>rl :call VimuxRunCommand("clear; ./dev-scripts/karma-run-line-number.sh " . expand("%.") . ":" . line("."))<CR>
" 'B'uffer
autocmd FileType javascript map <Leader>rb :call VimuxRunCommand("clear; $NODE_PATH/karma/bin/karma run -- --grep=")<CR>


" Grammar  ******************************************************************
let g:languagetool_jar="`brew --prefix`/Cellar/languagetool/2.8/libexec/languagetool.jar"

" Spelling ******************************************************************
set spellfile=~/.vim/spell/en.utf-8.add
nmap <Leader>s :setlocal spell! spelllang=en_us<CR>

" Syntastic  ****************************************************************
" defaults
" @see https://github.com/scrooloose/syntastic README
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_loc_list_height=5
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
" From Danny, mode info
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'active_filetypes': [],
                           \ 'passive_filetypes': ['txt', 'go'] }



" Kortina  *****************************************************************
" Mac **********************************************************************
if $HOME == '/Users/kortina'
    colorscheme ir_black_kortina
    autocmd FileType objc let g:alternateExtensions_m = "h"
    autocmd FileType objc let g:alternateExtensions_h = "m"

    " Toggle source/implementation
    " noremap <Down> :A<cr> 
    " noremap <Up> :A<cr>

    let g:clang_complete_auto = 1
    let g:clang_exec='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang'
    let g:clang_library_path='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib'
endif


" Crosshairs ****************************************************************
"
hi CursorLine     guifg=NONE        guibg=#121212     gui=underline ctermfg=NONE        ctermbg=NONE        cterm=underline
hi CursorColumn   guifg=NONE        guibg=#121212     gui=NONE      ctermfg=NONE        ctermbg=darkgray        cterm=BOLD
hi Search         guifg=NONE        guibg=NONE        gui=underline ctermfg=NONE        ctermbg=darkgray        cterm=underline

set cursorline
set cursorcolumn
function CrosshairsOn()
    set cursorline
    set cursorcolumn
endfunction
nmap <Leader>l :call CrosshairsOn()<CR>

autocmd BufRead,BufNewFile,BufDelete * :syntax on

" Shortcuts *****************************************************************
imap <C-l> <C-r>"

" insert a markdown header, like
" ==============================
map <Leader>1 V"zy"zpVr=
map <Leader>2 V"zy"zpVr-

" copy all to clipboard
nmap <Leader>a ggVG"*y

" open markdown preview
nmap <Leader>p :Mm<CR>

" toggle Goyo (focus mode)
nmap <Leader>g :Goyo<CR>

" clear search buffer
map <Leader>c :let @/ = ""<CR>

" show keymappings in a searchable buffer
nmap <Leader>mm :redir @" | silent map | sort | redir END | new | put! 

" run ctags. Check for local / project versions first.
nmap <Leader>cc :!(test -f ./ctags.sh && ./ctags.sh) \|\|  (test -f ./bin/ctags.sh && ./bin/ctags.sh) \|\| echo 'no ./ctags.sh or ./bin/ctags.sh found'<CR>

" Fountain / Markdown  *********************************************************
autocmd BufNewFile,BufRead *.md,*.mkd,*.markdown,*.fountain set linebreak
autocmd BufNewFile,BufRead *.md,*.mkd,*.markdown,*.fountain setlocal spell spelllang=en_us

" fountain settings / hacks
" fixes error when loading markdown-folding
autocmd BufRead *.fountain let b:undo_ftplugin = '' 
" use markdown folding of headers in fountain files
autocmd BufRead *.fountain source ~/.vim/bundle/vim-markdown-folding/after/ftplugin/markdown/folding.vim
" ir_black_kortina does not color scene headings nicely
autocmd BufRead *.fountain colorscheme darkblue


" Experiments  *****************************************************************
" autocmd VimEnter *   call LogCmdEvent("VimEnter")

fun LogCmdEvent(eventName)
    echom "LogCmdEvent: " . a:eventName
endfun


