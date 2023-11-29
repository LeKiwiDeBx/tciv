if !has('vim9script') || v:version < 900
    finish
endif
vim9script
g:loaded_tciv9 = true
# const BMF_SYMB = ['A', 'O', 'W', 'E', 'I']
const BMF_KEYS = ['alert', 'ok', 'warning', 'error', 'info']
const BMF_SYMB = ['', '', '', '', '']
var bmf_signs: dict<string> 

def g:CodeiumInVimInit(): bool
    echo "tciv9.vim plugin loaded"
    g:loaded_tciv = 1
    if len(BMF_SYMB) == len(BMF_KEYS)
        for i in range(len(BMF_KEYS))
            bmf_signs->extend({[BMF_KEYS[i]]: BMF_SYMB[i]})
            BMF_KEYS[i]->sign_define({"text": bmf_signs[BMF_KEYS[i]]})
        endfor
        echo "Init of bmf_signs done"
        echo bmf_signs
        return true
    else
        echo "Ooops! error with init of bmf_signs"
        return false
    endif
enddef

