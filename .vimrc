set nocompatible
filetype off

let use_you_complete_me = 0 " experiencing editor lag. try turning this off for now

" vim-plug  *****************************************************************
call plug#begin('~/.vim/plugged')
if use_you_complete_me
    Plug 'Valloric/YouCompleteMe'
endif
Plug 'ambv/black'
Plug 'benmills/vimux'
Plug 'bogado/file-line'
Plug 'dcosson/vimux-nose-test2'
Plug 'itchyny/lightline.vim'
Plug 'jtratner/vim-flavored-markdown'
Plug 'jnwhiteh/vim-golang'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'kana/vim-fakeclip'
Plug 'kana/vim-textobj-user'
Plug 'keith/swift.vim'
Plug 'maximbaz/lightline-ale'
Plug 'mileszs/ack.vim'
Plug 'mxw/vim-jsx'
Plug 'nvie/vim-flake8'
Plug 'pangloss/vim-javascript'
Plug 'pgr0ss/vimux-ruby-test'
Plug 'plasticboy/vim-markdown'
Plug 'rainerborene/vim-reek'
Plug 'reedes/vim-pencil'
" Plug 'reedes/vim-textobj-quote'
Plug 'reedes/vim-textobj-sentence'
Plug 'reedes/vim-wordy'
Plug 'rkulla/pydiction'
Plug 'scrooloose/nerdtree'
Plug 'shime/vim-livedown'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
" Plug 'tpope/vim-markdown'
Plug 'tpope/vim-rails'
Plug 'vim-ruby/vim-ruby'
Plug 'vim-scripts/LanguageTool'
Plug 'vim-scripts/fountain.vim'
Plug 'vim-scripts/taglist.vim'
Plug 'zxqfl/tabnine-vim'
Plug 'w0rp/ale'


" Plug 'prabirshrestha/async.vim'
" Plug 'prabirshrestha/vim-lsp'

call plug#end()

filetype plugin indent on
syntax on

let &runtimepath.=',~/.vim/bundle/ale'
:runtime! ~/.vim/

" use either , or \ as <Leader>
let mapleader = ","
nmap \ ,

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
set title
set ruler
set showmode
set showcmd
set ai " Automatically set the indent of a new line (local to buffer)
set si " smartindent    (local to buffer)
set lazyredraw

" tabnine *******************************************************************
" set rtp+=~/tabnine-vim
set rtp+=~/.vim/plugged/tabnine-vim/

" ale ***********************************************************************
function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
    \   '%dW %dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction

let g:ale_enabled = 1
nnoremap <leader>a :ALENextWrap<CR>

set statusline+=%#warningmsg#
set statusline=%{LinterStatus()}
set statusline+=%*

let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_changed = 'normal' " 'never', 'insert', or 'normal'
let g:ale_lint_on_save = 1
" Only fix on save
let g:ale_fix_on_save = 1

let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_change_sign_column_color = 1

" NB: if you run your project on docker, make sure to install js dependencies
" on mac host as well:
"   yarn install --dev
let g:ale_linters = {
\   'javascript': ['eslint', 'flow'],
\   'jsx': ['eslint', 'flow'],
\   'python': ['flake8', 'mypy'],
\   'ruby': ['ruby', 'rubocop'],
\   'hcl': [],
\}
let g:ale_fixers = {
\   'javascript': ['prettier', 'remove_trailing_lines'],
\   'ruby': ['rubocop', 'remove_trailing_lines'],
\}

" ale javascript settings
" let g:ale_javascript_prettier_options = ' --parser babylon --single-quote --jsx-bracket-same-line --trailing-comma es5 --print-width 100'
let g:ale_javascript_prettier_options = ' --config $FIN_HOME/.prettierrc '
let g:ale_javascript_eslint_use_global = 1

