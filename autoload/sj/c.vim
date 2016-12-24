" Only real syntax that's interesting is cParen and cConditional
let s:skip = sj#SkipSyntax('cComment', 'cCommentL', 'cString', 'cCppString', 'cBlock')

function! sj#c#SplitFuncall()
  if sj#SearchUnderCursor('(.\{-})', '', s:skip) <= 0
    return 0
  endif

  call sj#PushCursor()

  let range_start = col( '.' )
  normal! %
  let range_end = col( '.' )
  let range = strpart( getline( '.' ), range_start - 1, (range_end - range_start) )
  normal! %

  normal! w
  let param_start = col( '.' )
  normal! F(%ge
  let param_end = col( '.' )

  let prefix_whitespace = strpart( range, 1, param_start - range_start - 1)
  let suffix_whitespace = strpart( range, param_end - range_start + 1, range_end - param_end - 1 )

  let items = sj#ParseJsonObjectBody(range_start + 1, range_end - 1)
  let body = '(' . prefix_whitespace . join(items, ",\n") . suffix_whitespace . ')'

  call sj#PopCursor()

  call sj#ReplaceMotion('va(', body)
  return 1
endfunction

function! sj#c#SplitIfClause()
  if sj#SearchUnderCursor('if\s*(.\{-})', '', s:skip) <= 0
    return 0
  endif

  let items = sj#TrimList(split(getline('.'), '\(&&\|||\)\zs'))
  let body  = join(items, "\n")

  call sj#ReplaceMotion('V', body)
  return 1
endfunction

function! sj#c#JoinFuncall()
  if sj#SearchUnderCursor('([^)]*\s*$', '', s:skip) <= 0
    return 0
  endif

  normal! va(J
  return 1
endfunction

function! sj#c#JoinIfClause()
  if sj#SearchUnderCursor('if\s*([^)]*\s*$', '', s:skip) <=  0
    return 0
  endif

  call sj#PushCursor()
  normal! f(
  normal! va(J
  call sj#PopCursor()
  return 1
endfunction
