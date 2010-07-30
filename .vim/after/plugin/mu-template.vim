"«Description» File:		mu-template.vim		{{{1
" Initial Author:		Gergely Kontra <kgergely@mcl.hu>
" Last Official Version:	0.11
"
" Last Update:  30th Jul 2003
" Version:	0.32, by Luc Hermitte <hermitte {at} free {dot} fr>
" 
" Description:	Micro vim template file loader
" Installation:	{{{2
" 	Drop it into your plugin directory.
"	If you have some bracketing macros predefined, install this plugin in
"	<{runtimepath}/after/plugin/>
"	Needs: searchInRuntime.vim, bracketing.base.vim (i_CTRL-R_TAB),
"	words_tools.vim
"
" Usage:	{{{2
" 	When a new file is created, a template file is loaded ; the name of
" 	the template beeing of the form {runtimepath}/template/template.&ft ,
" 	&ft being the filetype of the new file.
"
" 	We can also volontarily invoke a template construction with 
" 		:MuTemplate id
" 	that will loads {runtimepath}/template/template.id ; cf. for instance
" 	template.cpp-class
"
"	Template file has some magic characters:
"	- Strings surrounded by ¡ are expanded by vim
"	  Eg: ¡strftime('%c')¡ will be expanded to the current time (the time,
"	  when the template is read), so 2002.02.20. 14:49:23 on my system
"	  NOW.
"	  Eg: ¡expr==1?"text1":text2¡ will be expanded as "text1" or "text2"
"	  regarding 'expr' values 1 or not.
"	- Lines starting with "VimL:" are interpreted by vim
"	  Eg: VimL: let s:fn=expand("%") will affect s:fn with the name of the
"	  file currently created.
"	- Strings between «» signs are fill-out places, or marks, if you are
"	  familiar with some bracketing or jumping macros
"
"	See the documentation for more explanation.
"
" History: {{{2
" 	v0.1	Initial release
"	v0.11	- 'runtimepath' is searched for template files,
"		Luc Hermitte <hermitte at free.fr>'s improvements
"		- plugin => non reinclusion
"		- A little installation comment
"		- change 'exe "norm \<c-j>"' to 'norm !jump!' + startinsert
"		- add '¿vimExpr¿' to define areas of VimL, ideal to compute
"		  variables
"
"	v0.1bis&ter not included in 0.11, 
"	(*) default value for g:author as it is used in some templates
"	    -> $USERNAME (windows specific ?)
"	(*) extend '¡.\{-}¡' and s:Exec() in order to clear empty lines after
"	    the interpretation of '¡.\{-}¡'
"           cf. template.vim and say 'No' to see the difference.  0.20
"	(*) Command (:MuTemplate) in order to insert templates on request, and
"	    at the current cursor position.
"	    Eg: :MuTemplate cpp-class
"	(*) s:Template() changed in consequence
"
"	v0.20bis
"	(*) correct search(...,'W') to search(...,&ws?'w':'W') 
"	    ie.: the 'wrapscan' option is used.
"	(*) search policy of the template files improved :
"	    1- search in $VIMTEMPLATES if defined 
"	    2- true search in 'runtimepath' with :SearchInRuntime if
"	       <searchInRUntime.vim> installed.
"	    3- search of the first $$/template/ directory found to define
"	       $VIMTEMPLATES
"	(*) use &fdm to ease the edition of this file
"
"	v0.22
"	(*) Add a global boolean (0/1) option:
"	    g:mt_jump_to_first_markers that specifies whether we want to jump
"	    automatically to the first marker inserted.
"
"	v0.23
"	(*) New global boolean ([0]/1) option:
"	    g:mt_IDontWantTemplatesAutomaticallyInserted that forbids
"	    mu-template to automatically insert templates when opening new
"	    files.
"	    Must be set once before mu-template.vim is sourced -> .vimrc
"
"	v0.24
"	(*) No empty line inserted along with ':r'
"	(*) Cursor correctly positioned if there is no marker to jump to.
"	(*) MuTemplate accepts paths. e.g.: :MuTemplate xslt/xsl-if
"	(*) Reindentation of the text inserted permitted when the template
"	    file contains ¿ let s:reindent = 1 ¿
"	(*) New mappings: i_CTRL-R_TAB and i_CTRL-R_SPACE. They insert the
"	    template file matching {ft}/template.{cWORD}.
"	    In case there are several matches, the choice is given to the user
"	    through a menu.
"	    For instance, try:
"	    - in a C++ file:  
"		clas^R\t
"	    - in a XSLT file:
"		xsl:i^R\t!jump!xsl:t^R\t
"
"	v0.25
"	(*) i_CTRL-R_TAB   <=> {cWORD}
"	    i_CTRL-R_SPACE <=> {cword}
"	(*) Simplification: search(...,&ws?'w':'W') <=> search(...)
"	(*) Limit cases (when there are no available template for a given
"	    filetype and current word) no more errors
"
"	v0.26
"	(*) Plugin not run if required files are missing
"	(*) Better way to join lines that must be
"	(*) New option: "[bg]:mt_how_to_join"
"
"	v0.27
"	(*) Handling of $VIMTEMPLATES improved!
"	(*) The parsing of the templates is more accurate
"	(*) New statement: "^VimL:...$" that is equivalent to "^¿...¿$"
"	(*) Default implementation for DateStamp
"	(*) The function interpreted between ¡...¡ can echo messages and still
"	    remain silent.
"	(*) Little problem with ":MuTemplate <arg>" fixed.
"
"	v0.28
"	(*) some dead code cleaned
"	
"	v0.29
"	(*) quick fixes for file encodings
"
"	v0.30
"	(*) big changes regarding the funky characters used as delimiters
"	    "¿...¿" abandonned to "VimL:..."
"	    "¡...¡" abandonned to ... WILL BE DONE IN v0.32
"	(*) little bug with Vim 6.1.362 -> s/firstline/first_line/
"
"	v0.30 bis
"	(*) no more problems when expanding a multi-lines text (like
"	    g:Author="foo\nbarr")
"	(*) New function s:Include() that be be used from template files, 
"	    cf.: template.c, template.c-imp and template.c-header
"	    As a result, a single template-file (associated to a specific
"	    filtetype) can load different other template-files.
"	(*) some code cleaning has been done
"
"	v0.31
"	(*) Add menus
"
"	v0.32
"	(*) Add a menu item for the help
"	(*) g:mt_IDontWantTemplatesAutomaticallyInserted can be changed at any
"	    time.
"	(*) Doesn't mess up with syntax/2html.vim anymore!
"
" BUGS:	{{{2
"	Globals should be prefixed. Eg.: g:author .
" 	Marker: First marker must contain text --> ???
"
" TODO:	{{{2
" 	Re-executing commands. (Can be useful for Last Modified fields).
"	Change <cword> to alternatives because of 'xsl:i| toto'.
"	Check it doesn't mess with search history, or registers.
"	Marker: Don't jump to a marker outside the inserted area.
"	Marker: Problem when modeline activates folding and we try to jump to
"	      the first marker.
"	Encoding: Accept characters other than "¡" for expressions.
"	Encoding: Test in utf-8.
"	Documentation: finish.
"	Menu: enable/disable submenus according the current &filetype.
"	Menu: toggle the value of some options.
"
"}}}1
"========================================================================
if exists("g:mu_template") | finish | endif
let g:mu_template = 1
" scriptencoding latin1