" lightline *****************************************************************
set laststatus=2 " Show filename at bottom of buffer
let g:lightline = {}
let g:lightline.colorscheme = 'wombat'
let g:lightline.active = {}
let g:lightline.active.left = [ ['mode', 'paste'], [ 'gitbranch', 'readonly', 'relativepath', 'modified', 'column' ] ]
let g:lightline.component_function = { 'gitbranch': 'fugitive#head' }
      " \ 'colorscheme': 'wombat',
      " \ 'active': {
      " \   'left': [ [ 'mode', 'paste' ],
      " \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      " \ },
      " \ 'component_function': {
      " \   'gitbranch': 'fugitive#head'
      " \ },
      " \ }

let g:lightline.component_expand = {
      \  'linter_checking': 'lightline#ale#checking',
      \  'linter_warnings': 'lightline#ale#warnings',
      \  'linter_errors': 'lightline#ale#errors',
      \  'linter_ok': 'lightline#ale#ok',
      \ }
let g:lightline.component_type = {
      \     'linter_checking': 'left',
      \     'linter_warnings': 'warning',
      \     'linter_errors': 'error',
      \     'linter_ok': 'left',
      \ }
let g:lightline.active.right = [[ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ]]

" I would do this as a local project .vimrc, but do not want to commit that to
" shared repo:
if getcwd() =~ '/fin/fin-core-beta$'
    " Project specific stuff here.
end

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
set foldlevelstart=99


" Search ********************************************************************
set tags=./tags;
set grepprg=ag\ --vimgrep
set grepformat=%f:%l:%c:%m
let g:ackprg = 'ag --vimgrep'

" switch from horizontal to vertical split
command H2v normal <C-w>t<C-w>H
" switch from vertical to horizontal split
command V2h normal <C-w>t<C-w>K


" Completion ****************************************************************
autocmd FileType css        setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html       setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python     setlocal omnifunc=pythoncomplete#Complete
autocmd FileType python     setlocal list

let g:ctrlp_working_path_mode = 0
set wildignore+=*/node_modules/*

" fzf ***********************************************************************

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


" CSS ***********************************************************************
autocmd Filetype css setlocal ts=2 sts=2 sw=2
autocmd Filetype scss setlocal ts=2 sts=2 sw=2


" HTML  *********************************************************************
autocmd Filetype html setlocal ts=2 sts=2 sw=2

" Javascript ****************************************************************
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2
autocmd FileType javascript setlocal formatprg=prettier\ --write\ --single-quote\ --jsx-bracket-same-line\ --parser\ babylon\ --trailing-comma\ es5\ --print-width\ 100
let g:jsx_ext_required = 0

" ↓ deprecated, using ale fixer now instead ↓
function FormatPrettierJs()
    let l:wv = winsaveview()
    " ↓ this will call formatprg on the entire buffer ↓
    silent exe "normal gggqG"
    " If there was an error, undo replacing the entire buffer
    if v:shell_error
        undo
    endif
    call winrestview(l:wv)
    redraw
    " Old way was to run the buffer through a filter ↓
    " silent %! prettier --single-quote --jsx-bracket-same-line --parser babylon --trailing-comma es5 --print-width 100
endfunction
" ↓ deprecated, using ale fixer now instead ↓
" Run prettier on save (with Fin flags)
" autocmd BufWritePre *.js,*.jsx call FormatPrettierJs()

" Golang  *******************************************************************
set rtp+=/usr/local/go/misc/vim
autocmd BufWritePost *.go :silent Fmt


" Python ********************************************************************

let g:black_linelength = 79
" prevent comments from going to beginning of line
autocmd BufRead *.py inoremap # X<c-h>#
" turn on python folding when you open a file
autocmd BufRead *.py set foldmethod=indent
" autocmd BufRead *.py set foldlevel=1
" configure pydiction
let g:pydiction_location = '~/.vim/bundle/pydiction/complete-dict'
" noremap <Leader>d Oimport pdb; pdb.set_trace()<Esc>
noremap <Leader>d Ofrom IPython.core.debugger import set_trace; set_trace()<Esc>
" au FileType python setlocal formatprg=autopep8\ -
" au FileType python setlocal equalprg=autopep8\ -
au FileType python setlocal formatprg=black\ -l\ 79\ -q\ -
autocmd BufWritePre *.py execute ':Black'

" Ruby **********************************************************************
au BufRead,BufNewFile {Capfile,Gemfile,Rakefile,Vagrantfile,Thorfile,config.ru,.caprc,.irbrc,irb_tempfile*} set ft=ruby
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype eruby setlocal ts=2 sts=2 sw=2


" Git ***********************************************************************
command! -complete=file -nargs=* Gstaged call s:RunShellCommand('git diff --staged')
" review git diff in vertical split (fugitive doesn't seem to want to do this
:command ReviewGitDiff normal :Gdiff<CR>:H2v<CR>
nmap <Leader>dd :ReviewGitDiff<CR>

" browse current file on github (with my browse-file alias in .gitconfig) +
" `hub`
function! GH()
    call system('hub browse-file "' . @% . '#L' . line('.') . '" & > /dev/null')
endfunction
nmap <Leader>gh :call GH()<CR>

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
autocmd FileType ruby   map <buffer> <Leader>rs :call VimuxRunCommand("rspec")<CR>
" 'B'uffer
autocmd FileType ruby   map <buffer> <Leader>rb :RunAllRubyTests<CR>
" 'L'ine
" autocmd FileType ruby   map <buffer> <Leader>rl :RunRailsFocusedTest<CR>
autocmd FileType ruby   map <buffer> <Leader>rl :call VimuxRunCommand("clear; RSPEC_CLEAN_WITH_DELETION=1 RSPEC_TRUNCATE_AFTER_SUITE=1 RSPEC_SKIP_ELASTICSEARCH_SETUP=1 ./bin/rspec " . expand("%.") . ":" . line("."))<CR>
" 'C'ontext
autocmd FileType ruby   map <buffer> <Leader>rc :RunRubyFocusedContext<CR>
" vimux python
autocmd FileType python map <buffer> <Leader>rt :call VimuxRunNoseSetup()<CR>
" 'S'pecs 'S'uite
autocmd FileType python map <buffer> <Leader>rs :call VimuxRunNoseAll()<CR>
" 'B'uffer
autocmd FileType python map <buffer> <Leader>rb :call VimuxRunNoseFile()<CR>
" 'L'ine
autocmd FileType python map <buffer> <Leader>rl :call VimuxRunNoseLine()<CR>
" vimux js
" In one tab in docker, start karma and leave it running with
" xvfb-run $NODE_PATH/karma/bin/karma start --single-run=false
" 'L'ine
" ↓ use daemonized karma runner:
" autocmd FileType javascript map <Leader>rl :call VimuxRunCommand("clear; ./dev-scripts/karma-run-line-number.sh " . expand("%.") . ":" . line("."))<CR>
autocmd FileType javascript map <Leader>rk :call VimuxRunCommand("clear; ./dev-scripts/karma-run-line-number.sh " . expand("%.") . ":" . line("."))<CR>
" ↓ start karma each test run:
" autocmd FileType javascript map <buffer> <Leader>rl :call VimuxRunCommand("clear; ./dev-scripts/karma-start-single-run-line-number.sh " . expand("%.") . ":" . line("."))<CR>
" ↓ use jest runner:
autocmd FileType javascript map <buffer> <Leader>rl :call VimuxRunCommand("clear; ./dev-scripts/jest-run-focused-test.sh " . expand("%.") . ":" . line("."))<CR>
" 'B'uffer
" ↓ use daemonized karma runner:
" autocmd FileType javascript map <Leader>rb :call VimuxRunCommand("clear; $NODE_PATH/karma/bin/karma run -- --grep=")<CR>
" ↓ start karma each test run:
" autocmd FileType javascript map <buffer> <Leader>rb :call VimuxRunCommand("clear; xvfb-run ./node_modules/karma/bin/karma start --single-run=true --single-file=\"" . expand("%.") . "\"")<CR>
" ↓ use jest runner:
autocmd FileType javascript map <buffer> <Leader>rb :call VimuxRunCommand("clear; ./dev-scripts/jest-run-focused-test.sh " . expand("%."))<CR>


" Grammar  ******************************************************************
let g:languagetool_jar="`brew --prefix`/Cellar/languagetool/2.8/libexec/languagetool.jar"

" Spelling ******************************************************************
set spellfile=~/.vim/spell/en.utf-8.add
nmap <Leader>s :setlocal spell! spelllang=en_us<CR>

" Theme *********************************************************************
set rtp+=$HOME/dotfiles/themes/tomorrow-theme/vim
colorscheme Tomorrow-Night
" Some of the highlight colors are kinda wack. Fix them:
hi SpellBad ctermfg=54
hi SpellCap ctermfg=54
hi DiffAdd ctermfg=54

" Crosshairs ****************************************************************
set nocursorline
set nocursorcolumn
" Use these instead of cursorline and cursorcolumn
let g:crosshair_cursorline = 1
let g:crosshair_cursorcolumn = 0

function! s:FlashCrosshairs()
    setlocal cursorline
    setlocal cursorcolumn
    hi CursorLine     guifg=NONE        guibg=black     gui=NONE      ctermfg=NONE        ctermbg=black            cterm=BOLD
    hi CursorColumn   guifg=NONE        guibg=black     gui=NONE      ctermfg=NONE        ctermbg=black            cterm=BOLD
    redraw
    sleep 10m

    " restore originals
    if g:crosshair_cursorline
        setlocal cursorline
    else
        setlocal nocursorline
    endif
    if g:crosshair_cursorcolumn
        setlocal cursorcolumn
    else
        setlocal nocursorcolumn
    endif
    redraw
endfunction
com! FlashCrosshairs call s:FlashCrosshairs()
" Use ,, to flash the Crosshairs:
nmap <Leader>, :FlashCrosshairs<CR>

" Flash crosshairs when cursor enters new buffer:
augroup CrosshairsGroup
    au!
    au WinEnter,BufWinEnter * :call s:FlashCrosshairs()
    au WinLeave * setlocal nocursorline nocursorcolumn
augroup END
" ^ Crosshairs ^ ************************************************************


" Shortcuts *****************************************************************
imap <C-l> <C-r>"
" Run / execute the current file
nmap <Leader>e :!%:p<CR>

" copy all to clipboard
nmap <Leader>c ggVG"*y

" open markdown preview
nmap <Leader>p :Mm<CR>

" clear search buffer
map <Leader>/ :let @/ = ""<CR>

" show keymappings in a searchable buffer
function! s:ShowMaps()
    let old_reg = getreg("a")          " save the current content of register a
    let old_reg_type = getregtype("a") " save the type of the register as well
    try
        redir @a                           " redirect output to register a
        " Get the list of all key mappings silently, satisfy "Press ENTER to continue"
        silent map | call feedkeys("\<CR>")    
        redir END                          " end output redirection
        vnew                               " new buffer in vertical window
        put a                              " put content of register
        " Sort on 4th character column which is the key(s)
        %!sort -k1.4,1.4
    finally                              " Execute even if exception is raised
        call setreg("a", old_reg, old_reg_type) " restore register a
    endtry
endfunction
com! ShowMaps call s:ShowMaps()      " Enable :ShowMaps to call the function
nmap <Leader>mm :ShowMaps<CR>

" run ctags. Check for local / project versions first.
nmap <Leader>cc :!(test -f ./ctags.sh && ./ctags.sh) \|\|  (test -f ./bin/ctags.sh && ./bin/ctags.sh) \|\| echo 'no ./ctags.sh or ./bin/ctags.sh found'<CR>

" Fountain / Markdown  *********************************************************
au BufRead,BufNewFile *.fountain set filetype=fountain
autocmd BufNewFile,BufRead *.md,*.mkd,*.markdown,*.fountain set linebreak
autocmd BufNewFile,BufRead *.md,*.mkd,*.markdown,*.fountain setlocal spell spelllang=en_us

" fountain settings / hacks
" fixes error when loading markdown-folding
autocmd BufRead *.fountain let b:undo_ftplugin = '' 
" use markdown folding of headers in fountain files
autocmd BufRead *.fountain source ~/.vim/bundle/vim-markdown-folding/after/ftplugin/markdown/folding.vim
let g:vim_markdown_frontmatter=1

" Experiments  *****************************************************************
" autocmd VimEnter *   call LogCmdEvent("VimEnter")

fun LogCmdEvent(eventName)
    echom "LogCmdEvent: " . a:eventName
endfun


" allow for per-project configuration files (project .vimrc)
set exrc
" disable unsafe commands in your project-specific .vimrc files
set secure

" source local customizations based on $USER name
" eg, use ~/.vimrc.kortina for your local mods
" and one common ~/.vimrc for team
if filereadable($HOME . '/.vimrc.' . $USER)
    exec ':source ' . $HOME . '/.vimrc.' . $USER
endif


" ***********************************************************************
" prose
" ***********************************************************************
" via https://github.com/reedes/vim-pencil
function! Prose()
  " call pencil#init()
  " call lexical#init()
  " call litecorrect#init()
  " call textobj#quote#init()
  call textobj#sentence#init()

  " manual reformatting shortcuts
  nnoremap <buffer> <silent> Q gqap
  xnoremap <buffer> <silent> Q gq
  nnoremap <buffer> <silent> <leader>Q vapJgqap

  " force top correction on most recent misspelling
  nnoremap <buffer> <c-s> [s1z=<c-o>
  inoremap <buffer> <c-s> <c-g>u<Esc>[s1z=`]A<c-g>u

  " replace common punctuation
  " iabbrev <buffer> -- –
  " iabbrev <buffer> --- —
  iabbrev <buffer> << «
  iabbrev <buffer> >> »
  iabbrev <buffer> --> →

  " open most folds
  " setlocal foldlevel=6

  " replace typographical quotes (reedes/vim-textobj-quote)
  " map <silent> <buffer> <leader>qc <Plug>ReplaceWithCurly
  map <silent> <buffer> <leader>qs <Plug>ReplaceWithStraight

  " highlight words (reedes/vim-wordy)
  noremap <silent> <buffer> <F8> :<C-u>NextWordy<cr>
  xnoremap <silent> <buffer> <F8> :<C-u>NextWordy<cr>
  inoremap <silent> <buffer> <F8> <C-o>:NextWordy<cr>

endfunction

" automatically initialize buffer by file type
autocmd FileType markdown,mkd,text call Prose()

" invoke manually by command for other file types
command! -nargs=0 Prose call Prose()



" ***********************************************************************
" experimental:
" ***********************************************************************

let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/vim-lsp.log')
" for asyncomplete.vim log
let g:asyncomplete_log_file = expand('~/asyncomplete.log')

autocmd FileType * setlocal omnifunc=lsp#complete
let g:lsp_async_completion = 1
" autocmd FileType typescript setlocal omnifunc=lsp#complete
set omnifunc=lsp#complete

" gem install language_server
au User lsp_setup call lsp#register_server({
    \ 'name': 'language_server',
    \ 'cmd': {server_info->['language_server']},
    \ 'whitelist': ['ruby'],
    \ })

" gem install language_server
au User lsp_setup call lsp#register_server({
    \ 'name': 'flow-language-server',
    \ 'cmd': {server_info->['flow-language-server']},
    \ 'whitelist': ['javascript', 'javascript.jsx'],
    \ })

" pip install python-language-server
au User lsp_setup call lsp#register_server({
    \ 'name': 'pyls',
    \ 'cmd': {server_info->['pyls']},
    \ 'whitelist': ['python'],
    \ })

