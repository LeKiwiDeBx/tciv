vim9script
if !has('vim9script') || v:version < 900
    finish
endif
g:loaded_tciv9 = true
const BMF_KEYS = ['alert', 'ok', 'warning', 'error', 'info']
const BMF_SYMB = ['', '', '', '', '']
var bmf_signs: dict<string> 

def CodeiumInVimInit(): bool
    try
        if len(BMF_SYMB) == len(BMF_KEYS)
            for i in range(len(BMF_KEYS))
                bmf_signs->extend({[BMF_KEYS[i]]: BMF_SYMB[i]})
                BMF_KEYS[i]->sign_define({"text": bmf_signs[BMF_KEYS[i]]})
            endfor
            return true
        else
            echo "Ooops! error with init of bmf_signs"
            return false
        endif
    catch
        echo "Ooops! error with init " .. v:exception
        return false
    endtry
enddef

def ListSignsAtBuffer()
    setqflist([], 'r')
    var signs = bufnr('%')->sign_getplaced({'group': 'signs'})[0].signs->sort((a: dict<any>, b: dict<any>) => a.lnum - b.lnum)
    for sign in signs
        setqflist([], 'a', {'items': [{'lnum': sign.lnum, 'text': bmf_signs[sign.name] .. ' ' .. sign.name}]})
    endfor
enddef

def AddSign(sign: string = 'info'): number
    var sign_id = sign_place(0, 'signs', sign, bufnr('%'), {'lnum': line('.')})
    ListSignsAtBuffer()
    return sign_id
enddef

def RemoveAllSignsAtLine(line: string = '0'): void
    var lnum: number = line ==# '0' ? line('.') : line->str2nr()
    var signs = bufnr('%')->sign_getplaced({'lnum': lnum, 'group': 'signs'})[0].signs
    for sign in signs
        sign_unplace('signs', {'id': sign.id})
    endfor
    ListSignsAtBuffer()
enddef

var ListKeys = (A: string, L: string, P: number): list<string> => BMF_KEYS->copy()->sort()
command! -nargs=* -complete=customlist,ListKeys AddSign call AddSign(<f-args>)
command! -nargs=? RemoveSign call RemoveAllSignsAtLine(<f-args>)

nnoremap <silent> <Plug>AddSign :AddSign<space><tab>
if !hasmapto('<Plug>AddSign')
    nmap <leader>as <Plug>AddSign
endif

nnoremap <silent> <Plug>RemoveAllSignsAtLine :RemoveSign<cr>
if !hasmapto('<Plug>RemoveAllSignsAtLine')
    nmap <leader>rs <Plug>RemoveAllSignsAtLine
endif

CodeiumInVimInit()
copen