"========================================================================
" Low level functions {{{1
function! s:ErrorMsg(text) "{{{3
  if has("gui_running")
    call confirm(a:text, "&OK", 1, "Error")
  else
    " echohl ErrorMsg
    echoerr a:text
    " echohl None
  endif
endfunction
function! s:CheckDeps(Symbol, File, path) " {{{3
  if !exists(a:Symbol)
    exe "runtime ".a:path.a:File
    " runtime ftplugin/cpp/cpp_FindContextClass.vim
    if !exists(a:Symbol)
      call s:ErrorMsg('mu-templates: Requires <'.a:File.'>')
      return 0
    endif
  endif
  return 1
endfunction
" }}}1
"========================================================================
" Dependancies {{{1
if   
      \    !s:CheckDeps(':SearchInVar',    'searchInRuntime.vim', 'plugin/')
      \ || !s:CheckDeps('*GetCurrentWord', 'words_tools.vim',     'plugin/')
  let &cpo=s:cpo_save
  finish
endif
" }}}1
"========================================================================
" Default definitions and options {{{1
function! s:Option(name, default)                        " {{{2
  if     exists('b:mt_'.a:name) | return b:mt_{a:name}
  elseif exists('g:mt_'.a:name) | return g:mt_{a:name}
  else                          | return a:default
  endif
endfunction

" Define directories to search for templates               {{{2
let s:template_dirs = substitute(&runtimepath, ',\|$', '/template\0', 'g')
function! s:TemplateDirs()
  if exists('$VIMTEMPLATES') 
    " $VIMTEMPLATES is used if defined
    " This must be a list of directories separated by ';' or ','
    " Note: $VIMTEMPLATES has precedence over 'runtimepath'
    return $VIMTEMPLATES . ',' . s:template_dirs
  else
    return s:template_dirs
  endif
endfunction

" g:author : recurrent special variable                    {{{2
if !exists('g:author')
  if exists('$USERNAME')	" win32
    let g:author = $USERNAME
  elseif exists('$USER')	" unix
    let g:author = $USER
  else
    let g:author = ''
  endif
  if !exists('g:author_short')
    let g:author_short = g:author
  endif
endif

" Default implementation  for DateStamp()                  {{{2
if !exists('*DateStamp')
  function! DateStamp(...)
    if a:0 > 0
      return strftime(a:1)
    else
      return strftime('%c')
    endif
  endfunction
endif

" Tools functions                                          {{{2
" let s:value_start = '%%%('
" let s:value_end   = ')'
let s:value_start = '¡'
let s:value_end   = '¡'
function! s:Value(text)   " {{{3
  return s:value_start . a:text . s:value_end
endfunction

function! s:Command(text) " {{{3
  return 'VimL:' . a:text
endfunction

function! s:Comment(text) " {{{3
  return s:Command('" '.a:text)
endfunction

" function! s:Include()     {{{3
function! s:Include(template)
  let pos = line('.')
  let g:mt_templates_dirs = s:TemplateDirs()
  let dir = fnamemodify(a:template, ':h')
  if dir != "" | let dir = dir . '/' | endif
  let cmd = ':SearchInVar g:mt_templates_dirs '.pos.
	\ 'r '.dir.'template.'.a:template
  if &verbose >= 1
    exe cmd
  else
    silent exe cmd
  endif
  " unlet g:mt_templates_dirs

  " Note: s:last is incremented by the number of lines inserted
  let s:last = s:last + line("']") - pos
endfunction

" {[bg]:mt_jump_to_first_markers}                          {{{2
" Boolean: specifies weither we want to jump to the first marker in the file.

" How to join with next line : {[bg]:mt_how_to_join}       {{{2
"   Used only with i_CTRL-R_TAB
"   == 0 : "{pattern}^r\t foo" -> "{the template}\nfoo"
"   == 1 : "{pattern}^r\t foo" -> "{the template} foo"
"   == 2 : "{pattern}^r\t foo" -> "{the template}«» foo"
"
" }}}1
"========================================================================
" Core Functions {{{1
" s:InterpretValue() will interpret a sequence between ¡.\{-}¡ {{{2
" ... and return the computed value.
" Note: If the sequence is expanded into an empty string and ends the line in
" the template (ie a:nl=='\n'), then s:Value() returns a carriage return ('\r')
" at the end of the expression.
" To possibly expand a sequence into an empty string, use the 
" 'bool_expr ?  act1 : act2' VimL operator ; cf template.vim for examples of
" use.
function! s:InterpretValue(what,nl)
  exe 'let s:r = ' . a:what
  let r = (strlen(s:r) ? s:r. (strlen(a:nl)?"\r":'') : '') 
  if r == "" | let s:last = s:last - 1 | let s:crt = s:crt - 1 
  else
    let l = strlen(substitute(r, ".\\{-}\r\\|.\\{-}$", 'a', 'g'))
    let s:last = s:last + l - 1
    let s:crt = s:crt + l - 1
    " if l > 1
      " call confirm(r."\ncrt=".s:crt."\nlast=".s:last, '&ok', 1)
    " endif
  endif
  return r
endfunction

" s:InterpretCommand() will interpret a sequence "VimL:.*" {{{2
" ... and return nothing
" Back-Door to trojans !!!
function! s:InterpretCommand(what)
  let s:last = s:last - 1
  let s:crt  = s:crt  - 1
  exe a:what
  return ""
endfunction

function! s:InterpretLines(first_line) " {{{2
  let s:crt = a:first_line
  " As the functions executed by Exec2() may echo messages, we can not call
  " :substitute silently. Instead, 'report' is increased to 10000
  let report = &report
  set report=10000
  while s:crt <= s:last
    let the_line = getline(s:crt) 
    if the_line =~ '\c^'.s:Command('.*')
      exe s:crt.'d _'
      call s:InterpretCommand( substitute(the_line, '\c'.s:Command(''), '', ''))
    else
      exe s:crt.'s/' .s:Value('\(.\{-}\)') . '\(\n\)\=/'.
	    \ '\=<SID>InterpretValue(submatch(1),submatch(2))/ge'
    endif
    let s:crt = s:crt + 1
  endwhile
  let &report=report
endfunction

" s:Template() is the main function {{{2
function! s:Template(NeedToJoin, ...)
  " 1- Determine the name of the template file awaited {{{3
    let pos = line('.')
  if a:0 > 0 
    " let pos = line('.')
    let dir = fnamemodify(a:1, ':h')
    if dir != "" | let dir = dir . '/' | endif
    let ft  = fnamemodify(a:1, ':t')
    " first option : the template file is specified ; cf. template.cpp-class
  else       
    " let pos = '0' 
    let ft=strlen(&ft) ? &ft : 'unknown'
    let dir = ''
    " otherwise (default) : the template file is function of the current
    " filetype
  endif
  " 2- Load the associated template {{{3
  let foldenable=&foldenable
  set nofoldenable
  " because the template are suposed to be in latin1 ; and not necesserally
  " the current file
  let encoding=&encoding
  set encoding=latin1
  let ll = line('$')
  let g:mt_templates_dirs = s:TemplateDirs()
  if &verbose >= 1
    exe 'SearchInVar g:mt_templates_dirs '.pos.'r  '.dir.'template.'.ft
  else
    silent exe 'SearchInVar g:mt_templates_dirs '.pos.'r  '.dir.'template.'.ft
  endif
  " unlet g:mt_templates_dirs

  " Note: s:last is the number of the last line inserted
  let s:last=line("']")
  " 3- If succesful, interpret it {{{3
  " if (line('$') > 1) || (strlen(getline(0)) > 0)
  if (line('$') > ll) " {{{4
    " Interpret
    call s:InterpretLines(pos)
    " Reindent
    if exists('s:reindent') && s:reindent
      exe (pos).','.(s:last).'normal =='
      unlet s:reindent
    endif
    " Join with the line after the template that have been inserted
    if     a:NeedToJoin >= 2
      exe s:last."normal! A".Marker_Txt('')."\<esc>J!"
    elseif a:NeedToJoin >= 1
      exe s:last."normal! J!"
    endif
    " Goto the first line and delete it (because :r insert one useless line)
    if "" == getline(pos)
      exe pos."normal! dd0"
    else
      exe pos."normal! J!0"
    endif
    if s:Option('jump_to_first_markers',1)
      " set foldopen+=insert,jump
      normal !jump!
    endif
    " No more ':startinsert'. It seems useless and redundant with !jump!
    " startinsert
    let &encoding=encoding
    let &foldenable=foldenable
    return 1
  else " {{{4
    let &encoding=encoding
    let &foldenable=foldenable
    return 0
  endif
  " }}}3
endfunction

" s:SearchTemplates()  {{{2
command! -nargs=1 LetFiles :exe ':let s:files=s:files."\n".<q-args>'
function! s:SearchTemplates(word)
  " 1- Build the list of template files matching the current word {{{3
  let w = substitute(a:word, ':', '-', 'g').'*'
  " call confirm("w =  #".w."#", '&ok', 1)
  let s:files=''
  let g:mt_templates_dirs = s:TemplateDirs()
  exe ":SearchInVar! g:mt_templates_dirs LetFiles template.".&ft."-".w
	\ ." ".&ft."/template.".w
  " unlet g:mt_templates_dirs

  " 2- Select one template file only {{{3
  let nbChoices = strlen(substitute(s:files, "[^\n]", '', 'g'))
  " call confirm(nbChoices."\n".s:files, '&ok', 1)
  let strings =substitute(s:files, "\\(^\\|\n\\).\\{-}template[/\\\\]", 
	\ "\n", 'g')
  let strings =substitute(strings, '[/\\]template\.', '/', 'g')
  let strings =substitute(strings, '\_s*template\.', ' ', 'g')
  " if (nbChoices > 1) || ((a:word != "") && (nbChoices==1))
  if (nbChoices > 1) 
    let choice = confirm("Which template do you wish to use ?", 
	  \ "&Abort".strings, 1)
    if choice <= 1 | return "" | endif
  else 
    let choice = 2
  endif

  " File <- n^th choice
  let file = matchstr(strings, 
	\ "\\(.\\{-}\n\\)\\{".(choice-1)."}\\s*\\zs.\\{-}\\ze\\(\n\\|$\\)")
  " call confirm("choice=".choice."\nfile=".file, '&ok', 1)

  " 3- Template-file to insert ? {{{3
  if "" != file " 3.A- => YES there is one {{{4
  " 3.1- Remove the current word {{{5
    " Note: <esc> is needed to escape from "Visual insertion mode"
    " TODO: manage a blinking pb
    let l = strlen(a:word)	" No word to expand ; abort
    if     0 == l
    elseif 1 == l		" Select a one-character length word
      exe "normal! \<esc>vc\<esc>"
    else			" Select a 1_n-characters length word
      let ew = escape(a:word, '\.*[')
      call search(ew, 'b')
      exe "normal! \<esc>v/".ew."/e\<cr>c\<esc>"
      " exe "normal! \<esc>viWc\<esc>"
    endif
    " Insert a line break
    exe "normal! i\<cr>\<esc>\<up>$"
    
    " 3.2- Insert the template {{{5
    if &verbose >= 1
      call confirm("Using the template file: <".file.'>', '&ok', 1)
    endif
    " Todo: check what happens with g:mt_jump_to_first_markers off
    if !s:Template(s:Option('how_to_join',1),file)
      call s:ErrorMsg("Hum... problem inserting the template: <".file.'>') 
    endif
    " Note: <esc> is needed to escape from "Visual insertion mode"
    return "\<esc>\<right>"
  else          " 3.B- No template file available for the current word {{{4
    return ""
  endif " }}}3
endfunction

" i_CTRL-R stubbs {{{2
if 0
" s:CTRL_R() {{{3
" |i_CTRL-R_TAB| : proposes a list of templates
" |i_CTRL-R_SPACE| : expand the current word
" |i_CTRL-R_F1| : displays a short help
function! s:CTRL_R()
  " let s:alts = '' | let s:cur = 0
  while 1
    let key=getchar()
    let complType=nr2char(key)
    if -1 != stridx(" \<tab>",complType) ||
	  \ (key =~ "\<F1>")
      if     complType == " "      | return s:SearchTemplates("<cword>")
      elseif complType == "\<tab>" | return s:SearchTemplates("<cWORD>")
      elseif key       == "\<F1>" 
	echohl StatusLineNC
	echo "\r-- mode ^R (/0-9a-z\"%#*+:.-=/<tab>/<F1>)"
	echohl None
	" else
      endif
    else
      return "\<c-r>".complType
    endif
  endwhile
endfunction

  inoremap <silent> <C-R>		<C-R>=<sid>CTRL_R()<cr>
else " {{{3
  "Note: expand('<cword>') is not correct when there are characters after the
  "current curpor position
  inoremap <silent> <Plug>MuT_ckword <C-R>=<sid>SearchTemplates(GetCurrentKeyword())<cr>
  inoremap <silent> <Plug>MuT_cWORD  <C-R>=<sid>SearchTemplates(GetCurrentWord())<cr>
  if !hasmapto('<Plug>MuT_ckword', 'i')
    imap <unique> <C-R><space>	<Plug>MuT_ckword
  endif
  if !hasmapto('<Plug>MuT_cWORD', 'i')
    imap <unique> <C-R><tab>	<Plug>MuT_cWORD
  endif
endif
" }}}1
"========================================================================
" Menus {{{1
" Options                                    {{{2
" Note: must be set before the plugin is loaded -> .vimrc
let s:menu_prio = exists('g:mt_menu_priority') 
      \ ? g:mt_menu_priority : 59
if s:menu_prio !~ '\.$' | let s:menu_prio = s:menu_prio . '.' | endif
let s:menu_name = exists('g:mt_menu_name')
      \ ? g:mt_menu_name     : '&Templates.'
if s:menu_name !~ '\.$' | let s:menu_name = s:menu_name . '.' | endif

" Fonction: s:AddMenu(m_prio,m_name,name)    {{{2
function! s:AddMenu(m_name, m_prio, name)
  let m_name = a:m_name
  let m_name = substitute(m_name, '^\s*\(\S.\{-}\S\)\s*$', '\1', '')
  let name =substitute(a:name, '^.\{-}template[/\\]', '', 'g')
  let name =substitute(name,   '[/\\]template\.', '.\&', 'g')
  let name =substitute(name,   '\_s*template\.', '', 'g')
  if (name =~ '-') && (name !~ '\.&') | return | endif

  exe 'amenu '.s:menu_prio.a:m_prio
	\ escape(s:menu_name.m_name.name, '\ ').
	\ ' :MuTemplate '.substitute(name,'\.&', '/', '').'<cr>'
endfunction
command! -nargs=+ MuTAddMenu  :call s:AddMenu(<f-args>)

" Fonction: s:BuildMenu(doRebuild: boolean)  {{{2
function! s:BuildMenu(doRebuild)
  " 1- Clear previously existing menu {{{3
  if a:doRebuild
    silent! exe ":unmenu ".escape(s:menu_name, '\ ')
  endif

  " 2- Static menus                   {{{3
  exe 'amenu <silent> '.s:menu_prio.'200 '.escape(s:menu_name.'-1-', '\ '). ' <Nop>'
  exe 'amenu <silent> '.s:menu_prio.'400 '.escape(s:menu_name.'-2-', '\ '). ' <Nop>'
  exe 'amenu <silent> '.s:menu_prio.'500 '.
	\ escape(s:menu_name.'&Rebuild Menu', '\ ').
	\ ' :call <sid>BuildMenu(1)<CR>'
  exe 'amenu <silent> '.s:menu_prio.'510 '.
	\ escape(s:menu_name.'&Help', '\ ').
	\ ' :call <sid>Help()<CR>'

  " 3- New File                       {{{3
  let g:mt_templates_dirs = s:TemplateDirs()
  SearchInVar! g:mt_templates_dirs MuTAddMenu template.* |0 &New.& 100.10

  " 4- contructs                      {{{3
  SearchInVar! g:mt_templates_dirs MuTAddMenu */template.* |0 & 300.10
  delcommand MuTAddMenu

endfunction

" Load Menu                                  {{{2
if has('gui_running') && has('menu')
  call s:BuildMenu(0)
endif
" Menus }}}1
" Help {{{1
" Function: s:Help()                         {{{2
function! s:Help()
  let errmsg_save = v:errmsg
  silent! help mu-template
  if v:errmsg != ""
    if exists(':SearchInRuntime')
      command! -nargs=1 HelpTags exe 'helptags '.fnamemodify('<args>', ':h')
      SearchInRuntime HelpTags doc/mu-template.txt
      delcommand HelpTags
      silent help mu-template
    else
      call s:ErrorMsg("Please install the help for mu-template")
    endif
  endif
  let v:errmsg = errmsg_save    
endfunction
" Help }}}1
"========================================================================
" [auto]commands {{{1
command! -nargs=? MuTemplate :call <sid>Template(0, <f-args>)

function! s:AutomaticInsertion()
  return !exists('g:mt_IDontWantTemplatesAutomaticallyInserted') ||
	\ !g:mt_IDontWantTemplatesAutomaticallyInserted
endfunction

augroup template
  au!
  au BufNewFile * if s:AutomaticInsertion() | call <SID>Template(0) | endif
  "au BufWritePre * echon 'TODO'
  "au BufWritePre * normal ,last
augroup END
" }}}1
"========================================================================
" vim60: set fdm=marker:
