" Vim File:	fileuptodate.vim
" Author:	Luc Hermitte <EMAIL:hermitte at free.fr>
" 		<URL:http://hermitte.free.fr/vim/>
" Last Update:	21st jul 2002
"
" Purpose:	Checks if a <file2> is more recent than <file1>
" ==========================================================================
"
if !exists("g:fileuptodate_vim")
  let g:fileuptodate_vim = 1
  "
  "
  " true <=> ( date(f1) <= date(f2) )
  function! IsFileUpToDate( file1, file2 )
    if !filereadable( a:file1 )
      echohl ErrorMsg 
      echo "Warning : <".a:file1. "> does not exist...!"
      echohl None
      return -1
    endif
    let IsOK = 0
    if filereadable( a:file2 )
      let d1 = getftime( a:file1 )
      let d2 = getftime( a:file2 )
      if d1 <= d2
	let IsOK = 1
      endif
    endif
    return IsOK
  endfunction

endif
