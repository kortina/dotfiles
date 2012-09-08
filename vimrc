" Pathogen
set nocompatible
filetype off " Pathogen needs to run before plugin indent on
call pathogen#runtime_append_all_bundles()
call pathogen#helptags() " generate helptags for everything in 'runtimepath'
filetype plugin indent on
filetype on
filetype plugin on
filetype indent on
syntax on

if $HOME == '/Users/kortina'
    "colorscheme herald_kortina
    colorscheme ir_black_kortina

    let g:clang_library_path = "/Applications/Xcode45-DP4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/"
endif

"if has("terminfo")
"  set t_Co=16
"  set t_AB=[%?%p1%{8}%<%t%p1%{40}%+%e%p1%{92}%+%;%dm
"  set t_AF=[%?%p1%{8}%<%t%p1%{30}%+%e%p1%{82}%+%;%dm
"else
"  set t_Co=16
"  set t_Sf=[3%dm
"  set t_Sb=[4%dm
"endif

" http://github.com/twerth/dotfiles/blob/master/etc/vim/vimrc
" very good vimrc (and well documented!)

set nocompatible

" always do very magic search
:nnoremap / /\v
:cnoremap %s/ %s/\v

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
" show in title bar
set title
set ruler
set showmode
set showcmd
set ai " Automatically set the indent of a new line (local to buffer)
set si " smartindent    (local to buffer)
set tags=./tags;
set grepprg=ack
"set list

let jslint_command_options = '-conf ~/Dropbox/nix/bin/jsl.conf -nofilelisting -nocontext -nosummary -nologo -process'
"set equalalways " Multiple windows, when created, are equal in size
"set splitbelow splitright"

" Professor VIM says '87% of users prefer jj over esc', jj abrams disagrees
" imap jj <Esc>


autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
autocmd BufRead,BufNewFile,BufDelete * :syntax on

let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1

let g:pyflakes_use_quickfix = 0

autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType python setlocal list
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS

autocmd FileType python set ft=python.django " For SnipMate
autocmd FileType html set ft=html.django_template " For SnipMate

au BufRead,BufNewFile {Capfile,Gemfile,Rakefile,Vagrantfile,Thorfile,config.ru,.caprc,.irbrc,irb_tempfile*} set ft=ruby

" fix backspace in vim 7
:set backspace=indent,eol,start
"nmap <buffer> <CR> gf
"nmap <buffer> <C-S-y> <Esc>yy<Esc>:bd<CR>:edit @"<CR>

" popout split buffer hack
" map <C-S-p>  <Esc>:hide<CR>:blast<CR>

" ctrl-p paste
imap <C-l> <C-r>"

" duplicate line"
" imap <C-D> <Esc>yyp
" nmap <C-D> <Esc>yyp

" insert a markdown header, like
" ==============================
map ,1 V"zy"zpVr=
map ,2 V"zy"zpVr-
"map <leader>h1 VypVr=
"map <leader>h2 VypVr-

nmap ,bs :ConqueTermSplit bash<CR>
nmap ,bv :ConqueTermVSplit bash<CR>

" copy all to clipboard
nmap ,a ggVG"*y
" copy word to clipboard
nmap ,d "*yiw
" underline current line, markdown style
nmap ,- "zyy"zp:.s/./-/g<CR>:let @/ = ""<CR>

" delete inner xml tag
nmap ,dit dt<dT>
nmap ,cit dt<cT>

" kortina - move note to the old-notes file
nmap ,kk ^"=strftime("%Y-%m-%d ")<CR>P<Esc>:,!~/Dropbox/nix/bin/note_archive.sh>/dev/null<CR>
nmap ,ll ^"=strftime("%Y-%m-%d ")<CR>P<Esc>:,!~/Dropbox/nix/bin/note_not_done.sh>/dev/null<CR>

nmap ,t <Leader>t

" kortina - map leader p to markdown preview
nmap ,p :Mm<CR>

"clear the fucking search buffer, not just remove the highlight
" map \c :let @/ = ""<CR> " this screws up Ack.vim
" also clear buffer with Enter
nmap <CR> :let @/ = ""<CR>

