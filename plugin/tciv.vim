if exists('g:loaded_tciv') || v:version < 704 || &cp   
    finish
endif
let g:loaded_tciv = 0
let s:save_cpo = &cpo
set cpo&vim

function! CodeiumInVimInit()
    echo "tciv.vim plugin loaded"
    let g:loaded_tciv = 1
    let g:bmf_symb= ['', '', '', '', '']
    let g:bmf_list = {}
    let g:bmf_keys = ['alert', 'ok', 'warning', 'error', 'info']
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
        echo "No signs on this line: " .. line('.')
    else
        echo "List of signs:"
        for l:sign in l:signs
            echo " Line: " .. l:sign.lnum  .. " Sign: " .. l:sign.name .. " Id: " .. l:sign.id
        endfor
    endif
endfunction

function! ListSignsAtBuffer()
    call setqflist([],'r')
    try
        let l:signs = sign_getplaced(bufnr('%'), {'group': 'signs'})[0].signs->sort({a, b -> a.lnum-  b.lnum})
        if len(l:signs) == 0
            echo "No signs"
        else
            echo "List of signs:"
            for l:sign in l:signs
                echo " Line: " .. l:sign.lnum  .. " Sign: " .. l:sign.name .. " Id: " .. l:sign.id 
                call setqflist([],'a',{'items':[{'lnum': l:sign.lnum, 'text': printf(" %-12s |Id: %d", l:sign.name , l:sign.id)}],'title': 'List of signs at buffer','idx':'$'})
            endfor
        endif
    catch
        echo "Ooops! error with list signs at buffer: "..v:exception
    endtry
endfunction

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

function! RemoveSign(lnum, name, id)
    if a:id <= 0
        echo "Ooops! id is not a valid number sign id "
        return v:false
    else
        try
            let g:sign_id = sign_unplace('signs', {'id': a:id})
            if g:sign_id ==# 0
                echo "Remove a sign at line: " .. a:lnum .. " " .. a:name .. " id: " .. a:id
            else
                echo "Ooops! id:" .. a:id .. " is not  a valid sign id "
            endif
        catch
            echo "Ooops! error with remove a sign: "..v:exception
        endtry
    endif
endfunction

function! RemoveAllSigns(lnum = line('.'), lname = "")
    let l:signs = sign_getplaced(bufnr('%'), {'lnum': a:lnum, 'group': 'signs'})[0].signs
    if len(l:signs) > 0
        for i in range(len(l:signs))
            call RemoveSign( l:signs[i].lnum, l:signs[i].name, l:signs[i].id)
        endfor
    else
        echo "No signs on this line: " .. a:lnum .. " nothing to remove"
    endif
endfunction

function! JumpToSign(lnum, lname)
    let g:line_tojump = 0
    let l:signs = sign_getplaced(bufnr('%'), {'lnum': a:lnum, 'group': 'signs'})[0].signs
    if len(l:signs) > 0
        let l:id = l:signs[0].id
        try
            let g:line_tojump = sign_jump(l:id, 'signs', bufnr('%'))
        catch
            echo "Ooops! error with jump to a sign: "..v:exception
        endtry
    else
        echo "No signs on this line: " .. a:lnum .. " nothing to jump"
    endif
    return g:line_tojump
endfunction

function! GetSigns(A, L, P)
    let l:signs = sign_getplaced(bufnr('%'), {'group': 'signs'})[0].signs
    let g:customSignList =[]
    if len(l:signs) > 0
        for i in range(len(l:signs))
            let l:sign = l:signs[i]
            call add(g:customSignList, l:sign.lnum .. " " .. l:sign.name)
        endfor
    endif
    return g:customSignList
endfunction

function! SignList(A, L, P)
    return  g:bmf_signs->keys()->sort()
endfunction

if has('vim_starting') 
    autocmd VimEnter * call CodeiumInVimInit()
else
    call CodeiumInVimInit()
endif

command! -nargs=0 ListSigns :call ListSigns()
command! -nargs=0 ListSignsAtBuffer :call ListSignsAtBuffer()
command! -nargs=* -complete=customlist,GetSigns RemoveAllSigns :call RemoveAllSigns(<f-args>)
command! -nargs=1 -complete=customlist,SignList AddSign :call AddSign(<f-args>)
command! -nargs=* -complete=customlist,GetSigns JumpToSign :call JumpToSign(<f-args>)

nnoremap <silent> <Plug>AddSign :AddSign<space><tab>
if !hasmapto('<Plug>AddSign')
    nmap <leader>as <Plug>AddSign
endif
nnoremap <silent> <Plug>RemoveAllSigns :RemoveAllSigns<space><tab>
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
nnoremap <silent> <Plug>JumpToSign :JumpToSign<space><tab>
if !hasmapto('<Plug>JumpToSign')
    nmap <leader>js <Plug>JumpToSign
endif

let &cpo = s:save_cpo
unlet s:save_cpo
