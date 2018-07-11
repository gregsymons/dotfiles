"Initialize pathogen first
filetype off
runtime bundle/pathogen/autoload/pathogen.vim
execute pathogen#incubate()
syntax on
filetype plugin indent on

set et
set ts=2
set sw=2
set tw=132
set bs=eol,indent,start
set ruler
set ai
set si
set laststatus=2
set statusline=%f\ %h%m%r[%1*%{fugitive#statusline()}%*]%<%=%-14.(%l,%c%V%)\ %P

if has("win32") || has("mac")
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
colorscheme Tomorrow-Night-Bright

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

if has("nvim")
tnoremap <C-j> <C-\><C-N><C-W>j
tnoremap <C-k> <C-\><C-N><C-W>k
tnoremap <C-h> <C-\><C-N><C-W>h
tnoremap <C-l> <C-\><C-N><C-W>l
tnoremap <M-j> <C-\><C-N><C-W>J
tnoremap <M-k> <C-\><C-N><C-W>K
tnoremap <M-g> <C-\><C-N><C-W>H
tnoremap <M-l> <C-\><C-N><C-W>L
endif

inoremap <C-j> <C-\><C-N><C-W>j
inoremap <C-k> <C-\><C-N><C-W>k
inoremap <C-h> <C-\><C-N><C-W>h
inoremap <C-l> <C-\><C-N><C-W>l
inoremap <M-j> <C-\><C-N><C-W>J
inoremap <M-k> <C-\><C-N><C-W>K
inoremap <M-g> <C-\><C-N><C-W>H
inoremap <M-l> <C-\><C-N><C-W>L
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
nnoremap <M-j> <C-W>J
nnoremap <M-k> <C-W>K
nnoremap <M-g> <C-W>H
nnoremap <M-l> <C-W>L

set secure

"table-mode configuration
let g:table_mode_verbose=1
let g:table_mode_header_fillchar='='
let g:table_mode_corner_corner='+'

"markdown configuration
let g:markdown_fenced_languages = [ 'javascript', 'scala', 'java' ]
