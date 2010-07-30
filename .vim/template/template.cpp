VimL:" C/C++ File Template, Luc Hermitte, 30th mar 2003
VimL: let s:suffix = exists("g:abi") && g:abi ? '-abi' : ''
VimL: call s:Include( (expand("%:e") =~ '^hh\=$\|^hpp$') ? ('c-header' . s:suffix) : ('c-imp' . s:suffix))
