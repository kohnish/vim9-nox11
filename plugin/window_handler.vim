vim9script

def FocusIfOpen(filename: string): bool
    var buffers = getbufinfo()
    for buf in buffers
        if buf.loaded && buf.name == filename
            win_gotoid(buf.windows[0])
            return true
        endif
    endfor
    return false
enddef

export def HandleJsonInput(json_msg: dict<any>): void
    var key_name = "file_path"
    if has_key(json_msg, key_name)
        var file_path = json_msg[key_name]
        if filereadable(file_path)
            if !FocusIfOpen(file_path)
                if &modified
                    execute "tabedit " .. file_path
                else
                    execute "edit " .. file_path
                endif
            endif
        endif
    endif
enddef
