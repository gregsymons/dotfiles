" DoxyGen syntax hilighting extension for c/c++/idl
" Author: Michael Geddes <michaelrgeddes@optushome.com.au>
" Date: Dec 2000
" Version: 1.0

" NOTE:  Comments welcome!

if 0
syn clear 
doau Syntax cpp
endif


" Start of Doxygen syntax hilighting:
" 

" C/C++ Style line comments
"syn region doxygenComment start=+/\*[*!]+  end=+\*/+ contains=doxygenStart,doxygenTODO keepend
syn region doxygenComment start=+/\*[*!]+  		end=+\*/+ contains=doxygenSyncStart,doxygenStart,doxygenTODO keepend
syn region doxygenCommentL start=+//[/!]+me=e-1 end=+$+ contains=doxygenStartL keepend
syn region doxygenCommentL start=+//@[{}]+ end=+$+


" Match the Starting pattern (effectively creating the start of a BNF)
syn match doxygenStart +/\*[*!]+ contained nextgroup=doxygenBrief,doxygenPrev,doxygenStartSpecial,doxygenStartSkip,doxygenPage skipwhite skipnl
syn match doxygenStartL +//[/!]+ contained nextgroup=doxygenPrevL,doxygenBriefL,doxygenSpecial skipwhite

" This helps with sync-ing as for some reason , syncing behaves differently to a normal region, and the start pattern does not get matched.
syn match doxygenSyncStart +[^*/]+ contained nextgroup=doxygenBrief,doxygenPrev,doxygenStartSpecial,doxygenStartSkip,doxygenPage skipwhite skipnl

" Match the first sentence as a brief comment
syn region doxygenBrief contained start=+\<+ end=+[.?!]+ contains=doxygenContinueComment,doxygenErrorComment,doxygenSmallSpecial,doxygenHtmlTag,doxygenHtmlSpecial,doxygenTODO,doxygenOtherLink skipnl nextgroup=doxygenBody
syn region doxygenBriefL start=+\<+ end=+[.?!]\|$+ contained contains=doxygenSmallSpecial,doxygenHtmlTag,doxygenHtmlSpecial keepend

" Match a '<' for applying a comment to the previous element.
syn match doxygenPrev +<+ contained nextgroup=doxygenBrief,doxygenSpecial,doxygenStartSkip skipwhite
syn match doxygenPrevL +<+ contained  nextgroup=doxygenBriefL,doxygenSpecial skipwhite

" These are anti-doxygen comments.  If there are more than two asterixes or 3 '/'s
" then turn the comments back into normal C comments.
syn region cComment start="/\*\*\*" end="\*/" contains=@cCommentGroup,cCommentString,cCharacter,cNumbersCom,cSpaceError
syn region cCommentL start="////" skip="\\$" end="$" contains=@cCommentGroup,cComment2String,cCharacter,cNumbersCom,cSpaceError

" Special commands at the start of the area:  starting with '@' or '\'
syn region doxygenStartSpecial contained start=+[@\\]+ end=+$+ contains=doxygenSpecial nextgroup=doxygenSkipComment skipnl keepend
syn match doxygenSkipComment contained +^\s*\*[^/]+me=e-1 nextgroup=doxygenBrief,doxygenStartSpecial,doxygenPage skipwhite

"syn region doxygenBodyBit contained start=+$+ 

" The main body of a doxygen comment.
syn region doxygenBody contained start=+.\|$+ matchgroup=doxygenEndComment end=+\*/+re=e-2,me=e-2 contains=doxygenContinueComment,doxygenTODO,doxygenSpecial

" These allow the skipping of comment continuation '*' characters.
syn match doxygenContinueComment contained +^\s*\*[^/]+me=e-1
syn match doxygenContinueComment contained +^\s*\*$+

"syn match doxygenErrorEnd contained +/+

" Catch a Brief comment without punctuation - flag it as an error but
" make sure the end comment is picked up also.
syn match doxygenErrorComment contained +\*/+


" Skip empty lines at the start for when comments start on the 2nd/3rd line.
syn match doxygenStartSkip +^\s*\*[^/]+me=e-1 contained nextgroup=doxygenBrief,doxygenStartSpecial,doxygenStartSkip,doxygenPage skipwhite skipnl
syn match doxygenStartSkip +^\s*\*$+ contained nextgroup=doxygenBrief,doxygenStartSpecial,doxygenStartSkip,doxygenPage skipwhite skipnl

" Create the single word matching special identifiers.

fun! DxyCreateSmallSpecial( kword, name )
  exe 'syn keyword doxygenSpecial'.a:name.'Word contained '.a:kword.' nextgroup=doxygen'.a:name.'Word skipwhite'
  exe 'syn match doxygen'.a:name.'Word contained "[a-zA-Z_:0-9]\+" '
