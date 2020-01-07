" context.vim
" Shows the context of the currently visible buffer contents
" Author:  Christian Wellenbrock <christian.wellenbrock@gmail.com>
" License: MIT license


" settings

" TODO: update docs

if exists('g:context_presenter')
    " keep the value
elseif has('nvim-0.4.0')
    let g:context_presenter = 'nvim-float'
elseif has('patch-8.1.1364')
    let g:context_presenter = 'vim-popup'
else
    let g:context_presenter = 'preview'
endif

" set this to 0 to disable this plugin on launch
" (use :ContextEnable to enable it later)
let g:context_enabled = get(g:, 'context_enabled', 1)

" set to 0 to disable default mappings and/or auto commands
let g:context_add_mappings = get(g:, 'context_add_mappings', 1)
let g:context_add_autocmds = get(g:, 'context_add_autocmds', 1)

" how many lines to use at most for the context
let g:context_max_height = get(g:, 'context_max_height', 21)

" how many lines are allowed per indent
let g:context_max_per_indent = get(g:, 'context_max_per_indent', 5)

" how many lines can be joined in one line (if they match
" g:context_join_regex) before the ones in the middle get hidden
let g:context_max_join_parts = get(g:, 'context_max_join_parts', 5)

" which character to use for the ellipsis "..."
let g:context_ellipsis_char = get(g:, 'context_ellipsis_char', '·')

let g:context_border_char = get(g:, 'context_border_char', '▬')

" TODO: mention that this is preview only
" how much to decrease window height when scrolling linewise (^E/^Y)
let g:context_resize_linewise = get(g:, 'context_resize_linewise', 0.25)

" how much to decrease window height when scrolling half-screen wise (^U/^D)
let g:context_resize_scroll = get(g:, 'context_resize_scroll', 1.0)

" lines matching this regex will be ignored for the context
" match whitespace only lines to show the full context
" also by default excludes comment lines etc.
let g:context_skip_regex = get(g:, 'context_skip_regex',
            \ '^\([<=>]\{7\}\|\s*\($\|#\|//\|/\*\|\*\($\|\s\|/\)\)\)')

" if a line matches this regex we will extend the context by looking upwards
" for another line with the same indent
" (to show the if which belongs to an else etc.)
let g:context_extend_regex = get(g:, 'context_extend_regex',
            \ '^\s*\([]{})]\|end\|else\|\(case\|default\|done\|elif\|fi\)\>\)')

" if a line matches this regex we consider joining it into the one above
" for example a `{` might be lifted to the preceeding `if` line
let g:context_join_regex = get(g:, 'context_join_regex', '^\W*$')

let g:context_highlight_normal = get(g:, 'context_highlight_normal', 'Normal')
let g:context_highlight_border = get(g:, 'context_highlight_border', 'Comment')
let g:context_highlight_tag    = get(g:, 'context_highlight_tag',    'Special')

" TODO: everything above (except context_add_mappings, context_add_autocmds,
" context_enabled) could be moved to autoload/context.vim, as they are not
" used here

" commands
command! -bar ContextActivate call context#activate()
command! -bar ContextEnable   call context#enable()
command! -bar ContextDisable  call context#disable()
command! -bar ContextToggle   call context#toggle()
command! -bar ContextUpdate   call context#update(0, 'command')


" " TODO update docs, as we changed the mappings and autocmds

" mappings
if g:context_add_mappings
    " NOTE: in the zz/zt/zb mappings we invoke zz/zt/zb twice before calling
    " context#update(). unfortunately this is needed because it seems like Vim
    " sometimes gets confused if the window height changes shortly after zz/zt/zb
    " have been executed.
    nnoremap <silent> <C-L> <C-L>:call context#update(1, 'C-L')<CR>
    nnoremap <silent> <C-E> <C-E>:call context#update(0, 'C-E')<CR>
    nnoremap <silent> <C-Y> <C-Y>:call context#update(0, 'C-Y')<CR>
    nnoremap <silent> zz     zzzz:call context#update(0, 'zz')<CR>
    nnoremap <silent> zt     ztzt:call context#update(0, 'zt')<CR>
    nnoremap <silent> zb     zbzb:call context#update(0, 'zb')<CR>
endif


" autocommands
if g:context_add_autocmds
    augroup context.vim
        autocmd!
        autocmd VimEnter     * ContextActivate
        autocmd BufAdd       * call context#update(1, 'BufAdd')
        autocmd BufEnter     * call context#update(0, 'BufEnter')
        autocmd CursorMoved  * call context#update(0, 'CursorMoved')
        autocmd VimResized   * call context#update(0, 'VimResized')
        autocmd CursorHold   * call context#update(0, 'CursorHold')
        autocmd User GitGutter call context#update(0, 'GitGutter')

    augroup END

    " TODO: move out of this check?
    " lazy loading was used
    if v:vim_did_enter
        let g:context_enabled = 0 " plugin was effectively disabled before load
        ContextActivate
    endif
endif
