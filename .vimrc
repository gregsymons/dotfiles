syntax on
set et
set ts=4
set sw=4
set tw=80
set bs=eol,indent,start
set ruler
set ai
set si
set guifont=DPCustomMono2\ 8
set grepprg=grep\ -n
set autowrite
set backup 
set backupext=.bak
set nocp
set exrc
filetype plugin on
imap <C-F>  <Esc>gUiw`]a
colorscheme oceandeep
let g:author='Greg Symons'
let g:author_initials='GMS'
let g:c_nl_before_curlyB = 1

function! CreateTemplateMappings()
   "Make expanded fields easier to handle.
   iabbr field ¡Marker_Txt("")¡<Esc>3ha
   "Map guillemotes and upside-down exclamation and question marks for editing 
   "templates
   imap <Leader><< «
   imap <Leader>>> »
   imap <Leader>! ¡
   imap <Leader>? ¿
endfunction

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

command! LintQF call LintXmlQuickFixParse()
command! Evimrc edit ~/.vimrc
command! Header vert sfind %:t:r.h
command! Cpp vert sfind %:t:r.cpp

if !exists("my_autocommands")
   let my_autocommands = 1
   augroup VIMRC_AUTOCOMMANDS
   au!
   "make *.ipp act like c++
   au BufNewFile,BufRead *.ipp setf cpp
   augroup end
endif


nmap vK :call VerticalHelp()<Return>
nmap <M-F12> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<Return>
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <M-j> <C-W>J
map <M-k> <C-W>K
map <M-g> <C-W>H
map <M-l> <C-W>L