endfun
call DxyCreateSmallSpecial('p', 'Code')
call DxyCreateSmallSpecial('c', 'Code')
call DxyCreateSmallSpecial('b', 'Bold')
call DxyCreateSmallSpecial('e', 'Emphasised')
call DxyCreateSmallSpecial('em', 'Emphasised')
call DxyCreateSmallSpecial('a', 'Argument')
call DxyCreateSmallSpecial('ref', 'Ref')
delfun DxyCreateSmallSpecial

syn match doxygenSmallSpecial contained +[@\\]+ nextgroup=doxygenFormula,doxygenSymbol,doxygenSpecial.*Word


" Now for special characters
syn match doxygenSpecial contained +[@\\]+ nextgroup=doxygenParam,doxygenRetval,doxygenBriefWord,doxygenBold,doxygenBOther,doxygenOther,doxygenPage,doxygenOtherLink,doxygenSymbol,doxygenFormula,doxygenErrorSpecial,doxygenSpecial.*Word
syn match doxygenErrorSpecial contained +\s+

" Match Parmaters and retvals (hilighting the first word as special).
syn keyword doxygenParam contained param nextgroup=doxygenParamName skipwhite
syn match doxygenParamName contained +\k\++ nextgroup=doxygenSpecialMultilineDesc skipwhite
syn keyword doxygenRetval contained retval nextgroup=doxygenParamName skipwhite

" Match one line identifiers. 
syn keyword doxygenOther contained addindex anchor code 
\ defgroup dontinclude endcode endhtmlonly endlatexonly endverbatim showinitializer hideinitializer
\ example exception htmlonly image include ingroup internal latexonly line 
\ overload relates return sa see skip skipline 
\ throw until verbatim verbinclude version warning
\ nextgroup=doxygenSpecialOnelineDesc 

" Match multiline identifiers.
syn keyword doxygenBOther contained class enum file fn mainpage
\ namespace struct typedef union var def name 
\ nextgroup=doxygenSpecialTypeOnelineDesc  

syn keyword doxygenOther contained par nextgroup=doxygenHeaderLine
syn region doxygenHeaderLine start=+.+ end=+^+ contained skipwhite nextgroup=doxygenSpecialMultilineDesc 

syn keyword doxygenOther contained arg author bug date deprecated li nextgroup=doxygenSpecialMultilineDesc 

" Handle \link, \endlink, hilighting the link-to and the link text bits separately.
syn region doxygenOtherLink matchgroup=doxygenOther start=+link+ end=+[\@]endlink+ contained contains=doxygenLinkWord,doxygenContinueComment
syn match doxygenLinkWord "[_a-zA-Z:#()]\+\>" contained skipnl nextgroup=doxygenLinkRest,doxygenContinueLinkComment
syn match doxygenLinkRest +.+ contained skipnl nextgroup=doxygenLinkRest,doxygenContinueLinkComment
syn match doxygenContinueLinkComment contained +^\s*\*\=[^/]+me=e-1 nextgroup=doxygenLinkRest

" Handle \page.  This does not use doxygenBrief.
syn match doxygenPage "[\\@]page"me=s+1 contained skipwhite nextgroup=doxygenPagePage
syn keyword doxygenPagePage page contained skipwhite nextgroup=doxygenPageIdent
syn region doxygenPageDesc  start=+.\++ end=+$+ contained skipwhite contains=doxygenSmallSpecial,doxygenHtmlTag,doxygenHtmlSpecial keepend skipwhite skipnl nextgroup=doxygenBody
syn match doxygenPageIdent "\<[a-zA-Z0-9]\+\>" contained nextgroup=doxygenPageDesc

" Handle section
syn keyword doxygenOther section subsection contained skipwhite nextgroup=doxygenSpecialIdent
syn region doxygenSpecialSectionDesc  start=+.\++ end=+$+ contained skipwhite contains=doxygenSmallSpecial,doxygenHtmlTag,doxygenHtmlSpecial keepend skipwhite skipnl nextgroup=doxygenBodydyxOther,doxygenContinueComment
syn match doxygenSpecialIdent "\<[a-zA-Z0-9]\+\>" contained nextgroup=doxygenSpecialSectionDesc


" Does the one-line description for the one-line type identifiers.
syn region doxygenSpecialTypeOnelineDesc  start=+.\++ end=+$+ contained skipwhite contains=doxygenSmallSpecial,doxygenHtmlTag,doxygenHtmlSpecial keepend
syn region doxygenSpecialOnelineDesc  start=+.\++ end=+$+ contained skipwhite contains=doxygenSmallSpecial,doxygenHtmlTag,doxygenHtmlSpecial keepend

