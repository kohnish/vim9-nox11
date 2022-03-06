vim9script

var WIN_FOCUSED = "f"
var WIN_NOT_FOUND_FOCUSED_ON_NON_TERMINAL = "t"
var WIN_NOT_FOUND_ONLY_TERMINAL = "o"
var WIN_NOT_FOUND = "n"

def FocusIfOpen(filename: string): string
    for buf in getbufinfo()
        if buf.loaded && buf.name == filename && len(buf.WINDOWS) > 0
            win_gotoid(buf.windows[0])
            return WIN_FOCUSED
        elseif &buftype == "terminal" && buf.loaded && len(buf.WINDOWS) > 0 && getbufvar(buf.bufnr, '&buftype') != "terminal"
            win_gotoid(buf.windows[0])
            return WIN_NOT_FOUND_FOCUSED_ON_NON_TERMINAL
        endif
    endfor
    if &buftype == "terminal"
        return WIN_NOT_FOUND_ONLY_TERMINAL
    endif
    return WIN_NOT_FOUND
enddef

export def HandleJsonInput(json_msg: dict<any>): void
    var key_name = "file_path"
    if has_key(json_msg, key_name)
        var file_path = json_msg[key_name]
        if filereadable(file_path)
            var f_ret = FocusIfOpen(file_path)
            if f_ret == WIN_NOT_FOUND_ONLY_TERMINAL
                execute 'tabnew ' .. file_path
            elseif f_ret != WIN_FOCUSED
                if &modified
                    execute 'vsplit ' .. file_path
                else
                    execute "edit " .. file_path
                endif
            endif
        endif
    endif
enddef