" Revert the current buffer
nnoremap \r :e!<CR>

"Easy edit of vimrc
nmap \s :source $MYVIMRC<CR>
nmap \v :e $MYVIMRC<CR>

:runtime! ~/.vim/
":helptags ~/.vim/doc 


let g:pydiction_location = '~/.vim/bundle/pydiction/ftplugin/pydiction-1.2/complete-dict'
"##################################################
"# move through CamelCaseWords
"##################################################
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

"##################################################

" Jump to last cursor position unless it's invalid or in an event handler
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \ exe "normal g`\"" |
    \ endif

" https://wincent.com/blog/2-hours-with-vim
"function! AckGrep(command)
"    cexpr system("ack " . a:command)
"    cw " show quickfix window already
"endfunction
"command! -nargs=+ -complete=file Ack call AckGrep(<q-args>)
"map <leader>a :Ack<space>

" prevent comments from going to beginning of line
autocmd BufRead *.py inoremap # X<c-h>#

" turn on python folding when you open a file
autocmd BufRead *.py set foldmethod=indent
autocmd BufRead *.py set foldlevel=1

" use spacebar to toggle folding
nnoremap <silent> <Space> @=(foldlevel('.')?'zA':"\<Space>")<CR>
vnoremap <Space> zf


"##################################################
" markdown
"##################################################
 augroup mkd
  autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
 augroup END

"##################################################
" via http://www.vim.org/scripts/script.php?script_id=30
"##################################################

map  ,cm   :call PythonCommentSelection()<CR>
vmap ,cm   :call PythonCommentSelection()<CR>
map  ,cu   :call PythonUncommentSelection()<CR>
vmap ,cu   :call PythonUncommentSelection()<CR>
" Comment out selected lines
" commentString is inserted in non-empty lines, and should be aligned with
" the block
function! PythonCommentSelection()  range
  let commentString = "#"
  let cl = a:firstline
  let ind = 1000    " I hope nobody use so long lines! :)

  " Look for smallest indent
  while (cl <= a:lastline)
    if strlen(getline(cl))
      let cind = indent(cl)
      let ind = ((ind < cind) ? ind : cind)
    endif
    let cl = cl + 1
  endwhile
  if (ind == 1000)
    let ind = 1
  else
    let ind = ind + 1
  endif

  let cl = a:firstline
  execute ":".cl
  " Insert commentString in each non-empty line, in column ind
  while (cl <= a:lastline)
    if strlen(getline(cl))
      execute "normal ".ind."|i".commentString
    endif
    execute "normal \<Down>"
    let cl = cl + 1
  endwhile
endfunction

" Uncomment selected lines
function! PythonUncommentSelection()  range
  " commentString could be different than the one from CommentSelection()
  " For example, this could be "# \\="
  let commentString = "#"
  let cl = a:firstline
  while (cl <= a:lastline)
    let ul = substitute(getline(cl),
             \"\\(\\s*\\)".commentString."\\(.*\\)$", "\\1\\2", "")
    call setline(cl, ul)
    let cl = cl + 1
  endwhile
endfunction

"function! KortinaOpenQuickfix()
    "" open quickfix
    "exe "copen"
"endfunction
" autocmd BufWritePost,FileWritePost *.py call KortinaOpenQuickfix() " open quickfix on write
" autocmd BufWritePost,FileWritePost *.py call KortinaOpenQuickfix() " open quickfix on write


if findfile('~/Dropbox/Venmo-Devops/gpg/gpg-add-venmo-recipients.vim')
    source ~/Dropbox/Venmo-Devops/gpg/gpg-add-venmo-recipients.vim
endif


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
command! -complete=file -nargs=* Gstaged call s:RunShellCommand('git diff --staged')
" command! -complete=file -nargs=* Git call s:RunShellCommand('git '.<q-args>)


" golang
set rtp+=/usr/local/go/misc/vim
autocmd BufWritePost *.go :silent Fmt



" ############ Testing
" TODO: this needs to be abstracted in a nicer manner

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
