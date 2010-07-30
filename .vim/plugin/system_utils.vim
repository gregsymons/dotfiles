"=============================================================================
" File:		system_utils.vim					{{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim>
" Version:	1.10
" Created:	28th aug 2002
" Last Update:	23rd Sep 2003
"------------------------------------------------------------------------
" Description:	VimL wrappers for external utilities and shells
"
"------------------------------------------------------------------------
" Installation:	Drop the file in a {rtp}/plugin/ directory.
" 		On MsWindows system, if you have installed unixutils or any
" 		other unix-like text/file environment, then in your .vimrc,
" 		set 'g:unix_layer_installed' to 1.
"
" Dependencies:	Can take advantage of the presence of searchInRuntime.vim
" 		Vim 6.0+
" 
" History:	{{{2
" 	v 1.0	First version come from fix_d_name.vim and ensure_path.vim:
" 		two plugins that, once, were parts of Triggers.vim.
" 		Also includes the main part of _vimrc_win
" 	v 1.07	Improvements, bug fixes and new commands :Uniq & :Sort
" 	v 1.08	SysCat() changed into SysPrint()
" 	v 1.09  Sort functions have been chaged to the very optimized ones
" 	        proposed by Piet Delport on Vim ML.
" 	        :Sort accept an optional argument: the name of a comparaison
" 	        function
" 	v 1.10  EmuleUniq() doesn't mess with the unnamed register anymore.
" }}}2
" TODO:		Support other environments.
" }}}1
"=============================================================================

" Avoid reinclusion {{{1
if exists("g:loaded_system_utils_vim") && 
      \ (!exists('g:do_load_system_utils') || !g:do_load_system_utils)
  finish
endif
let g:loaded_system_utils_vim = 1
let s:cpo_save=&cpo
set cpo&vim
let s:sfile = expand('<sfile>:p')
" }}}1
"=============================================================================
" Function: s:ErrorMsg(msg)    {{{1
function! s:ErrorMsg(msg)
  if has('gui')
    call confirm(a:msg, '&Ok', 1, 'Error')
  else
    echohl ErrorMsg
    echo a:msg
    echohl None
  endif
endfunction
" }}}1
"=============================================================================
" Function: FixPathName(pathname [, shellslash [, quote_char ]])	{{{1
function! FixPathName(pathname,...) 
  " Parameters       {{{2
  " Ignore the last slash or backslash character, if any
  let pathname	 = matchstr(a:pathname, '^.*[^/\\]')
  " Default value for the quote character
  let quote_char = ''
  " Determine if 'shellslash' exists (dos-like platforms)
  if has('win16') || has('win32') || has('dos16') || has('dos32') || has('os2')
    if s:system == 'msdos'
      let shellslash = 0
    else
      let shellslash = &shellslash
    endif
  else "unix
    let shellslash = 1
  endif
  " Determine if we will use slashes or backslashes to distinguish directories
  if a:0 >= 1	" 
    let shellslash = a:1
    if a:0 >= 2
      let quote_char = a:2
    endif
  endif

  " Smart definition of quote chars for $COMSPEC
  if (s:system == 'msdos') && !shellslash && (''==quote_char)
    if (&shell =~ 'command\.com') 
      if pathname =~ ' '
	" should also test long directory-names...
	" Best: AVOID command.com !!!
	if &verbose >= 1
	  call s:ErrorMsg('FixPathName: '. 
		\ 'Problem expected because of the space in <'.pathname.'>')
	endif
      else
	let quote_char = ''
      endif
    else
      let quote_char = '"'
    endif
  endif

  " Fix the pathname {{{2
  if shellslash
    " return substitute(dname, '\\\([^ ]\|$\)', '/\1', 'g')
    let res = substitute(
	  \ substitute(pathname, '\\\([^ ]\|$\)', '/\1', 'g'),
	  \ '\(^\|[^\\]\) ', '\1\\ ', 'g')
  else
    " return substitute(
	  " \ substitute(pathname, '\([^\\]\) ', '\1\\ ', 'g'), 
	  " \ '/', '\\', 'g')
    let res = substitute(
	  \ substitute(pathname, '\\ ', ' ', 'g'), 
	  \ '/', '\\', 'g')
  endif
  " Note: problem to take care (that explains the complex substition schemes): 
  " sometimes the path passed to the function mix the two writtings, e.g.:
  " "c:\Program Files/longpath/some\ spaces/foo"
  " }}}2
  return quote_char . res . quote_char
endfunction
" }}}1
"------------------------------------------------------------------------
" Function: UnixLayerInstalled() : boolean   {{{1
function! UnixLayerInstalled()
  return exists('g:unix_layer_installed') && g:unix_layer_installed
endfunction

" Function: SystemDetected() : string        {{{1
function! SystemDetected()
  return s:system
endfunction

" Function: s:DetectSystem()                 {{{1
function! s:DetectSystem()
  " if                *nix-like systems {{{2
  if &shell =~ 'sh' || UnixLayerInstalled()
    if &shell !~ 'sh'
      let s:bin_path = ''
      let s:system = 'msdos'
    else
      " Problem: how to distinguish the use of unixutils-Zsh over cygwin-bash?
      if ($OSTYPE == "cygwin") || ($TERM == "cygwin")
	let s:bin_path = '/usr/bin/'
      else
	let s:bin_path = '\'
      endif
      let s:system = 'unix'
    endif
    let s:print  = s:bin_path.'cat'
    let s:remove = s:bin_path.'rm'
    let s:touch  = s:bin_path.'touch'
    let s:copy   = s:bin_path.'cp -p'
    let s:move   = s:bin_path.'mv'
    let s:rmdir  = s:bin_path.'rm -r'
    let s:mkdir  = s:bin_path.'mkdir'
    let s:sort   = s:bin_path.'sort'

  " elseif            Windows & dos-like systems {{{2
  elseif            
	\ has('win16') || has('win32') || has('dos16') || has('dos32') 
	\ || has('os2')
    let s:system = 'msdos'
    let s:print  = 'type'
    let s:remove = 'del'
    let s:touch  = 'gvim -c wq'
    let s:copy   = 'copy'
    let s:move   = 'ren'
    let s:rmdir  = 'rd /S/Q'
    let s:mkdir  = 'md'
    let s:sort   = 'sort'
  else              " Other systems {{{2
    let s:system = 'unknown'
    call s:ErrorMsg(
	  \ "I don't know the typical system-programs for your configuration."
	  \."\nAny solution is welcomed! ".
	  \ "Please, contact me at <hermitte"."@"."free.fr>")
  endif " }}}2
