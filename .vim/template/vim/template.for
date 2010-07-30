VimL:" ``VimL for loop'' File Template, 
VimL:" Author:      Luc Hermitte <hermitte {at} free {dot} fr>
VimL:" Last Change: 30th Jul 2003
VimL:"
VimL: let s:value_start = '¡'
VimL: let s:value_end   = '¡'
VimL: let s:reindent = 1
VimL: let s:name = INPUT('Name of the iterator : ')
VimL: if "" != s:name | let s:max = INPUT('Number of iterations : ') | endif
let ¡s:name¡ = 0
while ¡s:name¡ != ¡s:max¡
	¡Marker_Txt('')¡
	let ¡s:name¡ = ¡s:name¡ + 1
endwhile
