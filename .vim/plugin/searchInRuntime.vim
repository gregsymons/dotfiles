" File:		searchInRuntime.vim 
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://hermitte.free.fr/vim/>
" URL:http://hermitte.free.fr/vim/ressources/vimfiles/plugin/searchInRuntime.vim
"
" Last Update:  29th mar 2003
" Version:	1.6c
"
" Purpose:	Search a file in the runtime path, $PATH, or any other
"               variable, and execute an Ex command on it.
" History: {{{
"	Version 1.6c:
"	(*) Bug fixed with non win32 versions of Vim: no more
"            %Undefined variable ss
"            %Invalid expression ss
"	Version 1.6b:
"	(*) Minor changes in the comments
"	Version 1.6:
"	(*) :SearchInENV has become :SearchInVar.
"	Version 1.5:
"	(*) The commands passed to the different :SearchIn* commands can
"	    accept any number of arguments before the names of the files found.
"	    To use them, add at the end of the :SearchIn* command: a pipe+0
"	    (' |0 ') and then the list of the other parameters.
"	Version 1.4:
"	(*) Fix a minor problem under Windows when VIM is launched from the
"	    explorer.
"	Version 1.3:
"	(*) The commands passed to the different :SearchIn* commands can
"	    accept any number of arguments after the names of the files found.
"	    To use them, add at the end of the :SearchIn* command: a pipe 
"	    (' | ') and then the list of the other parameters.
"	Version 1.2b:
"	(*) Address obfuscated for spammers
"	Version 1.2:
"	(*) Add continuation lines support ; cf 'cpoptions'
"	Version 1.1:
"	(*) Support the '&verbose' option :
"	     >= 0 -> display 'no file found'.
"	     >= 2 -> display the list of files found.
"	     >= 3 -> display the list of directories searched.
"	(*) SearchInPATH : like SearchInRuntime, but with $PATH
"	(*) SearchInENV : work on any list of directories defined in an
"	    environment variable.
"	(*) Define the classical debug command : Echo
"	(*) Contrary to 'runtime', the search can accept absolute paths ; 
"	    for instance, 
"	    	runtime! /usr/local/share/vim/*.vim 
"	    is not valid while 
"	    	SearchInRuntime source /usr/local/share/vim/*.vim 
"	    is accepted.
"	
"	Version 1.0 : initial version
" }}}
"
" Todo: {{{
" 	(*) Should be able to interpret absolute paths stored in environment
" 	    variables ; e.g: SearchInRuntime Echo $VIM/*vimrc*
" 	(*) Absolute paths should not shortcut the order of the file globing 
" 	    patterns ; see: SearchInENV! $PATH Echo *.sh /usr/local/vim/*
" 	(*) Write a little documentation
" }}}
"
" Examples: {{{
" 	(*) :SearchInVar $INCLUDE sp vector
" 	    Will (if $INCLUDE is correctly set) open in a |split| window (:sp)
" 	    the C++ header file vector.
"
"    	(*) :let g:include = $INCLUDE
"    	    :SearchInVar g:include Echo *
"	    Will echo the name of all the files present in the directories
"	    specified in $INCLUDE.
"
"	(*) :SearchInRuntime! Echo plugin/*foo*.vim | final arguments
"	    For every file name plugin/*foo*.vim in the 'runtimepath', this
"	    will execute:
"		:Echo {path-to-the-file} final arguments
"
"	(*) :SearchInRuntime! grep plugin/*foo*.vim |0 text
"	    For every file name plugin/*foo*.vim in the 'runtimepath', this
"	    will execute:
"		:grep text {path-to-the-file}
"
"	(*) :SearchInRuntime! source here/foo*.vim 
"	    is equivalent to:
"		:runtime! here/foo*.vim 
"
"	(*) :silent exe 'SearchInRuntime 0r there/that.'.&ft 
"	    Will:
"	    - search the 'runtimepath' list for the first file named
"	    "that.{filetype}" present in the directory "there", 
"	    - and insert it in the current buffer. 
"	    If no file is found, nothing is done. 
"
" }}}
"
" ========================================================================

if exists("g:searchInRuntime_vim") | finish | endif
let g:searchInRuntime_vim = 1
"
"" line continuation used here ??
let s:cpo_save = &cpo
set cpo&vim


" ========================================================================
" Commands {{{
command! -nargs=+ -complete=file -bang
      \       SearchInRuntime	call <SID>SearchInRuntime("<bang>",  <f-args>)
command! -nargs=+ -complete=file -bang
      \       SearchInVar	call <SID>SearchInVar("<bang>",  <f-args>)
command! -nargs=+ -complete=file -bang
      \       SearchInPATH	call <SID>SearchInPATH("<bang>",  <f-args>)

if !exists('!Echo')
  command! -nargs=+ Echo echo "<args>"
endif

" }}}
" ========================================================================
" Functions {{{

function! s:SearchIn(do_all, cmd, rpath, ...) " {{{
  " Loop on runtimepath : build the list of files
  if has('win32')
    let ss=&shellslash
    set shellslash
    " because of glob + escape ('\\')
  endif
  let rp = a:rpath
  let f = ''
  let firstTime = 1
  while strlen(rp) != 0
    let r  = matchstr(rp, '^[^,]*' )."/"
    let rp = substitute(rp, '.\{-}\(,\|$\)', '', '')
    if &verbose >= 3 | echo "Directory searched: [" . r. "]\n" | endif
      
    " Loop on arguments
    let params0 = '' | let params = '' 
    let i = 1
    while i <= a:0
      if a:{i} =~? '^\(/\|[a-z]:[\\/]\)' " absolute path
	if firstTime
	  if &verbose >= 3 | echo "Absolute path : [" . glob(a:{i}). "]\n" | endif
	  let f = f . glob(a:{i}) . "\n"
	endif
      elseif a:{i} == "|0"	" Other parameters
	let i = i + 1
	while i <= a:0
	  let params0 = escape(params0, "\\ \t") . ' ' . a:{i}
	  let i = i + 1
	endwhile
      elseif a:{i} == "|"	" Other parameters
	let i = i + 1
	while i <= a:0
	  let params = escape(params, "\\ \t") . ' ' . a:{i}
	  let i = i + 1
	endwhile
      else
	let f = f . glob(r.a:{i}). "\n"
	"echo a:{i} . " -- " . glob(r.a:{i})."\n"
	"echo a:{i} . " -- " . f."\n"
      endif
      let i = i + 1
    endwhile
    let firstTime = 0
  endwhile
  if has('win32')
    let &shellslash=ss
  endif
  "
  " Execute the command on the matching files
  let foundOne = 0
  while strlen(f) != 0
    let ff = matchstr(f, "^[^\n]*")
    let f  = substitute(f, '.\{-}\('."\n".'\|$\)', '', '')
    if filereadable(ff)
      if     &verbose >= 3 
	echo "Action on: [" . ff . "] (".params0.'/'.params.")\n"
      elseif &verbose >= 2 
	echo "Action on: [" . ff . "]\n" 
      endif
      " echo a:cmd.params0." ".escape(ff, "\\ \t").params
      exe a:cmd.params0." ".escape(ff, "\\ \t").params
      if !a:do_all | return | endif
      let foundOne = 1
    endif
  endwhile
  if &verbose > 0 && !foundOne " {{{
    let msg = "not found : « "
    let i = 1
    while i <= a:0
      let msg = msg. a:{i} . " "
      let i = i + 1
    endwhile
    echo msg."»"
  endif " }}}
endfunction
" }}}

function! s:SearchInRuntime(bang, cmd, ...) "{{{
  let do_all = a:bang == "!"
  let i = 1
  let a = ''
  while i <= a:0
    let a = a.",'".escape(a:{i}, "\\ \t")."'"
    let i = i + 1
  endwhile
  exe 'call <sid>SearchIn(do_all, a:cmd, &runtimepath' .a.')'
endfunction "}}}

function! s:SearchInPATH(bang, cmd, ...) "{{{
  let do_all = a:bang == "!"
  let i = 1
  let a = ''
  while i <= a:0
    " let a = a.",'".a:{i}."'"
    " let a = a.",'".escape(a:{i}, '\ ')."'"
    let a = a.",'".escape(a:{i}, "\\ \t")."'"
    let i = i + 1
  endwhile
  let p = substitute($PATH, ';', ',', 'g')
  exe "call <sid>SearchIn(do_all, a:cmd,'". p ."'".a.")"
endfunction "}}}

function! s:SearchInVar(bang, env, cmd, ...) "{{{
  let do_all = a:bang == "!"
  let i = 1
  let a = ''
  while i <= a:0
    " let a = a.",'".a:{i}."'"
    " let a = a.",'".escape(a:{i}, '\ ')."'"
    let a = a.",'".escape(a:{i}, "\\ \t")."'"
    let i = i + 1
  endwhile
  exe "let p = substitute(".a:env.", ';', ',', 'g')"
  exe "call <sid>SearchIn(do_all, a:cmd,'". p ."'".a.")"
endfunction "}}}

" }}}
let &cpo = s:cpo_save
" ========================================================================
" vim60: set foldmethod=marker:
