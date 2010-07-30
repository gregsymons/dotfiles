" ========================================================================
" File:			c_set.vim
" Author:		Luc Hermitte <MAIL:hermitte {at} free {dot} fr>
" 			<URL:http://hermitte.free.fr/vim/>
"
" Last Update:		18th Feb 2004
"
" Purpose:		ftplugin for C (-like) programming
"
" Dependancies:		misc_map.vim
" 			common_brackets.vim
" 			a.vim			-- alternate files
" 			LoadHeaderFile.vim	
" 			flist & flistmaps.vim	-- Dr Chips
" 			VIM >= 6.00 only
" ========================================================================




" ========================================================================
" Buffer local definitions {{{
" ========================================================================
if exists("b:loaded_local_perl_settings") | finish | endif
let b:loaded_local_perl_settings = 1

  "" line continuation used here ??
  let s:cpo_save = &cpo
  set cpo&vim

" ------------------------------------------------------------------------
" Includes {{{
" ------------------------------------------------------------------------
source $VIMRUNTIME/ftplugin/perl.vim
let b:did_ftplugin = 1
" }}}
" ------------------------------------------------------------------------
" Options to set {{{
" ------------------------------------------------------------------------
setlocal formatoptions=croql
setlocal cindent
setlocal ch=2  "leave this one here or the mappings don't work right.


if !exists('maplocalleader')
  let maplocalleader = ','
endif

" }}}
" ------------------------------------------------------------------------
" Brackets & all {{{
" ------------------------------------------------------------------------
if !exists('*Brackets')
  runtime plugin/common_brackets.vim
endif
if exists('*Brackets')
  let b:cb_parent  = 1
  let b:cb_bracket = 1
  let b:cb_acco    = 1
  let b:cb_quotes  = 2
  let b:cb_Dquotes = 1
  " Re-run brackets() in order to update the mappings regarding the different
  " options.
  call Brackets()
endif

" }}}
" ------------------------------------------------------------------------
" Control structures {{{
" ------------------------------------------------------------------------
"
command! PopSearch :call histdel('search', -1)| let @/=histget('search',-1)

" --- if -----------------------------------------------------------------
"--if    insert "if" statement
  Iabbr <buffer> if <C-R>=Def_AbbrPerl("if ",
      \ '\<c-f\>if () {\<cr\>!mark!\<cr\>}!mark!\<esc\>?)\<cr\>:PopSearch\<cr\>i')<cr>
"--,if    insert "if" statement
  vnoremap <buffer> <LocalLeader>if 
	\ :call InsertAroundVisual('if () {','}', 1, 1)<cr>gV
	" \ ><esc>`>a<cr>}<c-t><esc>`<iif<c-V> () {<c-f><cr><esc>?(<cr>a
      nmap <buffer> <LocalLeader>if V<LocalLeader>if

"--elif  insert else clause of if statement with following if statement
  Iabbr <buffer> elsif <C-R>=Def_AbbrPerl("elsif ",
      \ '\<c-f\>elsif () {\<cr\>!mark!\<cr\>}!mark!\<esc\>?)\<cr\>:PopSearch\<cr\>i')<cr>
"--,elif  insert else clause of if statement with following if statement
  vnoremap <buffer> <LocalLeader>elsif 
	\ :call InsertAroundVisual('elsif () {','}', 1, 1)<cr>gV
	" \ ><esc>`>a<cr>}<c-t><esc>`<ielse if () {<c-f><cr><esc>?(<cr>a
      nmap <buffer> <LocalLeader>elsif V<LocalLeader>elif

"--else  insert else clause of if statement
  Iabbr <buffer> else <C-R>=Def_AbbrPerl("else ",
      \ '\<c-f\>else {\<cr\>}!mark!\<esc\>O')<cr>
"--,else  insert else clause of if statement
  vnoremap <buffer> <LocalLeader>else 
	\ :call InsertAroundVisual('else {','}', 1, 1)<cr>gV
	" \ ><esc>`>a<cr>}<c-t><esc>`<ielse {<c-f><cr><esc>?{<cr>
      nmap <buffer> <LocalLeader>else V<LocalLeader>else

"--- for ----------------------------------------------------------------
"--for   insert "for" statement
  Iabbr <buffer> for <C-R>=Def_AbbrPerl("for ",
      \ '\<c-f\>for (;!mark!;!mark!) {\<cr\>!mark!\<cr\>}!mark!\<esc\>?)\<CR\>:PopSearch\<cr\>%a')<cr>
"--,for   insert "for" statement
  vnoremap <buffer> <LocalLeader>for 
	\ :call InsertAroundVisual('for (;;) {','}', 1, 1)<cr>gV
	" \ ><esc>`>a<cr>}<c-t><esc>`<ifor (;;) {<c-f><cr><esc>?(<cr>a
      nmap <buffer> <LocalLeader>for V<LocalLeader>for

"--- while --------------------------------------------------------------
"--while insert "while" statement
  Iabbr <buffer> while <C-R>=Def_AbbrPerl("while ",
      \ '\<c-f\>while () {\<cr\>!mark!\<cr\>}!mark!\<esc\>?)\<CR\>:PopSearch\<cr\>i')<cr>
"--,while insert "while" statement
  vnoremap <buffer> <LocalLeader>while 
	\ :call InsertAroundVisual('while () {','}', 1, 1)<cr>gV
	" \ ><esc>`>a<cr>}<c-t><esc>`<iwhile () {<c-f><cr><esc>?(<cr>a
      nmap <buffer> <LocalLeader>while V<LocalLeader>while

" --- return -------------------------------------------------------------
"-- <m-r> insert "return ;"
  inoremap <buffer> <m-r> <c-r>=BuildMapSeq('return;!mark!\<esc\>F;i')<cr>

"}}}
"}}}
" ========================================================================
" General definitions {{{
" ========================================================================
if exists("g:loaded_perl_set_vim") 
  let &cpo = s:cpo_save
  finish 
endif
let g:loaded_perl_set_vim = 1

" exported function !
function! Def_MapPerl(key,expr1,expr2)
  if exists('b:usemarks') && b:usemarks
    return "\<c-r>=MapNoContext2('".a:key."',BuildMapSeq('".a:expr2."'))\<cr>"
    " return "\<c-r>=MapNoContext2('".a:key."',BuildMapSeq(\"".a:expr2."\"))\<cr>"
  else
    return "\<c-r>=MapNoContext2('".a:key."', '".a:expr1."')\<cr>"
    " return "\<c-r>=MapNoContext2('".a:key."', \"".a:expr1."\")\<cr>"
  endif
endfunction

function! Def_AbbrPerl(key,expr)
  if exists('b:usemarks') && b:usemarks
    let rhs = "BuildMapSeq('".a:expr."')"
  else
    let rhs = "'".substitute(a:expr, '!mark!', '', 'g')."'"
  endif
  if exists('g:c_nl_before_bracket') && g:c_nl_before_bracket
    let rhs = substitute(rhs, '\(BuildMapSeq\)\@<!(', '\\<cr\\>\0', 'g')
  endif
  if exists('g:c_nl_before_curlyB') && g:c_nl_before_curlyB
    let rhs = substitute(rhs, '{', '\\<cr\\>\0', 'g')
  endif
  let g:toto = "\<c-r>=MapNoContext('".a:key."',". rhs . ")\<cr>"
  return "\<c-r>=MapNoContext('".a:key."',". rhs . ")\<cr>"
endfunction


" }}}
  let &cpo = s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
