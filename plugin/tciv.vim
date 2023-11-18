"if plugin is loaded
if exists('g:loaded_tciv')
    finish
endif
let g:loaded_tciv = 0
"functionCodeiumInVimInit to call when vim start up
function! CodeiumInVimInit()
    echo "tciv.vim plugin loaded"
    let g:loaded_tciv = 1
    "do a list g:bmf_list A O W E I
    let g:bmf_symb= ['A', 'O', 'W', 'E', 'I']
    let g:bmf_list = {}
    "create  a list with 'alert' 'ok 'warning' 'error' 'info' 'info'
    let g:bmf_keys = ['alert', 'ok', 'warning', 'error', 'info']
    "if bmf_symb and bmf_keys are equals length then let g:bmf_signs is a dictionary with keys from bmf_keys and values from bmf_symb
    if len(g:bmf_symb) == len(g:bmf_keys)
        let g:bmf_signs = {}
        for i in range(len(g:bmf_keys))
            let g:bmf_signs[g:bmf_keys[i]] = g:bmf_symb[i]  
            call sign_define(g:bmf_keys[i], {"text":g:bmf_signs[g:bmf_keys[i]]})
            echo "Sign defined: " .. g:bmf_keys[i] .. " " .. g:bmf_signs[g:bmf_keys[i]]
        endfor
    else
        echo "Ooops! error with init of bmf_signs"
    endif
endfunction
function! ListSigns()
    let l:signs = sign_getplaced(bufnr('%'), {'lnum': line('.'), 'group': 'signs'})[0].signs->sort({a, b -> a.name -  b.name})
    if len(l:signs) == 0
        echo "No signs"
    else
        echo "List of signs:"
        for l:sign in l:signs
            echo " Line: " .. l:sign.lnum  .. "Sign: " .. l:sign.name .. " group: " .. l:sign.group
        endfor
    endif
endfunction
"function list all signs at current buffer at the current buffer in a statement try catch endtry
function! ListSignsAtBuffer()
    try
        let l:signs = sign_getplaced(bufnr('%'), {'group': 'signs'})[0].signs->sort({a, b -> a.name -  b.name})
        if len(l:signs) == 0
            echo "No signs"
        else
            echo "List of signs:"
            for l:sign in l:signs
                echo " Line: " .. l:sign.lnum  .. "Sign: " .. l:sign.name .. " group: " .. l:sign.group
            endfor
        endif
    catch
        echo "Ooops! error with list signs at buffer: "..v:exception
    endtry
endfunction

"function add a sign in parameter at the current line
"at the current buffer in a statement try catch endtry
function! AddSign(sign)
    let g:sign_id = 0
    try
        let l:signs = sign_getplaced(bufnr('%'), {'lnum': line('.'), 'group': 'signs'})[0].signs
        let g:sign_id = sign_place(0, 'signs', a:sign, bufnr('%'), {'lnum': line('.')})
        if len(l:signs) == 0
            echo "Add a sign on this line: " .. line('.')
        else
            echo "Already a sign on this line: " .. line('.')
        endif
    catch
        echo "Ooops! error with add a sign: "..v:exception
    endtry
    return g:sign_id
endfunction

function! RemoveSign(arg1, arg2, arg3, sign_id)
    if a:sign_id <= 0
        echo "Ooops! id is not  a valid sign_id "
        return v:false
    else
        try
            let g:sign_id = sign_unplace('signs', {'id': a:sign_id})
        catch
            echo "Ooops! error with remove a sign: "..v:exception
        endtry
    endif
endfunction

"count all signs on  the current line and call  remove for all from gutter
function! RemoveAllSigns()
    let l:signs = sign_getplaced(bufnr('%'), {'lnum': line('.'), 'group': 'signs'})[0].signs
    if len(l:signs) > 0
        for i in range(len(l:signs))
            call RemoveSign(l:signs[i].id)
        endfor
    else
        echo "No signs on this line: " .. line('.') .. " nothing to remove"
    endif
endfunction
" Write function to jump to a sign
function! JumpToSign(sign_id)
    if a:sign_id <= 0
        echo "Ooops! id is not  a valid sign_id "
        return v:false
    else
        try
            let g:line_tojump = sign_jump(a:sign_id, 'signs', bufnr('%'))
        catch
            echo "Ooops! error with jump to a sign: "..v:exception
        endtry
    endif
    return g:line_tojump
endfunction
"create a function return a list of signs with id and line number and name
function! GetSigns(A, L, P)
    let l:signs = sign_getplaced(bufnr('%'), {'group': 'signs'})[0].signs
    let g:customSignList =[]
    if len(l:signs) > 0
        for i in range(len(l:signs))
            let l:sign = l:signs[i]
            call add(g:customSignList, l:sign.lnum .. " " .. l:sign.name .. "  id: " .. l:sign.id)
        endfor
    endif
    return g:customSignList
endfunction

function! SignList(A, L, P)
    return  g:bmf_signs->keys()->sort()
endfunction

" on vim start with vim enter load initialization function
if has('vim_starting') 
    autocmd VimEnter * call CodeiumInVimInit()
else
    call CodeiumInVimInit()
endif
"command to list all signs at current line
command! -nargs=0 ListSigns :call ListSigns()
"command to list all signs at current buffer
command! -nargs=0 ListSignsAtBuffer :call ListSignsAtBuffer()
"command to remove all signs
command! -nargs=0 RemoveAllSigns :call RemoveAllSigns()
"command to add a sign
command! -nargs=1 -complete=customlist,SignList AddSign :call AddSign(<f-args>)
"command to remove a sign
command! -nargs=* -complete=customlist,GetSigns RemoveSign :call RemoveSign(<f-args>)

nnoremap <silent> <Plug>AddSign :AddSign<space><tab>
if !hasmapto('<Plug>AddSign')
    nmap <leader>as <Plug>AddSign
endif

nnoremap <silent> <Plug>RemoveSign :RemoveSign<CR>
if !hasmapto('<Plug>RemoveSign')
    nmap <leader>rs <Plug>RemoveSign
endif

nnoremap <silent> <Plug>RemoveAllSigns :RemoveAllSigns<CR>
if !hasmapto('<Plug>RemoveAllSigns')
    nmap <leader>ras <Plug>RemoveAllSigns
endif

nnoremap <silent> <Plug>ListSigns :ListSigns<CR>
if !hasmapto('<Plug>ListSigns')
    nmap <leader>ls <Plug>ListSigns
endif

nnoremap <silent> <Plug>ListSignsAtBuffer :ListSignsAtBuffer<CR>
if !hasmapto('<Plug>ListSignsAtBuffer')
    nmap <leader>lsb <Plug>ListSignsAtBuffer
endif
