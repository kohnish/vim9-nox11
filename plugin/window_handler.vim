vim9script

def FocusIfOpen(filename: string): bool
    return false
enddef

export def HandleJsonInput(json_msg: dict<any>): void
    var key_name = "file_path"
    if has_key(json_msg, key_name)
        var file_path = json_msg[key_name]
        if filereadable(file_path)
            if !FocusIfOpen(file_path)
                execute "tabedit " .. file_path
            endif
        endif
    endif
enddef
