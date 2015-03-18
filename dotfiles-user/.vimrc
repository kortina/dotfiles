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
map ,1 V"zy"zpVr=
map ,2 V"zy"zpVr-

" copy all to clipboard
nmap ,a ggVG"*y

" open markdown preview
nmap ,p :Mm<CR>

" toggle Goyo (focus mode)
nmap ,g :Goyo<CR>

" clear search buffer
map \c :let @/ = ""<CR>

" Revert the current buffer
nnoremap \r :e!<CR>

" Easy edit of vimrc
nmap \s :source $MYVIMRC<CR>
nmap \v :e $MYVIMRC<CR>

" markdown settings
autocmd BufNewFile,BufRead *.md,*.mkd,*.markdown,*.fountain set filetype=markdown
autocmd FileType markdown set linebreak

" fountain settings / hacks
" fixes error when loading markdown-folding
autocmd BufRead *.fountain let b:undo_ftplugin = '' 
" use markdown folding of headers in fountain files
autocmd BufRead *.fountain source ~/.vim/bundle/vim-markdown-folding/after/ftplugin/markdown/folding.vim
" ir_black_kortina does not color scene headings nicely
autocmd BufRead *.fountain colorscheme darkblue