" Handle the multiline description for the multiline type identifiers.
syn region doxygenSpecialMultilineDesc  start=+.\++ skip=+^\s*\(\*[^/]\)\=\s*\([@\\]ar[^g]\|[^ \t\*]\)+ end=+^+ contained contains=doxygenSpecialContinueComment,doxygenSmallSpecial,doxygenHtmlTag,doxygenHtmlSpecial  skipwhite keepend
syn match doxygenSpecialContinueComment contained +^\s*\*[^/]+me=e-1 nextgroup=doxygenSpecial skipwhite


" Handle special cases  'bold' and 'group'
syn keyword doxygenBold contained bold nextgroup=doxygenSpecialHeading
syn keyword doxygenBriefWord contained brief nextgroup=doxygenBrief skipwhite
syn match doxygenSpecialHeading +.\++ contained skipwhite
syn keyword doxygenGroup contained group nextgroup=doxygenGroupName skipwhite
syn keyword doxygenGroupName contained +\k\++ nextgroup=doxygenSpecialOnelineDesc skipwhite

" Handle special symbol identifiers  @$, @\, @$ etc
syn match doxygenSymbol contained +[$\\&<>#]+ 


" Simplistic handling of formula regions
syn region doxygenFormula contained matchgroup=doxygenFormulaEnds start=+f\$+ end=+[@\\]f\$+ contains=doxygenFormulaSpecial,doxygenFormulaOperator
syn match doxygenFormulaSpecial contained +[@\\]\(f[^$]\|[^f]\)+me=s+1 nextgroup=doxygenFormulaKeyword,doxygenFormulaEscaped
syn match doxygenFormulaEscaped contained "."
syn match doxygenFormulaKeyword contained  "[a-z]\+"
syn match doxygenFormulaOperator contained +[_^]+

syn region doxygenFormula contained matchgroup=doxygenFormulaEnds start=+f\[+ end=+[@\\]f]+ contains=doxygenFormulaSpecial,doxygenFormulaOperator,doxygenAtom
syn region doxygenAtom contained transparent matchgroup=doxygenFormulaOperator start=+{+ end=+}+ contains=doxygenAtom,doxygenFormulaSpecial,doxygenFormulaOperator

" Add TODO hilighting.
syn keyword doxygenTODO contained TODO README XXX 

" Supported HTML subset.  Not perfect, but okay.
syn case ignore
syn region doxygenHtmlTag contained matchgroup=doxygenHtmlCh start=+</\=+ end=+>+ contains=doxygenHtmlCmd
syn keyword doxygenHtmlCmd contained img a b br p center code dfn dl em i li ol ul pre small strong sub sup table tt var nextgroup=doxygenHtmlVar skipwhite
"syntax match doxygenHtmlTag contained "<a\(\s\+\(href\|name\)\s*=\s*[^ \t=>]\+\)\s*>"
syn keyword doxygenHtmlVar contained src alt longdesc name height width usemap ismap nextgroup=doxygenHtmlEqu skipwhite
syn match doxygenHtmlEqu contained +=+ nextgroup=doxygenHtmlExpr skipwhite 
syn match doxygenHtmlExpr contained +"\(\\.\|[^"]\)*"+ nextgroup=doxygenHtmlVar skipwhite
syn case match
syn match doxygenHtmlSpecial contained "&\(copy\|quot\|[AEIOUYaeiouy]uml\|[AEIOUYaeiouy]acute\|[AEIOUaeiouy]grave\|[AEIOUaeiouy]circ\|[ANOano]tilde\);"


" Prevent the doxygen contained matches from leaking into the c groups.
syn cluster cParenGroup add=doxygen.*
syn cluster cPreProcGroup add=doxygen.*
syn cluster cMultiGroup add=doxygen.*
syn cluster rcParenGroup add=doxygen.*
syn cluster rcGroup add=doxygen.*

