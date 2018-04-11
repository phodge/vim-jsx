runtime syntax/javascript.vim

" FIXME: I wish this wasn't necessary
if exists('+regexpengine')
  set regexpengine=1
endif

" NOTE: this syntax uses the @jsClExpr cluster from javascript.vim

" {{{ clusters

  " @jsxClAttr - attributes, properties, splat, and comments
  syn cluster jsxClAttr add=jsComment
  " @jsxClAttrExpr - anything that can follow `attr=` in a JSX tag
  " @jsxClInlineExpr - any special {...} stuff that goes inside html tags

" }}}

" {{{ highlight links

  " '<' and '>'
  hi! link jsxLTGT Keyword
  " self-closing '/' in '/>'
  hi! link jsxTagSelfClose SpecialChar

  " '&quot;' and other char sequences
  hi! link jsxHtmlEscape Function

  " body, div, and other standard tag names
  hi! link jsxKnownTag Keyword
  " other tag names
  hi! link jsxTagName Normal

  " attributes, and the '=' operator around them
  hi! link jsxAttrEquals String
  hi! link jsxAttrName Special
  hi! link jsxPropName String

  " the braces around jsx expressions
  hi! link jsxExprBraces Statement

  " the splat {...var} splat operator
  hi! link jsxAttrSplat Statement

  " string attribute values, and escaped characters inside
  hi! link jsxString Function
  hi! link jsxStringSpecial Typedef

  " unknown syntax
  hi! link jsxUnknownSyntax IncSearch




" }}}

" {{{ warnings - lowest precedence

  " cry about anything weird contained inside the tag
  syn match jsxTagUnknown contained /[^ \t\r\na-zA-Z0-9_/>-]\S*/
  hi! link jsxTagUnknown jsxUnknownSyntax

  syn match jsxOrphanLT contained $<\%(/\|\w\)\@!$
  syn cluster jsxClInlineExpr add=jsxOrphanLT
  hi! link jsxOrphanLT Error

  " lone ampersands
  syn match jsxOrphanSymbol contained /&/
  syn cluster jsxClInlineExpr add=jsxOrphanSymbol
  hi! link jsxOrphanSymbol Error

  " cry about orphaned jsx closing tags
  syn match jsxOrphanCloseTag !</\w*! contained
  hi! link jsxOrphanCloseTag Error
  syn cluster jsClExpr add=jsxOrphanCloseTag

" }}}

" {{{ normal attributes and splats (near the top for lower precedence)

  syn cluster jsxClAttr add=jsxPropName,jsxAttrName

  " properties (no value assigned)
  syn match jsxPropName /\h[a-zA-Z0-9_-]*\>/ contained

  syn match jsxAttrName /\h[a-zA-Z0-9_-]*\>=\@=/ contained
        \ nextgroup=jsxAttrEquals skipwhite skipnl
  syn match jsxAttrEquals /=/ contained
        \ nextgroup=@jsxClAttrExpr

  " splat operator
  syn region jsxAttrSplatRegion matchgroup=jsxAttrSplat start=/{\.\.\./ end=/}/ contains=@jsClExpr
        \ contained keepend extend
  syn cluster jsxClAttr add=jsxAttrSplatRegion


" }}}


