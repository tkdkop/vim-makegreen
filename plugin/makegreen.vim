" plugin/makegreen.vim
" Author:   Rein Henrichs <reinh@reinh.com>
" License:  MIT License

" Install this file as plugin/makegreen.vim.

" ============================================================================

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if &cp || exists("g:makegreen_loaded") && g:makegreen_loaded
  finish
endif
let g:makegreen_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

hi GreenBar term=reverse ctermfg=white ctermbg=green guifg=white guibg=green
hi RedBar   term=reverse ctermfg=white ctermbg=red guifg=white guibg=red

function! MakeGreen(...) "{{{1
  let arg_count = a:0

  " Make sure a command isn't running
  if exists("s:error_var")
    echoerr 'Makegreen is already running!'
    return
  endif
  let s:error_var = ''

  silent! w " TODO: configuration option?
  if arg_count
    call async#job#start(split(&makeprg . " " . a:1), {
      \'on_exit': function('s:CompletionCallBack'),
      \ 'on_stdout': function('s:handler'),
      \ 'on_stderr': function('s:handler')
    \})
  else
    let job_id = async#job#start(split(&makeprg), {
      \'on_exit': function('s:CompletionCallBack')
    \})
  endif
endfunction
"}}}1

function! s:handler(job_id, data, event_type)
    let s:error_var = s:error_var . join(a:data, "\n")
endfunction

function! s:CompletionCallBack(...) "{{{1
  silent cexpr! s:error_var

  let error = s:GetFirstError()
  if error != ''
    call s:Bar("red", error)
  else
    call s:Bar("green","All tests passed")
  endif
  unlet s:error_var

  if !(exists("g:makegreen_stay_on_file") && g:makegreen_stay_on_file)
    cc!
  endif

endfunction
"}}}1
"
" Utility Functions" {{{1
function! s:GetFirstError()
  if getqflist() == []
    return ''
  endif

  for error in getqflist()
    if error['valid']
      break
    endif
  endfor
  if ! error['valid']
    return ''
  endif
  let error_message = substitute(error['text'], '^ *', '', 'g')
  let error_message = substitute(error_message, "\n", ' ', 'g')
  let error_message = substitute(error_message, "  *", ' ', 'g')
  return error_message
endfunction

function! s:Bar(type, msg)
  if a:type == "red"
    echohl RedBar
  else
    echohl GreenBar
  endif
  echon a:msg repeat(" ", &columns - strlen(a:msg) - 1)
  echohl None
endfunction

:command! -nargs=* MakeGreen :call MakeGreen(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set sw=2 sts=2:
