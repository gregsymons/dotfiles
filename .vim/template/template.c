VimL:" C/C++ File Template, Luc Hermitte, 30th mar 2003
VimL: call s:Include( (expand("%:e") =~ '^hh\=$\|^hpp$') ?'c-header' : 'c-imp')