if !exists("did_doxygen_syntax_inits")
  let did_doxygen_syntax_inits = 1

  hi doxygenHtmlCh cterm=bold gui=bold 
  hi doxygenHtmlCmd cterm=bold gui=bold 
  hi link doxygenHtmlSpecial htmlSpecialChar
  hi link doxygenHtmlVar Type
  hi link doxygenHtmlExpr String
  hi link doxygenTODO Todo

  hi doxygenCodeWord cterm=bold font=Lucida_Console:h10
  hi doxygenBoldWord cterm=bold gui=bold
  hi doxygenEmphasisedWord cterm=italic gui=italic
  hi doxygenSmallSpecial ctermfg=DarkGrey guifg=#a0a0aa
  hi doxygenArgumentWord cterm=italic gui=italic
  hi link doxygenSpecialCodeWord doxygenSmallSpecial
  hi link doxygenSpecialEmphasisedWord doxygenSmallSpecial
  hi link doxygenSpecialBoldWord doxygenSmallSpecial


  " syn match doxygenErrorSpecial contained +.+
  hi doxygenFormulaSpecial ctermfg=DarkBlue guifg=DarkBlue
  hi doxygenFormulaKeyword cterm=bold ctermfg=DarkMagenta guifg=DarkMagenta gui=bold
  hi doxygenFormulaEscaped  ctermfg=DarkMagenta guifg=DarkMagenta gui=bold
  hi doxygenFormulaOperator cterm=bold ctermfg=Red guifg=Red gui=bold
  hi doxygenFormula ctermfg=DarkMagenta guifg=DarkMagenta
  hi doxygenSymbol cterm=bold ctermfg=DarkCyan guifg=DarkCyan gui=bold
  hi doxygenComment ctermfg=DarkRed guifg=DarkRed

  if &background=='light'
	hi doxygenBrief cterm=bold ctermfg=Cyan guifg=DarkBlue gui=bold
	hi doxygenBody ctermfg=DarkBlue guifg=DarkBlue
	hi doxygenSpecial ctermfg=Black guifg=#a0a0ee
	hi doxygenSpecialTypeOnelineDesc cterm=bold ctermfg=DarkRed guifg=firebrick3 gui=bold
	hi doxygenBOther cterm=bold ctermfg=DarkMagenta guifg=#aa50aa gui=bold
  else
	hi doxygenBrief cterm=bold ctermfg=Cyan ctermbg=darkgrey guifg=Blue gui=bold
	hi doxygenBody ctermfg=Cyan guifg=Blue
	hi doxygenSpecial ctermfg=Grey guifg=#a0a0ee
	hi doxygenSpecialTypeOnelineDesc cterm=bold ctermfg=Red guifg=firebrick3 gui=bold
	hi doxygenBOther cterm=bold ctermfg=Magenta guifg=#aa50aa gui=bold
  endif

  hi doxygenParam ctermfg=DarkGray guifg=#aa50aa
  hi doxygenParamName cterm=italic ctermfg=DarkBlue guifg=DeepSkyBlue4 gui=italic,bold
  hi doxygenSpecialOnelineDesc cterm=bold ctermfg=DarkCyan guifg=DodgerBlue3 gui=bold
  hi doxygenSpecialHeading cterm=bold ctermfg=DarkBlue guifg=DeepSkyBlue4 gui=bold
  hi doxygenPrev ctermfg=DarkGreen guifg=DarkGreen

"  hi doxygenErrorSpecial ctermbg=Red guibg=Red
  hi link doxygenErrorSpecial Error
  hi link doxygenErrorEnd Error
  hi link doxygenErrorComment Error

  hi link doxygenSpecialMultilineDesc doxygenSpecialOnelineDesc
  hi link doxygenFormulaEnds doxygenSpecial
  hi link doxygenBold doxygenParam
  hi link doxygenBriefWord doxygenParam
  hi link doxygenRetval doxygenParam
  hi link doxygenOther doxygenParam
  hi link doxygenStart doxygenComment
  hi link doxygenCommentL doxygenComment
  hi link doxygenContinueComment doxygenComment
  hi link doxygenSpecialContinueComment doxygenComment
  hi link doxygenSkipComment doxygenComment
  hi link doxygenEndComment doxygenComment
  hi link doxygenStartL doxygenComment
  hi link doxygenPrevL doxygenPrev
  hi link doxygenBriefL doxygenBrief
  hi link doxygenHeaderLine doxygenSpecialHeading
  hi link doxygenStartSkip doxygenContinueComment 
  hi link doxygenLinkWord doxygenParamName 
  hi link doxygenLinkRest doxygenSpecialMultilineDesc

  hi link doxygenPage doxygenSpecial
  hi link doxygenPagePage doxygenBOther
  hi link doxygenPageIdent doxygenParamName
  hi link doxygenPageDesc doxygenSpecialTypeOnelineDesc

  hi link doxygenSpecialIdent doxygenPageIdent 
  hi link doxygenSpecialSectionDesc doxygenSpecialMultilineDesc

  hi link doxygenSpecialRefWord doxygenOther
  hi link doxygenRefWord doxygenPageIdent
  hi link doxygenContinueLinkComment doxygenComment
endif
if &syntax=='idl'
  syn cluster idlCommentable add=doxygenComment,doxygenCommentL
endif

"syn sync clear
"syn sync maxlines=500
"syn sync minlines=50
if v:version >= 600
syn sync match doxygencComment groupthere cComment "/\@<!/\*"
syn sync match doxygenSyncComment grouphere doxygenComment "/\@<!/\*[*!]" 
else
syn sync match doxygencComment groupthere cComment "/\*"
syn sync match doxygenSyncComment grouphere doxygenComment "/\*[*!]" 
endif
"syn sync match doxygenSyncComment grouphere doxygenComment "/\*[*!]" contains=doxygenStart,doxygenTODO keepend
syn sync match doxygenSyncEndComment groupthere NONE "\*/"


