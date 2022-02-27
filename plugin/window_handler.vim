vim9script

def FocusIfOpen(filename: string): bool
    for buf in getbufinfo()
        if buf.loaded && buf.name == filename && len(buf.windows) > 0
            win_gotoid(buf.windows[0])
            return true
        endif
    endfor
    return false
enddef

def FocusOnNonTerminal(filename: string): bool
    if &buftype == "terminal"
        for buf in getbufinfo()
            if buf.loaded && len(buf.windows) > 0 && getbufvar(buf.bufnr, '&buftype') != "terminal"
                win_gotoid(buf.windows[0])
                return true
            endif
        endfor
    endif
    return false
enddef

export def HandleJsonInput(json_msg: dict<any>): void
    var key_name = "file_path"
    if has_key(json_msg, key_name)
        var file_path = json_msg[key_name]
        if filereadable(file_path)
            if !FocusIfOpen(file_path)
                if !FocusOnNonTerminal(file_path)
                    execute 'tabnew ' .. file_path
                elseif &modified
                    execute 'vsplit ' .. file_path
                else
                    execute "edit " .. file_path
                endif
            endif
        endif
    endif
enddef
