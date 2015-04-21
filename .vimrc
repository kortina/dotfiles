" Notes *********************************************************************
" http://github.com/twerth/dotfiles/blob/master/etc/vim/vimrc
" is a very good (and well documented!) vimrc to learn from 


" Pathogen *****************************************************************
set nocompatible
filetype off " Pathogen needs to run before plugin indent on
call pathogen#infect('bundle/{}') " call pathogen#incubate()
call pathogen#helptags() " generate helptags for everything in 'runtimepath'
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

let g:AutoClosePairs = {'(': ')', '{': '}', '[': ']', '"': '"'}

" MiniBufExpl ***************************************************************
" let g:miniBufExplMapWindowNavVim = 1 is obsolete. Remapping below:
noremap <C-J> <C-W>j
noremap <C-K> <C-W>k
noremap <C-H> <C-W>h
noremap <C-L> <C-W>l



" Javascript ****************************************************************
" let jslint_command_options = '-conf ~/.jsl.conf -nofilelisting -nocontext -nosummary -nologo -process'
let g:jsx_ext_required = 0

" Golang  *******************************************************************
set rtp+=/usr/local/go/misc/vim
autocmd BufWritePost *.go :silent Fmt


" Python ********************************************************************
let g:pyflakes_use_quickfix = 0
autocmd FileType python set ft=python.django " For SnipMate
autocmd FileType html set ft=html.django_template " For SnipMate
" prevent comments from going to beginning of line
autocmd BufRead *.py inoremap # X<c-h>#
" turn on python folding when you open a file
autocmd BufRead *.py set foldmethod=indent
autocmd BufRead *.py set foldlevel=1
" call flake8 on save
autocmd BufWritePost *.py call Flake8()
" configure pydiction
let g:pydiction_location = '~/.vim/bundle/pydiction/complete-dict'
noremap <Leader>d Oimport pdb; pdb.set_trace()<Esc>


" Ruby **********************************************************************
au BufRead,BufNewFile {Capfile,Gemfile,Rakefile,Vagrantfile,Thorfile,config.ru,.caprc,.irbrc,irb_tempfile*} set ft=ruby
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2

let g:vroom_use_vimux = 1
let g:vroom_map_keys = 0

autocmd FileType ruby map <Leader>rf :VroomRunTestFile<CR>
autocmd FileType ruby map <Leader>rl :VroomRunNearestTest<CR>
autocmd FileType ruby map <Leader>rr :VroomRunLastTest<CR>


" Fountain  *****************************************************************
au BufRead,BufNewFile *.fountain        set filetype=fountain

" Git ***********************************************************************
command! -complete=file -nargs=* Gstaged call s:RunShellCommand('git diff --staged')
" review git diff in vertical split (fugitive doesn't seem to want to do this
:command ReviewGitDiff normal :Gdiff<CR>:H2v<CR>


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
let g:vimux_nose_options="--nologcapture"
autocmd FileType python map <Leader>rs :call VimuxRunNoseSetup()<CR>
autocmd FileType python map <Leader>ri :call VimuxInspectRunner()<CR>
autocmd FileType python map <Leader>rc :call VimuxCloseRunner()<CR>

autocmd FileType python map <Leader>ra :call VimuxRunNoseAll()<CR>
autocmd FileType python map <Leader>rf :call VimuxRunNoseFile()<CR>
autocmd FileType python map <Leader>rl :call VimuxRunNoseLine()<CR>
autocmd FileType python map <Leader>rr :call VimuxRunLastCommand()<CR>

" Grammar  ******************************************************************
let g:languagetool_jar='/opt/boxen/homebrew/Cellar/languagetool/2.8/libexec/languagetool.jar'

" Spelling ******************************************************************
set spellfile=~/.vim/spell/en.utf-8.add

" Syntastic  ****************************************************************
let g:syntastic_enable_signs=0 "sign markings (at beginning of line, before line numbers)
let g:syntastic_enable_highlighting=2
let g:syntastic_auto_loc_list=0
let g:syntastic_check_on_open=1
" mode info
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
    noremap <Down> :A<cr> 
    noremap <Up> :A<cr>

    let g:clang_complete_auto = 1
    let g:clang_exec='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang'
    let g:clang_library_path='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib'
endif


" Crosshairs ****************************************************************
autocmd VimEnter,WinEnter,BufEnter,BufRead,BufAdd,BufNew,FileReadPost,BufWinEnter * hi CursorLine     guifg=NONE        guibg=#121212     gui=underline ctermfg=NONE        ctermbg=NONE        cterm=underline
autocmd VimEnter,WinEnter,BufEnter,BufRead,BufAdd,BufNew,FileReadPost,BufWinEnter * hi CursorColumn   guifg=NONE        guibg=#121212     gui=NONE      ctermfg=NONE        ctermbg=darkgray        cterm=BOLD
autocmd VimEnter,WinEnter,BufEnter,BufRead,BufAdd,BufNew,FileReadPost,BufWinEnter * hi Search         guifg=NONE        guibg=NONE        gui=underline ctermfg=NONE        ctermbg=darkgray        cterm=underline
" Underline current line, but only if window is in focus
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
autocmd BufRead,BufNewFile,BufDelete * :syntax on


" Shortcuts *****************************************************************
" ctrl-p paste
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

" markdown settings
autocmd BufNewFile,BufRead *.md,*.mkd,*.markdown,*.fountain set linebreak

" fountain settings / hacks
" fixes error when loading markdown-folding
autocmd BufRead *.fountain let b:undo_ftplugin = '' 
" use markdown folding of headers in fountain files
autocmd BufRead *.fountain source ~/.vim/bundle/vim-markdown-folding/after/ftplugin/markdown/folding.vim
" ir_black_kortina does not color scene headings nicely
autocmd BufRead *.fountain colorscheme darkblue

