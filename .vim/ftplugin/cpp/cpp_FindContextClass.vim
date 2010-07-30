" ========================================================================
" File:		cpp_FindContextClass.vim
" Author:	Luc Hermitte <MAIL:hermitte at free.fr>
" 		<URL:http://hermitte.free.fr/vim/>
"
" Last Update:	16th dec 2002
"
" Dependencies:	VIM 6.0+

" Defines: {{{
" (*) Function: Cpp_SearchClassDefinition(lineNo)
"     Returns the class name of any member at line lineNo -- could be of the
"     form: "A::B::C" for nested classes.
"     Note: Outside class-scope, an empty string is returned
"     Note: Classes must be correctly defined: don't forget the ';' after the
"     '}'
" (*) Function Cpp_BaseClasses(lineNo)
"     Return the list of the direct base classes of the class around lineNo.
"     form: "+a_public_class, #a_protected_class, -a_private_class"
" }}}
" History:	{{{
" 	16th dec 2002
" 	(*) Bug fixed regarding forwarded classes.
" 	16th oct 2002
" 	(*) Able to handle C-definitions like 
" 	    "typedef struct foo{...} *PFoo,Foo;"
" 	(*) An inversion problem, with nested classes, fixed.
" 	(*) Cpp_SearchClassDefinition becomes obsolete. Instead, use
" 	    Cpp_CurrentScope(lineNo, scope_type) to search for a 
" 	    namespace::class scope.
" 	11th oct 2002
" 	(*) Cpp_SearchClassDefinition supports: 
" 	    - inheritance -> 'class A : xx B, xx C ... {'
" 	    - and declaration on several lines of the previous inheritance
" 	    text.
" 	(*) Functions that will return the list of the direct base classes of
" 	    the current class.
" }}}
"
" TODO: {{{
" (*) Support templates -> A<T>::B, etc
" (*) Ignore, whithin comments, any text matching either part or the searched pair.
" (*) Find the list of every base class ; aim: be able to retrieve the list of
"     every virtual function available to the class.
" (*) Must we differentiate anonymous namespaces from the global namespace ?
" }}}
" ==========================================================================
" No reinclusion {{{
if exists("g:loaded_cpp_FindContextClass_vim") 
      \ && !exists('g:force_load_cpp_FindContextClass')
  finish
endif
let g:loaded_cpp_FindContextClass_vim = 1
  "" line continuation used here ??
  let s:cpo_save = &cpo
  set cpo&vim
" }}}
" ==========================================================================
" Internal regexes {{{
" Note: this regex can be tricked with nasty comments
let s:id             = '\(\<\I\i*\>\)'
let s:class_token    = '\<\(class\|struct\)\>'
let s:class_part     = s:class_token  . '\_s\+' . s:id
let s:namespace_part = '\<\(namespace\)\>\_s\+' . s:id
" let s:namespace_part = '\<\(namespace\)\>\_s\+' . s:id . '\='
" Use '\=' for anonymous namespaces

" let s:class_open      = '\_.\{-}{'
" '.' -> '[^;]' in order to avoid forward declarations.
let s:class_open      = '\_[^;]\{-}{'
let s:class_close     = '}\%(\_s\+\|\*\=\s*\<\I\i*\>,\=\)*;'
  "Note: '\%(\_s*\|\*=\s*\<\I\i*\>,\=\)*' is used to accept C typedef like :
  "  typedef struct foo {...} *PFoo, Foo;
let s:namespace_open  = '\_s*{'
let s:namespace_close = '}'
" }}}
" ==========================================================================
" Search for current and most nested namespace/class <internal> {{{
function! s:CurrentScope(bMove,scope_type)
  let flag = a:bMove ? 'bW' : 'bnW'
  return searchpair(
	\ substitute(s:{a:scope_type}_part, '(', '%(', 'g')
	\ . s:{a:scope_type}_open, '', s:{a:scope_type}_close, flag)
  "Note: '\(..\)' must be changed into '\%(...\)' with search() and
  "searchpair().