" {{{ start/end tag

  " outer tag region which extends all the way to !/\zs>! or !</close\zs>! and contains:
  " attributes, opening tag name, tag self-close, jsx property splatting, and the 'inner tag'
  syn cluster jsClExpr add=jsxTagOuter
  syn cluster jsxClAttrExpr add=jsxTagOuter
  syn region jsxTagOuter matchgroup=jsxLTGT start=!<\z(\h\w*\%(\.\w\+\)*\)\@=! keepend extend
        \ matchgroup=jsxTagSelfClose end=!/\ze\z1>! end=!/>\@=!
        \ nextgroup=jsxTagGoodClosing
        \ contains=jsxTagInner,jsxTagOuterName,jsxTagUnexpectedCloseTag,jsxTagOpenError,jsxTagUnknown,@jsxClAttr
  syn match jsxTagGoodClosing contained !\w\+\%(\.\w\+\)*>! contains=jsxPossibleIdentifier
  syn match jsxTagGoodClosing contained !>!
  hi! link jsxTagGoodClosing jsxLTGT

  " inner tag region which goes from '>' all the way to '</'
  syn region jsxTagInner matchgroup=jsxLTGT start=!>! end=!<\%(/\h\w*\%(\.\w\+\)*\)\@=! keepend extend contained
        \ contains=jsxTagOuter,@jsxClInlineExpr

  syn match jsxTagOuterName /<\@<=\h\w*\%(\.\w\+\)*/ contained contains=jsxPossibleIdentifier
  syn match jsxPossibleIdentifier contained /\<\h\w*\>/ nextgroup=jsxTagNameDot contains=jsxHtmlTagName,jsUserIdentifier
  syn match jsxTagNameDot contained /\./ nextgroup=jsxIdentifierProperty
  syn match jsxIdentifierProperty contained /\h\w*/ nextgroup=jsxTagNameDot
  hi! link jsxTagNameDot jsDot

  syn match jsxTagSelfClose !/! contained
  hi! link jsxTagSelfClose SpecialChar

  " highlight mismatched ending
  syn match jsxTagUnexpectedCloseTag contained !/\@<=\h\w*\%(\.\w\+\)*>! extend
  hi! link jsxTagUnexpectedCloseTag Error
  syn match jsxTagOpenError contained !<\w*!
  hi! link jsxTagOpenError Error

" }}}

" {{{ javascript expressions embedded in tag bodies

  syn region jsxSimpleExpr contained matchgroup=jsxExprBraces start=/{/ end=/}/ keepend extend contains=@jsClExpr,jsComment
  syn cluster jsxClInlineExpr add=jsxSimpleExpr

" }}}

" {{{

  syn match jsxHtmlEscape contained /&\w\+;/ extend
  syn cluster jsxClInlineExpr add=jsxHtmlEscape

" }}}

" {{{ expression values

  " brace-enclosed expressions {}
  syn region jsxAttrValueExpr matchgroup=jsxExprBraces start=/{/ end=/}/ keepend extend contained
        \ contains=@jsClExpr
  syn cluster jsxClAttrExpr add=jsxAttrValueExpr

  " strings
  syn region jsxString start=/"/ end=/"/ contained
  syn cluster jsxClAttrExpr add=jsxString
  hi! link jsxString Function

" }}}

" {{{

  " recognised tag names
  syn keyword jsxHtmlTagName contained html
  syn keyword jsxHtmlTagName contained base head style title
  syn keyword jsxHtmlTagName contained address article footer header h1 h2 h3 h4 h5 h6 hgroup nav section
  syn keyword jsxHtmlTagName contained dd div dl dt figcaption hr li main ol p pre ul
  syn keyword jsxHtmlTagName contained a abbr b bdi bdo br cite code data dfn em i kbd mark q rp rt rtc ruby s samp small span strong sub sup time u var wbr
  syn keyword jsxHtmlTagName contained area audio map track video
  syn keyword jsxHtmlTagName contained embed object param source
  syn keyword jsxHtmlTagName contained canvas noscript script
  syn keyword jsxHtmlTagName contained del ins
  syn keyword jsxHtmlTagName contained caption col colgroup table tbody td tfoot th thead tr
  syn keyword jsxHtmlTagName contained button datalist fieldset form input keygen label legend meter optgroup option output progress select
  syn keyword jsxHtmlTagName contained details dialog menu menuitem summary
  syn keyword jsxHtmlTagName contained img
  " NOTE: deprecated
  syn keyword jsxHtmlTagName contained acronym applet basefont big blink center dir frame frameset isindex listing noembed plaintext spacer strike tt xmp
  hi! link jsxHtmlTagName Keyword

" }}}

syn sync fromstart

let b:current_syntax = "jsx"

