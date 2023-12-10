if !has('vim9script') || v:version < 900
    finish
endif
vim9script
g:loaded_tciv9 = true
# const BMF_SYMB = ['A', 'O', 'W', 'E', 'I']
const BMF_KEYS = ['alert', 'ok', 'warning', 'error', 'info']
const BMF_SYMB = ['', '', '', '', '']
var bmf_signs: dict<string> 

def CodeiumInVimInit(): bool
    # echo "tciv9.vim plugin loaded"
    g:loaded_tciv = 1
    if len(BMF_SYMB) == len(BMF_KEYS)
        for i in range(len(BMF_KEYS))
            bmf_signs->extend({[BMF_KEYS[i]]: BMF_SYMB[i]})
            BMF_KEYS[i]->sign_define({"text": bmf_signs[BMF_KEYS[i]]})
        endfor
        # echo "Init of bmf_signs done"
        # echo bmf_signs
        return true
    else
        echo "Ooops! error with init of bmf_signs"
        return false
    endif
enddef

def ListSigns()
    sign_place(0, 'signs', 'alert', bufnr('%'), {'lnum': line('.')})
    sign_place(0, 'signs', 'ok', bufnr('%'), {'lnum': line('.')})
    sign_place(0, 'signs', 'warning', bufnr('%'), {'lnum': line('.') + 2 })
    # echo "Calling ListSigns"
    var signs = bufnr('%')->sign_getplaced({'lnum': line('.'), 'group': 'signs'})
    # var sortedSigns = signs[0].signs->sort({a, b -> a.name - b.name})
    # echo signs
    # echo signs[0].signs->sort((a: dict<any>, b: dict<any>) => a.name <= b.name ? -1 : 1)
enddef

def ListSignsAtBuffer()
    setqflist([], 'r')
    var signs = bufnr('%')->sign_getplaced({'group': 'signs'})[0].signs->sort((a: dict<any>, b: dict<any>) => a.lnum - b.lnum)
    for sign in signs
        setqflist([], 'a', {'items': [{'lnum': sign.lnum, 'text': bmf_signs[sign.name] .. ' ' .. sign.name}]})
    endfor
enddef

CodeiumInVimInit()
ListSigns()
ListSignsAtBuffer()
copen