endfunction
" }}}
" ==========================================================================
" Search for a class definition (not forwarded definition) {{{
" Checks whether lineNo is in between the '{' at line classStart and its
" '}' counterpart ; in that case, returns "::".className
function! s:SearchClassOrNamespaceDefinition(class_or_ns)
  let pos = 1
  let scope = ''
  while pos > 0
    let pos = s:CurrentScope(1, a:class_or_ns)
    if pos > 0
      let current_scope = substitute(getline(pos),
	    \ '^.*'.s:{a:class_or_ns}_part.'.*$', '\2', '')
      let scope = '::' . current_scope . scope
    endif
  endwhile
  return substitute (scope, '^:\+', '', 'g')
endfunction
" }}}
" ==========================================================================
" Search for a class definition (not forwarded definition) {{{
" Function: Cpp_SearchClassDefinition(lineNo [, bNamespaces])
" Checks whether lineNo is in between the '{' at line classStart and its
" '}' counterpart ; in that case, returns "::".className
function! Cpp_SearchClassDefinition(lineNo,...)
  " let pos = a:lineNo
  exe a:lineNo
  let scope = s:SearchClassOrNamespaceDefinition('class')
  if (a:0 > 0) && (a:1 == 1)
    let ns = s:SearchClassOrNamespaceDefinition('namespace') 
    let scope = ns . (((""!=scope) && (""!=ns)) ? '::' : '') . scope
  endif
  exe a:lineNo
  return scope
endfunction

" Possible Values:
"  - 'class'
"  - 'namespace'
"  - 'any'
function! Cpp_CurrentScope(lineNo, scope_type)
  exe a:lineNo
  if a:scope_type =~ 'any\|§§'
    let scope = s:SearchClassOrNamespaceDefinition('class')
    let ns = s:SearchClassOrNamespaceDefinition('namespace') 
    let scope = ns . (((""!=scope) && (""!=ns)) 
	  \ ? ((a:scope_type == '§§') ? '§::§' : '::') 
	  \ : '') . scope
  elseif a:scope_type =~ 'class\|namespace'
    let scope = s:SearchClassOrNamespaceDefinition(a:scope_type)
  else
    echoerr 'cpp_FindContextClass.vim::Cpp_CurrentScope(): the only ' . 
	  \ 'scope-types accepted are {class}, {namespace} and {any}!'
    return ''
  endif
  exe a:lineNo
  return scope
endfunction
" }}}
" ==========================================================================
" Search for templates specs <internal> {{{
function! s:TemplateSpecs()
endfunction
" }}}
" ==========================================================================
" Search for the direct base classes <internal>{{{
function! s:BaseClasses(pos)
  " a- Retrieve the declaration: 'class xxx : yyy {' zone limits {{{
  let pos = a:pos
  let end_pos = line('$')
  let decl = ''
  while pos < end_pos
    " Concat lines and strip comments on the way to the '{'.
    let text = substitute(getline(pos), '/\*.\{-}\*/\|//.*$', '', 'g')
    let decl = decl . ' ' . text
    if text =~ '{' | break | endif
      let pos = pos + 1
    endwhile
    " }}}
    " b- Get the base classes only {{{
    let base = substitute(decl, '^.*'.s:class_part.'[^:]*:\([^{]*\){.*$', '\3','')
    let base = substitute(base, 'public',    '+', 'g')
    let base = substitute(base, 'protected', '#', 'g')
    let base = substitute(base, 'private',   '-', 'g')
    let base = substitute(base, '\s*', '', 'g')
    let base = substitute(base, ',', ', ', 'g')
    " }}}
    return base
  endfunction
  " }}}
  " ==========================================================================
  " Search for the direct base classes {{{
  function! Cpp_BaseClasses(lineNo)
    exe a:lineNo
    let pos = s:CurrentScope(1, 'class')
    exe a:lineNo
    return (pos > 0) ? s:BaseClasses(pos) : ''
  endfunction
  " }}}
  " ==========================================================================
  let &cpo = s:cpo_save
  " ========================================================================
  " vim60: set fdm=marker:
