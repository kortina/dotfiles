" Notes ***********************************************************************
" http://github.com/twerth/dotfiles/blob/master/etc/vim/vimrc
" is a very good (and well documented!) vimrc to learn from 


" Pathogen *******************************************************************
set nocompatible
filetype off " Pathogen needs to run before plugin indent on
call pathogen#runtime_append_all_bundles()
call pathogen#helptags() " generate helptags for everything in 'runtimepath'
filetype plugin indent on
filetype on
filetype plugin on
filetype indent on
syntax on


" Mac ************************************************************************
if $HOME == '/Users/kortina'
    colorscheme ir_black
    " autocmd FileType objc # TODO: use this
    autocmd FileType objc let g:alternateExtensions_m = "h"
    autocmd FileType objc let g:alternateExtensions_h = "m"
    noremap <Down> :A<cr>
    noremap <Up> :A<cr>
    let g:clang_complete_auto = 1
    let g:clang_exec='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang'
    let g:clang_library_path='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib'

endif


" Basics **********************************************************************
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
"set list " turn invisibles on by default
set title
set ruler
set showmode
set showcmd
set ai " Automatically set the indent of a new line (local to buffer)
set si " smartindent    (local to buffer)
" set equalalways " Multiple windows, when created, are equal in size
"set splitbelow splitright"
"
" Ensure the current window has at least 30 lines
" set winheight=30
" Ensure all splits will have at least 5 lines 
" set winminheight=5

" Not exactly sure why the next 2 lines need at the beginning: autocmd VimEnter * 
autocmd VimEnter,WinEnter,BufEnter,BufRead,BufAdd,BufNew,FileReadPost,BufWinEnter * hi CursorLine     guifg=NONE        guibg=#121212     gui=underline ctermfg=NONE        ctermbg=NONE        cterm=underline
autocmd VimEnter,WinEnter,BufEnter,BufRead,BufAdd,BufNew,FileReadPost,BufWinEnter * hi CursorColumn   guifg=NONE        guibg=#121212     gui=NONE      ctermfg=NONE        ctermbg=darkgray        cterm=BOLD
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
autocmd BufRead,BufNewFile,BufDelete * :syntax on

" Jump to last cursor position unless it's invalid or in an event handler
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \ exe "normal g`\"" |
    \ endif


" Folding *********************************************************************
" use spacebar to toggle folding
nnoremap <silent> <Space> @=(foldlevel('.')?'zA':"\<Space>")<CR>
vnoremap <Space> zf
" it's way too hard to type zR to expand all folds, so
nnoremap 88 zR


" Search **********************************************************************
set tags=./tags;
set grepprg=ack
" always do very magic search
:nnoremap / /\v
:cnoremap %s/ %s/\v

" switch from horizontal to vertical split
:command H2v normal <C-w>t<C-w>H
" switch from vertical to horizontal split
:command V2h normal <C-w>t<C-w>K

" Javascript ******************************************************************
let jslint_command_options = '-conf ~/.jsl.conf -nofilelisting -nocontext -nosummary -nologo -process'


" Golang  *********************************************************************
set rtp+=/usr/local/go/misc/vim
autocmd BufWritePost *.go :silent Fmt


" MiniBufExpl *****************************************************************
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1


" Python **********************************************************************
let g:pyflakes_use_quickfix = 0
autocmd FileType python set ft=python.django " For SnipMate
autocmd FileType html set ft=html.django_template " For SnipMate
" prevent comments from going to beginning of line
autocmd BufRead *.py inoremap # X<c-h>#
" turn on python folding when you open a file
autocmd BufRead *.py set foldmethod=indent
autocmd BufRead *.py set foldlevel=1


" Completion ******************************************************************
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType python setlocal list
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

let g:ctrlp_working_path_mode = 0

let g:AutoClosePairs = {'(': ')', '{': '}', '[': ']', '"': '"'}

" Ruby ***********************************************************************
au BufRead,BufNewFile {Capfile,Gemfile,Rakefile,Vagrantfile,Thorfile,config.ru,.caprc,.irbrc,irb_tempfile*} set ft=ruby


" Shortcuts *******************************************************************
" ctrl-p paste
imap <C-l> <C-r>"

" insert a markdown header, like
" ==============================
map ,1 V"zy"zpVr=
map ,2 V"zy"zpVr-

" copy all to clipboard
nmap ,a ggVG"*y

" open markdown preview
nmap ,p :Mm<CR>

map \c :let @/ = ""<CR>

" Revert the current buffer
nnoremap \r :e!<CR>

"Easy edit of vimrc
nmap \s :source $MYVIMRC<CR>
nmap \v :e $MYVIMRC<CR>

:runtime! ~/.vim/

" CamelCaseWords *************************************************************
" http://vim.wikia.com/wiki/Moving_through_camel_case_words
" Use one of the following to define the camel characters.
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


" Shell Command > New Buffer *************************************************
command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
  echo a:cmdline
  let expanded_cmdline = a:cmdline
  for part in split(a:cmdline, ' ')
     if part[0] =~ '\v[%#<]'
        let expanded_part = fnameescape(expand(part))
        let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
     endif
  endfor
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(1, 'You entered:    ' . a:cmdline)
  call setline(2, 'Expanded Form:  ' .expanded_cmdline)
  call setline(3,substitute(getline(2),'.','=','g'))
  execute '$read !'. expanded_cmdline
  setlocal nomodifiable
  1
endfunction


" Git *************************************************************************
command! -complete=file -nargs=* Gstaged call s:RunShellCommand('git diff --staged')
" review git diff in vertical split (fugitive doesn't seem to want to do this
:command ReviewGitDiff normal :Gdiff<CR>:H2v<CR>


" Testing  ********************************************************************
" TODO: this testrun.rb thing needs to be abstracted in a nicer manner

map ,u :call RunTests()<cr>
function! RunTests()
    if filereadable("./testrun.rb")
        " Write the file and run tests for the given filename
        :w
        :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
        :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
        :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
        :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
        :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
        :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
        exec ":!echo 'Running tests...' && ./testrun.rb"
    else
        echo "No testrun.rb file exists."
    endif
endfunction

