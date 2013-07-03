"Initialize pathogen first
filetype off
runtime bundle/pathogen/autoload/pathogen.vim
execute pathogen#incubate()
syntax on
filetype plugin indent on

set et
set ts=4
set sw=4
set tw=80
set bs=eol,indent,start
set ruler
set ai
set si
set laststatus=2
set statusline=%f\ %h%m%r[%1*%{fugitive#statusline()}%*]%<%=%-14.(%l,%c%V%)\ %P

if has("win32")
    set guifont=DPCustomMono2:h8
else
    set guifont=DPCustomMono2\ 8
endif
set grepprg=grep\ -n
set autowrite
set nocp
set exrc

let g:local_vimrc = '.vimrc.local'

imap <C-F>  <Esc>gUiw`]a
colorscheme oceandeep

function! EditFileFromClipboard()
   let fname = getreg('+')
   silent! execute ":split " . fname
endf

function! VerticalHelp()
   exec ':vert botright help ' . expand('<cword>')
endf

function! LintXmlQuickFixParse()
   set errorformat =<issue\ file\ =\"%f\"\ line\ =\ \"%l\"\ number\ =\ \"%n\"\ desc\ =\ \"%m\"/>
   cb
endf

function! FindAndOpen(base, inplace, ...)
    if a:inplace == '!'
        let opencmd = 'edit'
    else
        let opencmd = 'vsplit'
    endif

    for extension in a:000
        let fname = findfile(a:base . extension)
        if fname != ''
            silent execute opencmd . ' ' . fname
            return
        endif
    endfor

    echohl WarningMsg
    echomsg 'Unable to find a file!'
    echohl None
endf

command! LintQF call LintXmlQuickFixParse()
command! Evimrc edit ~/.vimrc
command! Svimrc source ~/.vimrc
command! -bang Header call FindAndOpen(expand('%:t:r'), '<bang>', '.h', '.hpp', '.hxx')
command! -bang Cpp call FindAndOpen(expand('%:t:r'), '<bang>', '.cpp', '.c', '.cxx')

if !exists("my_autocommands")
   let my_autocommands = 1
   augroup VIMRC_AUTOCOMMANDS
   au!
   "make *.ipp act like c++
   au BufNewFile,BufRead *.ipp setf cpp
   augroup end
endif


nmap vK :call VerticalHelp()<Return>
nmap <M-S-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<Return>
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <M-j> <C-W>J
map <M-k> <C-W>K
map <M-g> <C-W>H
map <M-l> <C-W>L

set secure