endfunction
" }}}1
"=============================================================================
" System functions         {{{1
" Function: SysPrint( file1 [, ...] ) : string               {{{2
function! SysPrint(...)
  let res = s:print
  let i = 0
  while i != a:0
    let i = i + 1
    if a:{i} =~ '^[-+]' " options
      if s:system == 'msdos' && !UnixLayerInstalled()
	if a:{i} =~ '^-h$\|^--h\%[elp]$' | let a_i = '/?'
	else
	  echoerr "SysPrint: Non portable option: ".a:{i}
	  return ''
	endif
      else
	let a_i = a:{i}
      endif
    else                " files
      let a_i = FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysRemove( file1 [, ...] ) : string              {{{2
function! SysRemove(...)
  let res = s:remove
  let i = 0
  while i != a:0
    let i = i + 1
    if a:{i} =~ '^[-+]' " options
      if s:system == 'msdos' && !UnixLayerInstalled()
	if a:{i} =~ '^-h$\|^--h\%[elp]$'              | let a_i = '/?'
	elseif a:{i} =~ '^-r$\|-R\|^--r\%[ecursive]$' | let a_i = '/S'
	elseif a:{i} =~ '^-i$\|^--i\%[interactive]$'  | let a_i = '/P'
	elseif a:{i} =~ '^-f$\|^--f\%[orce]$'         | let a_i = '/F'
	else
	  echoerr "SysRemove: Non portable option: ".a:{i}
	  return ''
	endif
      else
	let a_i = a:{i}
      endif
    else                " files
      let a_i = FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysRmdir( file1 [, ...] ) : string               {{{2
function! SysRmdir(...)
  let res = s:rmdir
  let i = 0
  while i != a:0
    let i = i + 1
    if a:{i} =~ '^[-+]' " options
      if s:system == 'msdos' && !UnixLayerInstalled()
	if a:{i} =~ '^-h$\|^--h\%[elp]$' | let a_i = '/?'
	else
	  echoerr "SysRmdir: Non portable option: ".a:{i}
	  return ''
	endif
      else
	let a_i = a:{i}
      endif
    else                " files
      let a_i = FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysMkdir( file1 [, ...] ) : string               {{{2
function! SysMkdir(...)
  let res = s:mkdir
  let i = 0
  while i != a:0
    let i = i + 1
    if a:{i} =~ '^[-+]' " options
      if s:system == 'msdos' && !UnixLayerInstalled()
	if a:{i} =~ '^-h$\|^--h\%[elp]$' | let a_i = '/?'
	else
	  echoerr "SysMkdir: Non portable option: ".a:{i}
	  return ''
	endif
      else
	let a_i = a:{i}
      endif
    else                " files
      let a_i = FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysCopy( file1 [, ...] ) : string                {{{2
function! SysCopy(...)
  let res = s:copy
  let i = 0
  while i != a:0
    let i = i + 1
    if a:{i} =~ '^[-+]' " options
      if s:system == 'msdos' && !UnixLayerInstalled()
	if a:{i} =~ '^-h$\|^--h\%[elp]$'              | let a_i = '/?'
	" elseif a:{i} =~ '^-r$\|-R\|^--r\%[ecursive]$' | let a_i = '/S'
	elseif a:{i} =~ '^-i$\|^--i\%[interactive]$'  | let a_i = '/-Y'
	elseif a:{i} =~ '^-f$\|^--f\%[orce]$'         | let a_i = '/Y'
	else
	  echoerr "SysCopy: Non portable option: ".a:{i}
	  return ''
	endif
      else
	let a_i = a:{i}
      endif
    else                " files
      let a_i = FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysTouch( file1 [, ...] ) : string               {{{2
function! SysTouch(...)
  let res = s:touch
  let i = 0
  while i != a:0
    let i = i + 1
    if a:{i} =~ '^[-+]' " options
      if s:system == 'msdos' && !UnixLayerInstalled()
	if a:{i} =~ '^-h$\|^--h\%[elp]$' | let a_i = '/?'
	else
	  echoerr "SysTouch: Non portable option: ".a:{i}
	  return ''
	endif
      else
	let a_i = a:{i}
      endif
    else                " files
      let a_i = FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysMove( file1 [, ...] ) : string                {{{2
function! SysMove(...)
  let res = s:move
  let i = 0
  while i != a:0
    let i = i + 1
    if a:{i} =~ '^[-+]' " options
      if s:system == 'msdos' && !UnixLayerInstalled()
	if a:{i} =~ '^-h$\|^--h\%[elp]$' | let a_i = '/?'
	else
	  echoerr "SysMove: Non portable option: ".a:{i}
	  return ''
	endif
      else
	let a_i = a:{i}
      endif
    else                " files
      let a_i = FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: SysSort( file1 [, ...] ) : string                {{{2
function! SysSort(...)
  let res = s:sort
  let i = 0
  while i != a:0
    let i = i + 1
    if a:{i} =~ '^[-+]' " options
      if s:system == 'msdos' && !UnixLayerInstalled()
	if a:{i} =~ '^-k=\d\+$\|^--k\%[ey]=\d\+$' 
	  let a_i = substitute('-k=\|--k\%[ey]=', '/+', '')
	else
	  echoerr "SysSort: Non portable option: ".a:{i}
	  return ''
	endif
      else
	let a_i = a:{i}
      endif
    else                " files
      let a_i = FixPathName(a:{i})
    endif
    let res = res . ' ' . a_i
  endwhile 
  return res
endfunction
" }}}2
"------------------------------------------------------------------------
" Command: Uniq()                                        {{{2

" ---
" Version from: Piet Delport <pjd {at} 303.za {dot} net>
" histdel() does not not in standalone in a command => cf the function
" command! -range=% Uniq 
      " \ silent <line1>,<line2>g/^\%<<line2>l\(.*\)\n\1$/d
      " \ | let @/ =  (histdel("search", -1) ? histget("search", -1) : '')
" ---

command! -range=% -nargs=0 Uniq	<line1>,<line2>call EmuleUniq()

" Function: EmuleUniq() range                            
" Use: As it is a `range' function, call it with:
" 	:%call EmuleUniq()
" 	:'<,'>call EmuleUniq()
" 	:3,6call EmuleUniq()
" 	etc
function! EmuleUniq() range
  let l1 = a:firstline
  let l2 = a:lastline
  if l1 < l2
    " Version1 from: Preben 'Peppe' Guldberg <peppe {at} xs4all {dot} nl>
    " silent exe l1 . ',' . (l2 - 1) . 's/^\(.*\)\%(\n\%<' . (l2 + 1)
	  " \ . 'l\1$\)\+/\1/e'
    
    " Version from: Piet Delport <pjd {at} 303.za {dot} net>
    " silent exe l1.','l2.'g/^\%<'.l2.'l\(.*\)\n\1$/d'

    " Version1 from: Preben & Piet
    " <line1>,<line2>-g/^\(.*\)\n\1$/d
    silent exe l1.','l2.'-g/^\(.*\)\n\1$/d _'

    call histdel('search', -1)		" necessary
    " let @/ = histget('search', -1)	" useless within a function
  endif
endfunction

" Based on the initial version proposed on the Vim ML by 
" Thomas Köhler <jean-luc {at} picard.franken {dot} de>
function! EmuleUniq0() range
  let l = a:firstline
  let e = a:lastline
  let crt = getline(l)		" current line
  while l < e     		" while we're not on the last line
    let l2 = l + 1			" look next line 
    let nxt = getline(l2)		" -- idem
    while (crt == nxt) && (l2<=e)	" while checked line matches current one
      let l2 = l2 + 1				" ... check next line
      let nxt = getline(l2)			
    endwhile
    let l2 = l2 - 1
    if l2 != l				" if there is more than one occurence
      silent exe (l+1).','.l2.'delete _' |	" delete the redundant lines
      let e = e - (l2 - l)			" correct the last line number
    endif
    let l = l + 1			" go to the next line
    let crt = nxt			" update the current line
  endwhile			" and endloop ...
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: EmuleSort() range                            {{{2
" Use: As it is a `range' function, call it with:
" 	:%call EmuleSort()
" 	:'<,'>call EmuleSort()
" 	:3,6call EmuleSort()
" 	etc
" Based on Robert Webb version (from Vim's documentation)
" Required as Microsoft's sort.exe is not case sensitive since MsDos 3.0 ...
" (smart move!)
" command! -range=% -nargs=0 Sort	<line1>,<line2>call EmuleSort('Strcmp')

func! Strcmp(str1, str2)
  if     (a:str1 < a:str2) | return -1
  elseif (a:str1 > a:str2) | return 1
  else                     | return 0
  endif
endfunction

" internal recursive function
func! s:SortR(start, end, cmp)
  if (a:start >= a:end) | return | endif
  let partition = a:start - 1
  let middle = partition
  let partStr = getline((a:start + a:end) / 2)
  let i = a:start
  while (i <= a:end)
    let str = getline(i)
    exec "let result = " . a:cmp . "(str, partStr)"
    if (result <= 0)
      " Need to put it before the partition.  Swap lines i and partition.
      let partition = partition + 1
      if (result == 0)
	let middle = partition
      endif
      if (i != partition)
	let str2 = getline(partition)
	call setline(i, str2)
	call setline(partition, str)
      endif
    endif
    let i = i + 1
  endwhile

  " Now we have a pointer to the "middle" element, as far as partitioning
  " goes, which could be anywhere before the partition.  Make sure it is at
  " the end of the partition.
  if (middle != partition)
    let str = getline(middle)
    let str2 = getline(partition)
    call setline(middle, str2)
    call setline(partition, str)
  endif
  call s:SortR(a:start, partition - 1, a:cmp)
  call s:SortR(partition + 1, a:end, a:cmp)
endfunc

function! EmuleSort(cmp) range
  silent call s:SortR(a:firstline, a:lastline, a:cmp)
endfunction
" }}}2
"
command! -range=% -nargs=* -complete=function Sort	
      \ <line1>,<line2>call s:BISortWrap(<f-args>)

" Function: BISort() range -- by Piet Delport            {{{2
function! s:BISortWrap(...) range                " {{{3
  if (a:0 == 1) 
    if !exists('*'.a:1)
      echoerr a:1 . ' is not a valid function name!'
    else
      silent call s:BISort(a:firstline, a:lastline, a:1)
    endif
  elseif a:0 > 1
    echoerr 'Too many arguments!'
  else
    silent call s:BISort2(a:firstline, a:lastline)
  endif
endfunction

function! s:BISort(start, end, cmp)              " {{{3
  let compare_ival_mid = 'let diff = '.a:cmp.'(i_val, getline(mid))'
  let i = a:start + 1
  while i <= a:end
    " find insertion point via binary search
    let i_val = getline(i)
    let lo = a:start
    let hi = i
    while lo < hi
      let mid = (lo + hi) / 2
      exec compare_ival_mid
      if diff < 0
        let hi = mid
      else
        let lo = mid + 1
        if diff == 0 | break | endif
      endif
    endwhile
    " do insert
    if lo < i
      exec i.'d_'
      call append(lo - 1, i_val)
    endif
    let i = i + 1
  endwhile
endfunction

function! s:BISort2(start, end)                  " {{{3
  let i = a:start + 1
  while i <= a:end
    " find insertion point via binary search
    let i_val = getline(i)
    let lo = a:start
    let hi = i
    while lo < hi
      let mid = (lo + hi) / 2
      let mid_val = getline(mid)
      if i_val < mid_val
        let hi = mid
      else
        let lo = mid + 1
        if i_val == mid_val | break | endif
      endif
    endwhile
    " do insert
    if lo < i
      exec i.'d_'
      call append(lo - 1, i_val)
    endif
    let i = i + 1
  endwhile
endfunction

"}}}2
" System functions }}}1
"=============================================================================
" Command: :EnsurePath     {{{1
"------------------------------------------------------------------------
" Purpose:              {{{2
" 	Proposes a command and a function that make sure a directory exists.
" 	If the directory didn't exist before the call, it is created.
" 	If the parent directories of the required directory do not exist, they
" 	are created on the way.
" Implementation Notes: {{{2
" (*) isdirectory() seems to require paths defined with forward slashes (even
" on Win Me, command.com and 'shellslash'=0 ; and the spaces must not be
" escaped... It is too simple otherwise.
" (*) On the same WinMe : 
"     - "system('md c:\verylongname')" and "system('md c:\verylongname\foo')"
"       work.
"     - "system('md c:\spaced name')" does not work !!! 
"       while !md "c:\spaced name" does... That's very odd
"     - "system('md "c:\spaced name"')" does not work either ... 
" (*) `mkdir' (from cygwin) is very permissive regarding the use of quotes and
" double-quotes. The only constraint is to have the spaces escaped.
" Tested on:            {{{2
" 	WinMe + command.com
" 	WinMe + cygwin (the VIM version, I used, being the one released on
" 		the VIM web site and ftps for PC/MsWindows systems).
" 		BTW, if you run VIM from the MsWindows files explorer and want
" 		to use cygwin commands (like mkdir here), be sure to have your
" 		$path correctly set.
" 	WinXP + cygwin (same comments as above)
" Retest on:
" 	Win95 + command.com & cygwin
" 	WinNT + cmd32 & zsh & cygwin
" 	Sun/Solaris + tcsh
" }}}2
"------------------------------------------------------------------------
command! -nargs=1 -complete=expression EnsurePath :call EnsurePath(<args>)
"------------------------------------------------------------------------
" Main function        <public>  {{{2
" Returns 0 : 0  -> the directory hasn't been created successfully
"         1 : ok -> the directory has been created successfully
" Note: for MsWindows system, this function transforms the path before
" anything else. 
function! EnsurePath(path)
  let path = a:path
  if has("dos16") || has("dos32") || has('win32') || has('win16')
    " a- change every backslash to forwardslash (when not followed by a
    "    space) ... because of 'isdirectory()'
    let path = substitute(path, '\\\([^ ]\)', '/\1', 'g')
    " b- unescape the spaces ... still because of 'isdirectory()'
    let path = substitute(path, '\\ ', ' ', 'g')
    " call confirm('<'.path.(isdirectory(path)?'> exists': "> doesn't exist"), 'ok')
    " return
  endif
  return s:EnsurePath_core(path)
endfunction
" }}}2
"------------------------------------------------------------------------
" Main loop function   <private> {{{2
" Return 0 : 0
"        1 : ok
" Note: This function recursively builds the provided directory.
function! s:EnsurePath_core(path)
  " call input("isdirectory(".a:path.") = ".isdirectory(a:path))
  if !isdirectory(a:path)
    " A.1- Get parent directory.
    let up = substitute(a:path, '/\=[^/]*/\=$', '/', '')
    " call input("up = ".up)
    " A.2.a- If the parent is not root.
    if "" != up
      " call input("loop ".up)
      " A.2.a.i-  Recursivelly construct the parent directory.
      let r = s:EnsurePath_core(up)
      " A.2.a.ii- Return if an error has occurred.
      if r != 1 
	" call input('r= '.r)
	return r 
      endif
    endif
    " A.2.b- the parent is root, implicitely, don't recurse.
    " A.3- Construct the directory at the current level.
    " call input("Build ".a:path)
    let r = s:EnsurePathLastDepth(a:path)
    " call input('rlast= '.r)
    " A.4- Return the result of the construction.
    return r
  else
    " B- The current path exist : terminal condition.
    " call input(a:path." exist")
    return 1
  endif
  " call input("Problem")
endfunction
" }}}2
"------------------------------------------------------------------------
" Creation function    <private> {{{2
" Return 0 : 0
"        1 : ok
" Note: This function calls mkdir on the last part of the directory and
" checks that the creation went OK. 
function! s:EnsurePathLastDepth(path)
  " call input("LastDepth isdirectory(".a:path.") = ".isdirectory(a:path))
  if !isdirectory(a:path)
    if filereadable(a:path) " {{{3
      call s:ErrorMsg("A file is found were a folder is expected : " . a:path)
      return 0 	" exit
    endif " }}}3
    let v:errmsg=""
    if &verbose >= 1 | echo "Create <".a:path.">\n" | endif
    if     has("unix") " {{{3
      "TODO: I'll certainly have to escape the path, if so, please send me
      "an email.
      call system('mkdir '.a:path)
      " call system('mkdir '.escape(a:path, ' '))
      let path = a:path
    elseif has("win32") " {{{3
      if &shell =~ "sh"
	let path = a:path
	" let path = substitute(a:path,'\\','/', 'g')
	""echo "system( 'mkdir ".path."')"
	call system('mkdir '.escape(path, ' '))
      else
	let path = substitute(a:path,'/','\\', 'g')
	let path = substitute(  path,'\\$','','')
	""echo "system( 'md ".path."')"
	if (path =~ ' ') && (has("dos16") || has("dos32") || has('win95'))
	  " system('md name with spaces do not work')
	  exe '!md "'.path.'"'
	  " Other solution if we don't want to wait for user to hit <enter>:
	  " parse the path and replace non-terminal occurences of
	  " directories having spaces in their name with the short name
	  " equivalent ; ie. "C:\Program Files\foo" --> "C:\Progra~1\foo"
	else
	  call system('md "'.path.'"')
	endif
      endif
    else " Other systems {{{3
      call s:ErrorMsg(
	    \ "I don't know how to create directories on your system."
	    \ "\nAny solution is welcomed! ".
	    \ "Please, contact me at <hermitte"."@"."free.fr>")
    endif " }}}3
    "
    " ¿ any error ? {{{3
    if strlen(v:errmsg) != 0
      call s:ErrorMsg(v:errmsg)
      return 0
    elseif !isdirectory(a:path)
      call s:ErrorMsg("<".path."> can't be created!")
      return 0
    endif
    " }}}3
    return 1
  else
    return 0
  endif
endfunction
" }}}2
"------------------------------------------------------------------------
" }}}1
"=============================================================================
" Shells for dos & windows {{{1
if has('win16') || has('win32') || has('dos16') || has('dos32') || has('os2')
" ----------------------------------------------------------------------
" Commands {{{2
command! -nargs=0 GoBash :call s:Go_bash()
command! -nargs=0 GoZsh  :call s:Go_zsh()
command! -nargs=0 GoCmd  :call s:Go_cmd()
" }}}2
" ----------------------------------------------------------------------
"  Functions {{{2
function! s:Go_bash() " {{{3
  " Search bash.exe {{{4
  if filereadable('c:/cygwin/bin/bash.exe')
    set shell=c:\\cygwin\\bin\\bash.exe
  elseif filereadable('d:/cygwin/bin/bash.exe')
    set shell=d:\cygwin\bin\bash.exe
  else
    " Last chance : the cygwin path must be in the $PATH, and
    " searchInRuntime.vim available.
    if !exists(':SearchInPATH') " solve the loading order problem...
      :runtime plugin/searchInRuntime.vim macros/searchInRuntime.vim
    endif
    if exists(':SearchInPATH') " search bash
      command! -nargs=1 SetShell :exe ':let &shell=<q-args>'
      :SearchInPATH SetShell bash.exe
      delcommand SetShell
    endif
    if &shell !~ 'bash'  " bash not found...
      call confirm("Change the path to your bash installation.\n"
	    \. 'Check <'.s:sfile.'>', '&OK', 1, "Error")
      return
    endif
  endif
  " Search bash.exe }}}4

  " set shellredir=">%s 2>&1"
  set shellredir=>%s\ 2>&1
  set shellpipe=2>&1\|\ tee
  set shellcmdflag=-c
  set shellquote=
  set shellxquote=\"
  " set shellxquote='"'
  set shellslash
  :call s:DetectSystem()
endfunction " }}}3
" ----------------------------------------------------------------------
function! s:Go_zsh() " {{{3
  " Search Zsh {{{4
  if filereadable('d:/users/hermitte/bin/bin/sh.exe')
    set shell=d:\users\hermitte\bin\bin\sh
  elseif filereadable('c:/Program\ Files/Nix/Unixtools/bin/sh.exe')
    set shell=c:/Program\ Files/Nix/Unixtools/bin/sh.exe
  else
    " Last chance: zsh must be in the $PATH, and searchInRuntime.vim
    " available.
    if !exists(':SearchInPATH') " solve the loading order problem...
      :runtime plugin/searchInRuntime.vim macros/searchInRuntime.vim
    endif
    " Note: If cygwin is installed and visible from $PATH, this may find ash
    " instead.
    if exists(':SearchInPATH') " search zsh
      command! -nargs=1 SetShell :exe ':let &shell=<q-args>'
      :SearchInPATH SetShell zsh.exe sh.exe
      delcommand SetShell
    endif
    if &shell !~ 'sh'  " zsh not found...
      call confirm("Change the path to your Zsh installation.\n"
	    \. 'Check <'.s:sfile.'>', '&OK', 1, "Error")
      return
    endif
  endif
  " Search Zsh }}}4
  set shellredir=>&
  set shellpipe=2>&1\|\ tee
  set shellcmdflag=-c
  set shellquote=
  set shellxquote=\"
  " set shellxquote='"'
  if version >= 600
    " Set shellslash in order to use correctly Cygwin.bat
    set shellslash
  endif
  :call s:DetectSystem()
endfunction " }}}3
" ----------------------------------------------------------------------
function! s:Go_cmd() " {{{3
  if has("dos16") || has("dos32") || has('win16') || has('win95')
    " Or Windows Millenium
    set shell=command.com
    set noshellslash
  elseif has("win32")	" NT, 2000, XP (?) ; 95&Me if the previous case
    " set shell=C:\WINNT\system32\cmd.exe
    let &shell=$COMSPEC
    "set shellslash	???
  else | return
  endif
  set shellcmdflag=/c
  set shellquote=
  set shellxquote=
  set shellredir=>
  set shellpipe=>
  :call s:DetectSystem()
endfunction " }}}3
" ----------------------------------------------------------------------
" }}}2
" ----------------------------------------------------------------------
" Auto-config {{{2
if ($OSTYPE == "cygwin") || ($TERM == "cygwin")
  " Cygwin
  :GoBash
elseif &sh =~ 'sh'
  " Unix tools
  :GoZsh
else
  " Microsoft's shell
  :GoCmd
endif
" Auto-config }}}2
" ----------------------------------------------------------------------
else
  call s:DetectSystem()
endif
" Shell }}}1
"=============================================================================
let &cpo=s:cpo_save

"=============================================================================
" vim600: set fdm=marker:
" vim:    set sw=2:ts=8:
