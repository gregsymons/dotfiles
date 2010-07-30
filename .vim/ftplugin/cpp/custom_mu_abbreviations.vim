"=============================================================================
" File:		custom_mu_abbreviations.vim                                           {{{1
" Author:	Greg Symons
" Version:	1.0
" Created:	1/25/2007 4:54:59 PM
" Last Update:	1/25/2007 4:54:59 PM
"------------------------------------------------------------------------
" Description:	My own abbreviations for use with mu-template, 
" 
"------------------------------------------------------------------------
" Installation:	Requires cpp_set.vim
" History:	
" TODO:		
" }}}1
"=============================================================================


"=============================================================================
" Avoid buffer reinclusion {{{1
if exists('b:loaded_ftplug_custom_mu_abbreviations_vim') | finish | endif
let b:loaded_ftplug_custom_mu_abbreviations_vim = 1
 
let s:cpo_save=&cpo
set cpo&vim
" }}}1
"------------------------------------------------------------------------
" Commands and mappings {{{1
"Make sure cpp_set is loaded first
runtime! ftplugin/cpp/cpp_set.vim
"Load the c++ folding script
"runtime! fold/cpp-fold.vim

imap <silent> !markB! <c-r>=Marker_Open()<cr>
imap <silent> !markE! <c-r>=Marker_Close()<cr>

"Create a skeleton for a boost serialize method
Iabbr boost_serialize <C-R>=Def_AbbrC('boost_serialize ', 
   \ 'template <class Archive>\<cr\>void !mark!::serialize(Archive& theArchive, '
   \ .'BOOST_PFTO int version){\<cr\>!mark!\<cr\>}')<CR>!jumpB!!jumpB!
Iabbr bbonvp <C-R>=Def_AbbrC('bbonvp ', 'BOOST_SERIALIZATION_BASE_OBJECT_NVP()!mark!')<CR><Left><Left><Left>
Iabbr mcmwv <C-R>=Def_AbbrC('mcmwv ', 'M_CONFIG_MANAGER_WRAP_VALUE()!mark!')<CR><Left><Left><Left>
Iabbr vr <C-R>=Def_AbbrC('vr ', '(void) ')<CR>
Iabbr tdtc <C-R>=Def_AbbrC('tdtc ', 'boost::shared_ptr\<'
   \ . 'TypeDescriptorTestCaseBase\>(\<cr\>new TypeDescriptorTestCase\<!markB!TypeDescriptor!markE!, !markB!Type!markE!'
   \ . '\>(!mark!))!mark!')<CR>!jumpB!!jumpB!!jumpB!

iabbr fhdr <esc>:MuTemplate cpp/function-template<cr>
iabbr func <esc>:MuTemplate cpp/function<cr>
"enable markers
let b:usemarks=1

"add the cpp templates directory to the mu-template search path so including
"templates from there works.
let g:mt_templates_dirs+=$VIM.'/template/cpp'

" Commands and mappings }}}1
"=============================================================================
" Avoid global reinclusion {{{1
if exists("g:loaded_custom_mu_abbreviations_vim") 
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_custom_mu_abbreviations_vim = 1
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Functions {{{1


" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
