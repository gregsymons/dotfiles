" ========================================================================
" File:			cpp_set.vim
" Author:		Luc Hermitte <MAIL:hermitte at free.fr>
" 			<URL:http://hermitte.free.fr/vim/>
"
" Last Update:		16th Mar 2004
"
" Purpose:		ftplugin for C++ programming
"
" Dependencies:		c.set, misc_map.vim, 
" 			cpp_InsertAccessors.vim,
" 			cpp_BuildTemplates.vim
" 			VIM >= 6.00 only
"
" TODO:		
"  * Menus & Help pour se souvenir des commandes possibles
"  * Support pour l'héritage vis-à-vis des constructeurs
"  * Reconnaître si la classe courante est template vis-à-vis des
"    implementations & inlinings
" ========================================================================


" ========================================================================
" Buffer local definitions
" ========================================================================
if exists("b:loaded_local_cpp_settings") | finish | endif
let b:loaded_local_cpp_settings = 1

  "" line continuation used here ??
  let s:cpo_save = &cpo
  set cpo&vim

" ------------------------------------------------------------------------
" Commands
" ------------------------------------------------------------------------
" Cf. cpp_BuildTemplates.vim
"
" ------------------------------------------------------------------------
" VIM Includes
" ------------------------------------------------------------------------
source $VIMRUNTIME/ftplugin/cpp.vim
let b:did_ftplugin = 1
" runtime! ftplugin/c/*.vim 
" --> need to be sure that some definitions are loaded first!
"     like maplocaleader.

""so $VIMRUNTIME/macros/misc_map.vim
""so <sfile>:p:h/cpp_InsertAccessors.vim
""so <sfile>:p:h/cpp_BuildTemplates.vim

"   
" ------------------------------------------------------------------------
" Options to set
" ------------------------------------------------------------------------
"  setlocal formatoptions=croql
"  setlocal cindent
"
setlocal cinoptions=g0,t0,h1s

" browse filter
if has("gui_win32") 
  let b:browsefilter = 
	\ "C++ Header Files (*.hpp *.h++)\t*.hpp;*.h++\n" .
	\ "C++ Source Files (*.cpp *.c++)\t*.cpp;*.c++\n" .
	\ "C Header Files (*.h)\t*.h\n" .
	\ "C Source Files (*.c)\t*.c\n" .
	\ "All Files (*.*)\t*.*\n"
endif
" ------------------------------------------------------------------------
" Some C++ abbreviated Keywords
" ------------------------------------------------------------------------
Inoreab <buffer> pub public:<CR>
Inoreab <buffer> pro protected:<CR>
Inoreab <buffer> pri private:<CR>

Iabbr <buffer> tpl <C-R>=Def_AbbrC('tpl ', 'template <>!mark!\<Left\>\<Left\>\<Left\>')<CR>

inoreab <buffer> vir virtual

inoremap <buffer> <m-s> std::
inoremap <buffer> <m-b> boost::


"--- namespace ----------------------------------------------------------
"--,ns insert "namespace" statement
  vnoremap <buffer> <LocalLeader>ns 
	\ :call InsertAroundVisual('namespace {','}', 1, 1)<cr>gV
      nmap <buffer> <LocalLeader>ns V<LocalLeader>ns

"--- try ----------------------------------------------------------------
"--try insert "try" statement
	" \ .'?try\<cr\>o')<CR>
  Iabbr <buffer> try <C-R>=Def_AbbrC("try ",
	\ '\<c-f\>try {\<cr\>} catch (!mark!) {!mark!\<cr\>}!mark!\<esc\>'
	\ .'?try\<cr\>:PopSearch\<cr\>o')<CR>
"--,try insert "try - catch" statement
  vnoremap <buffer> <LocalLeader>try 
	\ :call InsertAroundVisual('try {',"} catch () {\n}", 1, 1)<cr>gV
	" \ ><esc>`>a<cr>} catch () {<c-t><cr>}<esc>`<itry {<c-f><cr><esc>/(<cr>a
      nmap <buffer> <LocalLeader>try V<LocalLeader>try

"--- catch --------------------------------------------------------------
"--catch insert "catch" statement
  Iabbr <buffer> catch <C-R>=Def_AbbrC("catch ",
	\ '\<c-f\>catch () {!mark!\<cr\>}!mark!\<esc\>?)\<cr\>:PopSearch\<cr\>i')<CR>


" ------------------------------------------------------------------------
" Comments ; Javadoc/DOC++/Doxygen style
" ------------------------------------------------------------------------
"
" /**       inserts /** <cursor>
"                    */
" but only outside the scope of C++ comments and strings
  inoremap <buffer> /**  <c-r>=Def_MapC('/**',
	\ '/**\<cr\>\<BS\>/\<up\>\<end\> ',
	\ '/**\<cr\>\<BS\>/!mark!\<up\>\<end\> ')<cr>
" /*<space> inserts /** <cursor>*/
  inoremap <buffer> /*<space>  <c-r>=Def_MapC('/* ',
	\ '/** */\<left\>\<left\>',
	\ '/** */!mark!\<esc\>F*i')<cr>

" ------------------------------------------------------------------------
" std oriented stuff
" ------------------------------------------------------------------------
" in std::foreach and std::find algorithms, expand
"   'algo(container§)' into 'algo(container.begin(),container.end()§)', 
" '§' representing the current position of the cursor.
inoremap <c-x>be .<esc>%v%<left>o<right>y%%ibegin(),<esc>paend()<esc>a

" ========================================================================
" General definitions -> none here
" ========================================================================

"if exists("g:loaded_cpp_set_vim") | finish | endif
"let g:loaded_cpp_set_vim = 1

  let &cpo = s:cpo_save
