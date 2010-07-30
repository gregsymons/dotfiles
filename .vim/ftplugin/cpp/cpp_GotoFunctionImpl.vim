" File:		cpp_GotoFunctionImpl.vim
" Authors:	{{{
" 		From an original mapping by Leif Wickland (VIM-TIP#335)
" 		See: http://vim.sourceforge.net/tip_view.php?tip_id=335 
" 		Firstly changed into a plugin (Mangled by) Robert KellyIV
" 		<Feral at FireTop.Com> 
" 		Rewrote by Luc Hermitte <hermitte at free.fr>, but features
" 		and fixes still mainly coming from Robert's ideas.
" 		<URL:http://hermitte.free.fr/vim/>
" }}}
" Last Change:	17th oct 2002
" Version:	0.6
" History: {{{ 
" 	Note: for simplicity reasons, this ftplugin may accept illegal C++
" 	code. If you find such a broken C++-rule, send me an email to see if I
" 	can fix it.
"    [Luc: 17th oct 2002] v0.6: {{{
"	(*) Supports destructors
"	(*) Supports namespaces: 
"	    + If the zone where the function implementation is going to be
"	      inserted is within a namespace, then the scope of the function
"	      will be corrected.
"	    + The |search-implementation| feature is able to differentiate
"	      functions according to the namespace they are within, and thus
"	      it is able jump to the right function. For instance:
"	        int NS::CL::FN(int i) {}	// is NS::CL::FN
"	        namespace NS0 {
"	            int NS::CL::FN(int i) {}	// is NS0::NS::CL:FN
"	        }
"    	(*) Checks whether the function is a pure virtual method and refuse to
"    	    define an implementation in such cases ...
"    	(*) When searching for the implementation of a function within the
"    	    .cpp file, comments before the signature will be ignored ; i.e.
"    	    the cursor will move to the return-type. The difference is
"    	    noticeable on virtual or static functions.
"    	(*) s/GIMPL/GOTOIMPL
"	Todo:
"	(*) Pb (now hanging) when searching/building/checking when GOTOIMPL is
"	    invoked on a non function
"	(*) Pb when GOTOIMPL invoked on a function call within an
"	    implementation -- searching/checking for {} may do the trick
"	(*) Skip comments with searchpair()
"	}}}
"    [Luc: 15th oct 2002] v0.5: {{{
"	(*) The management of cpp_options.vim has been moved to another file. 
"	(*) Comments are completly ignored when searching for the
"    	    implementation of a function. Actually, the match is done
"    	    according to the list of types only -- even parameter names will
"    	    be ignored.
"    	    Hence: the programmer can change the name of the parameters and/or
"    	    add comments wherever she want whithin the function's header.
"    	    Parameters-types Supported: 
"    	    - simple types (int, unsigned short int, signed double, etc)
"    	    - pointers, references and const modifiers usable
"    	    - arrays "T p[][xx]"
"    	    - arrays of pointers and pointers of arrays: 
"    	    	"T (*p)[][N]", "T* p[][N]"
"    	    - complex types with scopes : "T1::T2::T3"
"	(*) Inlines functions (within the class def) (ie not prototypes) will
"    	    be ignored
"	(*) Enhancements and little bugs corrections regaring default
"	    parameters 
"	(*) We can specify where we want the default implementation code to be
"	    written ; cf cpp_options.vim and g:cpp_FunctionPosition.
"    	Todo:
"    	(*) Check about declared exceptions : 'throws'
"    	(*) Possibility to extend the list of simple types (__int64, long
"    	    long, UINT, etc) on user request/conf.
"    	(*) Support very complex types : function types, template types.
"    	    Must we consider that p for "T p[10]", "T p[]" and "T p[N]" have
"    	    the same type ? 
"    	    Don't differenciate:
"    	      "T * p$" and "T (*p)$" ; "const T" and "T const"
"    	}}}
"    [Luc: 08th oct 2002] v0.4: {{{
"    	(*) Accepts comments within the signature and trim them.
"    	(*) If something is written between the ')' and the ';', even on
"    	    new line, it will be understood as part of the prototype
"    	    (typically 'const' and '=0').
"    	    But: We can not put the cursor on this particular line and then
"    	    invoke the command ; the last line accepted is the one of the
"    	    closing parenthesis.
"    	}}}
"    [Luc: 08th oct 2002] v0.3: {{{
"    	(*) No more parameters don't require anymore to be on the same line
"    	    But, the return type and the possible const modifier on the
"    	    function must.
"    	(*) No more registers, 
"    	(*) Works with member and non-member functions.
"    	(*) Requires some other files of mine.
"    	    => Can handle nested class.
"    	(*) If an implementation already exists for the function, we go to
"    	    this implementation, otherwise we add it at once.
"    	(*) The command accept optional arguments
"    	(*) Add two default mappings for normal and insert modes, can be
"    	    easily remapped to anything we want.
"    	(*) Divergenge in the versionning from now
"    	Todo:
"    	(*) Enable multilines prototypes
"    	    Status: Half implemented in 0.4
"    	(*) Memorize the current cursor position ? -> option
"    	(*) Use tags to achieve a more accurate search
"    	(*) Check whether the function is a pure virtual method and refuse to
"    	    define an implementation ...
"    	    Status: done in 0.6
"    	}}}
"    [Feral:274/02@20:42] v0.2: {{{
"	Improvments: from Leif's Tip (#335): 
"	(*) can handle any number of default params (as long as they are all 
"	    on the same line!) 
"	    Status: 2/3 fixed with ver 0.4
"	(*) Options on how to format default params, virtual and static. 
"	         (see below) TextLink:||@|Prototype:| 
"	(*) placed commands into a function (at least I think it's an
"	    improvement ;) ) 
"	(*) Improved clarity of the code, at least I hope. 
"	(*) Preserves registers/marks. (rather does not use marks), Should not
"	    dirty anything. 
"	(*) All normal operations do not use mappings i.e. :normal! 
"	   (I have Y mapped to y$ so Leif's mappings could fail.) 
" 
"	Limitations: 
"	(*) fails on multi line declarations. All params must be on the same 
"	    line. 
"	    Status: 2/3 fixed with ver 0.4
"	(*) fails for non member functions. (though not horibly, just have to
"	    remove the IncorectClass:: text... 
"	    Status: fixed with 0.3.
"	}}}
"    [Leif:] v0.1 {{{
"	 Leif's original VIM-Tip #335 
"	}}}
" }}} 
" Requirements: {{{
" 		VIM 6.0, 
" 		cpp_FindContextClass.vim, cpp_options-commands.vim, 
" 		a.vim
" }}}
"#############################################################################
" Buffer Relative stuff {{{
if exists("b:loaded_ftplug_cpp_GotoFunctionImpl_vim") 
      \ && !exists('g:force_load_cpp_GotoFunctionImpl_vim')
    finish 
endif 
let b:loaded_ftplug_cpp_GotoFunctionImpl_vim = 1 
let s:cpo_save=&cpo
set cpo&vim

" ==========================================================================

" Possible Arguments:
"  'ShowVirtualon', 'ShowVirtualoff', 'ShowVirtual0', 'ShowVirtual1',
"  'ShowStaticon', '..off', '..0' or '..1'
"  'ShowDefaultParamson', '..off', '..0', '..1',  or '..2'
command! -buffer -nargs=* GOTOIMPL call <SID>GrabFromHeaderPasteInSource(<f-args>)
" In order to insert the default implementation when the user want it (with
" the option g:cpp_FunctionPosition set to 3 ; Robert's approach) or after a
" positionning error (ie: if a searched pattern is not found, them :PASTEIMPL
" will be usable).
command! -buffer -nargs=0 PASTEIMPL call <SID>InsertCodeAtLine()

" Mappings {{{
" normal mode mapping ; still possible to set parameters
nnoremap <buffer> <Plug>GotoImpl	:GOTOIMPL<SPACE>
nnoremap <buffer> <Plug>PasteImpl	:PASTEIMPL<CR>
if !hasmapto('<Plug>GotoImpl', 'n')
  nmap <buffer> ;GI <Plug>GotoImpl
  " <LeftMouse> is used to position the cursor first
  nmap <buffer> <M-LeftMouse>  <LeftMouse><Plug>GotoImpl<CR>
endif
if !hasmapto('<Plug>PasteImpl', 'n')
  nmap <buffer> ;PI <Plug>PasteImpl
  nmap <buffer> <M-RightMouse> <LeftMouse><Plug>PasteImpl
