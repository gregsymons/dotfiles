"=============================================================================
" File:		ftplugin/template.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim>
" Version:	1.0
" Created:	13th nov 2002
" Last Update:	13th nov 2002
"------------------------------------------------------------------------
" Description:	ftplugin for mu-template's template files
"   It makes sure that the syntax coloration and ftplugins loaded match the
"   filetype aimed by the template file, while &filetype values 'template'.
" 
"------------------------------------------------------------------------
" Installation:	
"    (*) Drop it into {rtp}/ftplugin/
"    (*) Add into your $HOME/.vim/filetype.vim:
"        au BufNewFile,BufRead template.*  | 
"               \ if (expand('<afile>:p:h') =~? '.*\<template\%([/\\].\+\)\=') |
"               \    exe ("doau filetypedetect BufRead " . expand("<afile>"))  |
"               \    let g:ft = &ft  |
"               \    set ft=template |
"               \ endif
" History:	«history»
" TODO:		«missing features»
"=============================================================================
"
" Avoid reinclusion
if exists('b:loaded_ftplug_c__template_vim') | finish | endif
let b:loaded_ftplug_c__template_vim = 1
"
let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
exe 'runtime! syntax/'.g:ft.'.vim'
exe 'runtime! ftplugin/'.g:ft.'.vim ftplugin/'.g:ft.'_*.vim ftplugin/'.g:ft.'/*.vim'

" unlet g:ft

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