endif
" insert mode mapping ; use global parameters
inoremap <buffer> <Plug>GotoImpl	<C-O>:GOTOIMPL<CR>
inoremap <buffer> <Plug>PasteImpl	<C-O>:PASTEIMPL<CR>
if !hasmapto('<Plug>GotoImpl', 'i')
  imap <buffer> <C-X>GI <Plug>GotoImpl
  imap <buffer> <M-LeftMouse>  <LeftMouse><Plug>GotoImpl
endif
if !hasmapto('<Plug>PasteImpl', 'i')
  imap <buffer> <C-X>PI <Plug>PasteImpl
  imap <buffer> <M-RightMouse> <LeftMouse><Plug>PasteImpl
endif
" Mappings }}}

" }}}
"=============================================================================
" Global definitions {{{
if exists("g:loaded_cpp_GotoFunctionImpl_vim") 
      \ && !exists('g:force_load_cpp_GotoFunctionImpl_vim')
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_cpp_GotoFunctionImpl_vim = 1
"------------------------------------------------------------------------
" VIM Includes {{{
"------------------------------------------------------------------------
" Function: s:ErrorMsg {{{
function! s:ErrorMsg(text)
  if has('gui_running')
    call confirm(a:text, '&Ok', '1', 'Error')
  else
    " echohl ErrorMsg
    echoerr a:text
    " echohl None
  endif
endfunction " }}}
" Dependencies {{{
function! s:CheckDeps(Symbol, File, path) " {{{
  if !exists(a:Symbol)
    exe "runtime ".a:path.a:File
    " runtime ftplugin/cpp/cpp_FindContextClass.vim
    if !exists(a:Symbol)
      if has('gui_running')
	call s:ErrorMsg(
	      \ 'cpp_GotoFunctionImpl.vim: Requires <'.a:File.'>',
	      \ '&Ok', '1', 'Error')
      else
	" echohl ErrorMsg
	echoerr 'cpp_GotoFunctionImpl.vim: requires <'.a:File.'>'
	" echohl None
      endif
      return 0
    endif
  endif
  return 1
endfunction " }}}
if   
      \    !s:CheckDeps('*Cpp_CurrentScope', 
      \			'cpp_FindContextClass.vim', 'ftplugin/cpp/')
      \ || !s:CheckDeps(':CheckOptions',
      \			'cpp_options-commands.vim', 'ftplugin/cpp/')
  let &cpo=s:cpo_save
  finish
endif
" }}}
" }}}
"------------------------------------------------------------------------
" Function: s:GetFunctionPrototype " {{{
" Todo: 
" * Retrieve the type even when it is not on the same line as the function
"   identifier.
" * Retrieve the const modifier even ahen it is not on the same line as the
"   ')'.
function! s:GetFunctionPrototype(lineNo)
  exe a:lineNo
  " 0- Goto end of current line of prototype (stop at the first found)
  normal! 0
  call search( ')\|\n')
  " 1- Goto start of current prototype
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')\%(\n\|[^;]\)*;.*$\ze', 'bW')
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')', 'bW')
  let pos = searchpair('\<\i\+\>\_s*(', '', ')\_[^{};]*;', 'bW')
  let l0 = line('.')
  " 2- Goto the "end" of the current prototype
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')', 'W')
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')\%(\n\|[^;]\)*;\zs','W')
  let pos = searchpair('\<\i\+\>\_s*(', '', ')\_[^{};]*;\zs', 'W')
  let l1 = line('.')
  " Abort if nothing found
  if ((0==pos) || (l0>a:lineNo)) | return '' | endif
  " 3- Build the protoype string
  let proto = getline(l0)
  while l0 < l1
    let l0 = l0 + 1
    " Add the line, and trim any comments ending the line
    let proto = proto . "\n" .
	  \ substitute(getline(l0), '\s*//.*$\|\s*/\*.\{-}\*/\s*$', '', 'g')
	  " \ substitute(getline(l0), '//.*$', '', 'g')
	  " \ substitute(getline(l0), '//.*$\|/\*.\{-}\*/', '', 'g')
  endwhile
  " 4- and return it.
  exe a:lineNo
  return proto
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:TrimParametersNames(str) {{{
" Some constant regexes {{{
let s:type_sign = 'unsigned\|signed'
let s:type_size = 'short\|long'
let s:type_main = 'void\|char\|int\|float'
let s:type_simple = s:type_sign.'\|'.s:type_size.'\|'.s:type_main
let s:type_scope1 = '\%(::\s*\)\=\<\I\i*\>'
let s:type_scope2 = '\s*::\s*\<\I\i*\>'
let s:type_scope  = s:type_scope1.'\%('.s:type_scope2.'\)*'
let s:re = '^\s*\%(\<const\>\s*\)\='.
      \ '\%(\%('.s:type_simple.'\|\s\+\)\+\|'.s:type_scope.'\)'.
      \ '\%(\<const\>\|\*\|&\|\s\+\)*'
" }}}
function! s:TrimParametersNames(str) " {{{
  " Stuff Supported: {{{
  " - Simple parameters		 : "T p"
  " - Arrays			 : "T p[][n]"
  " - Arrays of pointers	 : "T (*p)[n]"
  " - Scopes within complex types: "T1::T2"
    " Todo: support templates like "A<B,C>"
    " Todo: support functions like "T (*NameF)(P1, P2, ...)" , 
    " 				   "T (CL::* pmf)(params)"
  " }}}
  " Cut the signature in order to concentrate of the most outer parenthesis
  let head = matchstr(a:str, '^[^(]*(')
  let tail = matchstr(a:str, ')[^)]*$')
  let params = matchstr(a:str, '^[^(]*(\zs.*\ze)[^)]*$')
  let params_types = ''
  " Loop on the parameters
  while '' != params
    " Get the parameter field
    let field  = matchstr(params, '^[^,]*')
    let params = matchstr(params, ',\zs.*$')

    " Handle case of arrays {{{
    let p = 0
    let array = ''
    while -1 != p
      let p = match(field, '\[.\{-}\]', p)
      if -1 == p | break | endif
      let array = array . 
	    \ substitute(matchstr(field, '\[.\{-}\]', p),
	    \            '[[\]]', ' \\\0 ', 'g')
      let p = p + 1 
    endwhile " }}}
    " Extract the type of the parameter and only the type
    let type = matchstr(field, s:re)
    " let type = matchstr(field, '^\s*\(\<const\>\s*\)\='.
	  " \ '\(\('.s:type_simple.'\|\s\+\)\+\|\<\I\i*\>\)'.
	  " \ '\(\<const\>\|\*\|&\|\s\+\)*')
    " Check for special pointers stuff "T (*p_id)"
    let ptr = matchstr(field, '(\s*\*\s*\(\<\I\i*\>\)\=\s*)')
    let id = (""!=ptr) ? ' ( \* \%(\<\I\i*\>\)\= ) ' : ' \%(\<\I\i*\>\)\= '
    " Build the regex containing the parameter type, spaces, etc
    let params_types = params_types.','.
	  \ substitute(type, '\*', '\\\0', 'g')
	  \ . id
	  \ . array
	  " \ type.'\%(\<\I\i*\>\)\= '
  endwhile

  " Return the final regex to search.
  return substitute(head . strpart(params_types,1) . tail, '\s\s\+', ' ', 'g')
endfunction " }}}
" Function: s:TrimParametersNames(str) }}}
"------------------------------------------------------------------------
" Function: s:BuildRegexFromImpl {{{
" Build the regex that will be used to search the signature in the
" implementations file
function! s:BuildRegexFromImpl(impl,className)
  " trim spaces {{{
  let impl2search = substitute(a:impl, "\\(\\s\\|\n\\)\\+", ' ', 'g')
  " }}}
  " trim comments {{{
  let impl2search = substitute(impl2search, '/\*.\{-}\*/\|//.*$', '', 'g')
  " }}}
  " destructor ? {{{
  let impl2search = substitute(impl2search, '\~', '\\\0', 'g')
  " }}}
  " '[,' '],' pointers {{{
    " let impl2search = substitute(impl2search, '\s*\([[\]*]\)\s*', ' \\\1 ', 'g')
    " Note: these characters will be backspaced into s:TrimParametersNames
  let impl2search = substitute(impl2search, '\s*\([[\]*]\)\s*', ' \1 ', 'g')
  " }}}
  "  <, >, =, (, ), ',' and references {{{
  let impl2search = substitute(impl2search, '\s*\([<>=(),&]\)\s*', ' \1 ', 'g')
  " }}}
  " Check pure virtual functions: {{{
  if impl2search =~ '=\s*0\s*;\s*$' | return '§pure§' | endif
  " }}}
  " Start and end {{{
  let impl2search = substitute(impl2search, '^\s*\|\s*;\s*$', '', 'g')
  " }}}
  " Default parameters -> comment => ignored along with spaces {{{
  let impl2search = substitute(impl2search, '=[^,)]\+', '', 'g')
  " }}}
  " virtual and static -> comment => ignored along with spaces {{{
  let impl2search = substitute(impl2search, 
	\ '\_s*\<\%(virtual\|static\)\>\_s*', '', 'g')
  " }}}
  " Trim the variables names {{{
  " Todo: \(un\)signed \(short\|long\) \(int\|float\|double\)
  "       const, *
  "       First non spaced type + exceptions like: scope\s*::\s*type ,
  "       class<xxx,yyy> (scope or type)
  let impl2search = s:TrimParametersNames(impl2search)
  " }}}
  " class name {{{
  let className = a:className . (""!=a:className ? '::' : '')
  if className =~ '§::§'
    let ns = matchstr(className, '^.*\ze§::§') . '::'
    let b = substitute(ns, '[^:]', '', 'g')
    let b = substitute(b, '::', '\\%(', 'g')
    let ns_re = b.substitute(ns, '\<\I\i*\>::', '\0\\)\\=', 'g')
    let cl_re = matchstr(className, '§::§\zs.*$')
    let className = ns_re.cl_re
  endif
  let className   = substitute(className, '\s*::\s*', ' :: ', 'g')
  " let g:className = className
  let impl2search = substitute(impl2search, '\%(\\\~\)\=\<\I\i*\>\_s*(', 
	\ escape(className, '\' ) .'\0', '')
  " }}}

  " let g:impl2search = impl2search
  " Spaces & comments -> '\(\_s\|/\*.\{-}\*/\|//.*$\)*' and \i {{{
  let impl2search = substitute(' \zs'.impl2search, ' ', 
	\ '\\%(\\_s\\|/\\*.\\{-}\\*/\\|//.*$\\)*', 'g')
  " Note: \%(\) is like \(\) but the subexpressions are not counted.
  " Note: ' \zs' inserted at the start of the regex helps ignore any comments
  " before the signature of the function.
  " }}}
  " Return the regex built {{{
  return '^'.impl2search.'\_s*{'
  " }}}
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:Search4Impl(re_impl, scope):bool {{{
function! s:Search4Impl(re_impl, scope)
  " 0- Pretransformations {{{
  let required_ns = matchstr(a:scope, '^.*\ze§::§')
  " }}}
  " 1- Memorize position {{{
  let l0 = line('.')
  " }}}
  " 2- Loop until the implementation is found, {{{
  "    *and* the scope (namespaces) matches
  normal! gg
  " let l = 1
  while 1 " l > 0
    " a- search for an acceptable implementation {{{
    "    Note: re_impl looks like :
    "    'type \(\(ns1::\)\=ns2::\)\=cl1::cl2::function(...)'
    let l = search(a:re_impl, 'W')
    if l <= 0 | break | endif
    " }}}
    " b- Get the current namespace at the found line {{{
    let current_ns = Cpp_CurrentScope(l, 'namespace')
    " }}}
    " c- Build the function name that must be found on the current line {{{
    "    The function aname also contain the scope
    " let req_proto  = matchstr(required_ns, current_ns.
	  " \ (current_ns == '') ? '.*$' : '::\zs.*$')
    " }}}
    " d- Retrieve the actual function name (+ relative scope) {{{
    let z=@"
    let fe=&foldenable
    set nofoldenable
    let mv = l."gg".virtcol('.').'|'
    if search('(', 'W') <= 0 
	  " echoerr "Wierd Error!!!" 
    endif
    silent exe 'normal! v'.mv.'y'
    let &foldenable=fe
    let current_proto = matchstr(@", '\%(::\|\<\I\i*\>\)\+\ze($')
    let proto0= @"
    let @" = z
    " Todo: purge comments within current_proto
    " }}}
    " e- Check if really found {{{
    " if match(required_ns, '^'.current_ns) == 0 
	  " \ && (req_proto == current_proto)
    let current = current_ns . ((current_ns != "") ? '::' : '' ).current_proto
    if ("" != required_ns) && (required_ns !~ '.*::$')
      let required_ns = required_ns . '::' 
    endif
    " call confirm('required_ns='.required_ns.
	  " \ "\ncurrent_proto=".current_proto.
	  " \ "\ncurrent_ns=".current_ns.
	  " \ "\n".l."=".getline('.').
	  " \ "\n\nreq_proto=".req_proto.
	  " \ "\n\nmv=".mv."\nproto0=".proto0."\ncurrent=".current,
	  " \ '&ok', 1)
    if match(current,'^'.required_ns) == 0 
      return l 
    endif
    " }}}
  endwhile
  " }}}
  " 2.b- Not found {{{
  exe l0
  return 0
  " }}}
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:BuildFunctionSignature4impl " {{{
function! s:BuildFunctionSignature4impl(proto,className)
  " 1- XXX if you want virtual commented in the implementation: 
  let impl = substitute(a:proto, '\(\<virtual\>\)\(\s*\)', 
	\ (1 == s:ShowVirtual ? '/*\1*/\2' : ''), '')

  " 2- XXX if you want static commented in the implementation: 
  let impl = substitute(impl, '\(\<static\>\)\(\s*\)', 
	\ (1 == s:ShowStatic ? '/*\1*/\2' : ''), '')

  " 3- Handle default params, if any. 
  "    0 -> ""              : ignored
  "    1 -> "/* = value */" : commented
  "    2 -> "/*=value*/"    : commented, spaces trimmed
  "    3 -> "/*value*/"     : commented, spaces trimmed, no equal sign
  if     s:ShowDefaultParams == 0 | let pattern = '\2'
  elseif s:ShowDefaultParams == 1 | let pattern = '/* = \1 */\2' 
  elseif s:ShowDefaultParams == 2 | let pattern = '/*=\1*/\2'
  elseif s:ShowDefaultParams == 3 | let pattern = '/*\1*/\2'
  else                            | let pattern = '\2'
  endif
  " Todo: this doesn't support defaults like : "p=fn()"
  " let impl = substitute(impl, '\s*\(=\s*\([^,)]\{1,}\|//\|/\*\)\)', pattern, 'g')
  let impl = substitute(impl, '\s*=\s*\(.\{-}\)\(\s*\(/\*\|[,)]\|//\)\)', pattern, 'g')
  let impl = substitute(impl, "\n\\(\\s*\\)\\*/", "\\*/\n\\1", 'g')

  " 4- Add '::' to the class name (if any).
  let className = a:className . (""!=a:className ? '::' : '')
  " if "" != className | let className = className . '::' | endif
  let impl = substitute(impl, '\~\=\<\i\+\>\('."\n".'\|\s\)*(', 
	\ className.'\0', '')

  " 5- Remove last part
  let impl = substitute(impl, '\s*;\s*$', "\n{\n}", '')
  " 6- Return
  return impl
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:SearchLineToAddImpl() {{{
function! s:SearchLineToAddImpl()
  if     g:cpp_FunctionPosition == 0 " {{{
    return line('$') +
	  \ (exists('g:cpp_FunctionPosArg') ? g:cpp_FunctionPosArg : 0)
    " }}}
  elseif g:cpp_FunctionPosition == 1 " {{{
    if !exists('g:cpp_FunctionPosArg') 
      call s:ErrorMsg('cpp_GotoFunctionImpl.vim: The search pattern '.
	    \'<g:cpp_FunctionPosArg> is not defined')
      return -1
    endif
    let s=search(g:cpp_FunctionPosArg)
    if 0 == s
      call s:ErrorMsg("cpp_GotoFunctionImpl.vim: Can't find the pattern\n".
	    \'   <g:cpp_FunctionPosArg>: '.g:cpp_FunctionPosArg)
      return -1
    else
      return s
    endif
    " }}}
  elseif g:cpp_FunctionPosition == 2 " {{{
    if     !exists('g:cpp_FunctionPosArg') 
      call s:ErrorMsg('cpp_GotoFunctionImpl.vim: No positionning '.
	    \ 'function defined thanks to <g:cpp_FunctionPosArg>')
      return -1
    elseif !exists('*'.g:cpp_FunctionPosArg) 
      call s:ErrorMsg('cpp_GotoFunctionImpl.vim: The function '.
	    \ '<g:cpp_FunctionPosArg> is not defined')
      return -1
    endif
    exe "return ".g:cpp_FunctionPosArg."()"
    " }}}
  elseif g:cpp_FunctionPosition == 3 | return -1
  endif
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:InsertCodeAtLine([code [,line]]) {{{
function! s:InsertCodeAtLine(...)
  if     a:0 >= 2 | let p = a:2       | let impl = a:1
  elseif a:0 >= 1 | let p = line('.') | let impl = a:1
  else            | let p = line('.') | let impl = s:FunctionImpl
  endif
  " Check namespace value
  let ns = Cpp_CurrentScope(p, 'namespace')
  let ns0 = ns
  let impl0 = impl
  " call confirm('ns  ='.ns."\nimpl=".impl, '&Ok', 1)
  while ns != ""
    let n0 = matchstr(ns, '^.\{-}\ze\%(::\|$\)')
    if impl =~ '\s'.n0.'\%(::\|§::§\)'
      " call confirm('trim: '.n0, '&OK', 1)
      let impl = substitute(impl, '\(\s\)'.n0.'\%(::\|§::§\)', '\1', 'g')
    else
      call s:ErrorMsg( 'cpp_GotoFunctionImpl.vim: Namespaces mismatch!!!'.
	    \ "\n\nCan't insert <".
	    \ matchstr(impl0, '\%(::\|§::§\|\<\I\i*\>\)*\ze\_s*(').
	    \ '> within the namespace <'.ns.'>')
      " let g:impl0=impl0
      return 
    endif
    let ns = matchstr(ns, '::\zs.*$')
    " call confirm('ns  ='.ns."\nimpl=".impl, '&Ok', 1)
  endwhile
  " Change my namespace delimiters (§::§) to normal scope delimiters (::)
  let impl = substitute(impl, '§::§', '::', '')
  " Unfold folders otherwise there could be side effects with ':put'
  let folder=&foldenable
  set nofoldenable
  " Insert the default function implementation at position 'p'
  silent exe p."put=impl"
    " Note: unlike 'put', 'append' can't insert multiple lines.
    " call append(p, impl)
  " Reindent the newly inserted lines
  let nl = strlen(substitute(impl, "[^\n]", '', 'g'))
  let p = p + 1
  silent exe p.','.(p+nl).'v/^$/normal! =='
  " Restore folding
  let &foldenable=folder
endfunction
" }}}
"------------------------------------------------------------------------
" Function: s:GrabFromHeaderPasteInSource "{{{ 
" The default values for 'HowToShowVirtual', 'HowToShowStatic' and
" 'HowToShowDefaultParams' come from cpp_options.vim ; they can be overidden
" momentarily.
" Parameters: 'ShowVirtualon', 'ShowVirtualoff', 'ShowVirtual0', 'ShowVirtual1',
" 	      'ShowStaticon', '..off', '..0' or '..1'
" 	      'ShowDefaultParamson', '..off', '..0', '..1',  or '..2'
function! s:GrabFromHeaderPasteInSource(...)
  " 0- Check options {{{
  :CheckOptions
  let s:ShowVirtual		= g:cpp_ShowVirtual
  let s:ShowStatic		= g:cpp_ShowStatic
  let s:ShowDefaultParams	= g:cpp_ShowDefaultParams
  if 0 != a:0
    let i = 0
    while i < a:0
      let i = i + 1
      let varname = substitute(a:{i}, '\(.*\)\(on\|off\|\d\+\)$', '\1', '') 
      if varname !~ 'ShowVirtual\|ShowStatic\|ShowDefaultParams' " Error {{{
	call s:ErrorMsg(
	      \ 'cpp_GotoFunctionImpl.vim::GrabFromHeaderPasteInSource: Unknown parameter : <'.varname.'>')
	return
      endif " }}}
      let val = matchstr(a:{i}, '\(on\|off\|\d\+\)$')
      if     val == 'on'  | let val = 1
      elseif val == 'off' | let val = 0
      elseif val !~ '\d\+'
	call s:ErrorMsg(
	      \ 'cpp_GotoFunctionImpl.vim::GrabFromHeaderPasteInSource: Invalid value for parameter : <'.varname.'>')
	return
      endif
      exe "let s:".varname."= val"
      " call confirm(s:{varname}.'='.val, '&ok', 1)
    endwhile
  endif
  " }}}

  " 1- Retrieve the context {{{
  " 1.1- Get the class name,if any -- thanks to cpp_FindContextClass.vim
  let className = Cpp_CurrentScope(line('.'), '§§')
  " 1.2- Get the whole prototype of the function (even if on several lines)
  let proto = s:GetFunctionPrototype(line('.'))
  if "" == proto
    call s:ErrorMsg('cpp_GotoFunctionImpl.vim: We are not within a function prototype!')
    return
  endif
  " }}}

  " 2- Build the result strings {{{
  let impl2search = s:BuildRegexFromImpl(proto,className)
  if "§pure§" == impl2search 
    call s:ErrorMsg("cpp_GotoFunctionImpl.vim:\n\n".
	  \ "Pure virtual functions don't have an implementation!")
    return
  endif
  let impl        = s:BuildFunctionSignature4impl(proto,className)
  " }}}

  " 3- Add the string into the implementation file {{{
  " neutralize mu-template {{{
  if exists('g:mu_template') && 
	\ (!exists('g:mt_jump_to_first_markers') || g:mt_jump_to_first_markers)
    " NB: g:mt_jump_to_first_markers is true by default
    let mt_jump = 1
    let g:mt_jump_to_first_markers = 0
  endif " }}}
  if exists(':AS') " from a.vim
    silent AS cpp
  else
    let file = fnamemodify(expand('%'), ':r') . '.cpp'
    silent exe ":sp ".file
  endif
  " Search or insert the C++ implementation
  if !s:Search4Impl(impl2search, className)
    " Todo: Suport looking into other files like the .inl file

    " Insert the C++ code at the end of the file
    let p = s:SearchLineToAddImpl()
    if -1 != p
      call s:InsertCodeAtLine(impl, p)
      let s:FunctionImpl = impl
    else
      " Otherwise, we use a method somehow like the one used by Robert:
      " We store the text to insert in a specific variable and wait for manual
      " insertion of the text.
      let s:FunctionImpl = impl
    endif
  endif

  " call confirm(impl, '&ok', 1)
  " restore mu-template " {{{
  if exists('mt_jump')
    let g:mt_jump_to_first_markers = mt_jump
    unlet mt_jump
  endif " }}} 
  " }}}
endfunction 
" }}}
"------------------------------------------------------------------------
let &cpo=s:cpo_save
" }}}
"=============================================================================
" Documentation {{{
"***************************************************************** 
" given: 
"    virtual void Test_Member_Function_B3(int _iSomeNum2 = 5, char * _cpStr = "Yea buddy!"); 

" Prototype: 
"GrabFromHeaderPasteInSource(VirtualFlag, StaticFlag, DefaultParamsFlag) 

" VirtualFlag: 
" 1:    if you want virtual commented in the implimentation: 
"    /*virtual*/ void Test_Member_Function_B3(int _iSomeNum2 = 5, char * _cpStr = "Yea buddy!"); 
" else:    remove virtual and any spaces/tabs after it. 
"    void Test_Member_Function_B3(int _iSomeNum2 = 5, char * _cpStr = "Yea buddy!"); 

" StaticFlag: 
" 1:    if you want static commented in the implementation: 
"    Same as virtual, save deal with static 
" else:    remove static and any spaces/tabs after it. 
"    Same as virtual, save deal with static 

" DefaultParamsFlag: 
" 1:    If you want to remove default param reminders, i.e. 
"    Test_Member_Function_B3(int _iSomeNum2, char * _cpStr); 
" 2:    If you want to comment default param assignments, i.e. 
"    Test_Member_Function_B3(int _iSomeNum2/*= 5*/, char * _cpStr/*= "Yea buddy!"*/); 
" 3:    Like 2 but, If you do not want the = in the comment, i.e. 
"    Test_Member_Function_B3(int _iSomeNum2/*5*/, char * _cpStr/*"Yea buddy!"*/); 
" 
" Examples: 
" smallest implementation: 
"    void Test_Member_Function_B3(int _iSomeNum2, char * _cpStr); 
":command! -nargs=0 GHPH call <SID>GrabFromHeaderPasteInSource(0,0,1) 
"    Verbose...: 
"    /*virtual*/ void Test_Member_Function_B3(int _iSomeNum2/*5*/, char * _cpStr/*"Yea buddy!"*/); 
":command! -nargs=0 GHPH call <SID>GrabFromHeaderPasteInSource(1,1,3) 
"    What I like: 
"    void Test_Member_Function_B3(int _iSomeNum2/*5*/, char * _cpStr/*"Yea buddy!"*/); 
" }}}
"=============================================================================
" vim60:fdm=marker 
