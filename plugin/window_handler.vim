vim9script

var WIN_FOCUSED = 0 
var WIN_NOT_FOUND_FOCUSED_ON_NON_TERMINAL = 1
var WIN_NOT_FOUND_ONLY_TERMINAL = 2
var WIN_NOT_FOUND = 3

def FocusIfOpen(filename: string): number
    var f_ret = WIN_NOT_FOUND
    for buf in getbufinfo()
        if buf.loaded && buf.name == filename && len(buf.windows) > 0
            win_gotoid(buf.windows[0])
            return WIN_FOCUSED
        elseif &buftype == "terminal" && buf.loaded && len(buf.windows) > 0 && getbufvar(buf.bufnr, '&buftype') != "terminal"
            win_gotoid(buf.windows[0])
            f_ret = WIN_NOT_FOUND_FOCUSED_ON_NON_TERMINAL
        endif
    endfor
    if &buftype == "terminal" && f_ret != WIN_NOT_FOUND_FOCUSED_ON_NON_TERMINAL
        return WIN_NOT_FOUND_ONLY_TERMINAL
    endif
    return WIN_NOT_FOUND
enddef

export def HandleJsonInput(json_msg: dict<any>): void
    var key_name = "file_path"
    var cmd = ""
    if has_key(json_msg, "cmd")
        cmd = json_msg["cmd"]
    endif
    if has_key(json_msg, key_name)
        var file_path = json_msg[key_name]
        if filereadable(file_path)
            var f_ret = FocusIfOpen(file_path)
            if f_ret == WIN_NOT_FOUND_ONLY_TERMINAL
                execute 'tabnew ' .. file_path
            elseif f_ret != WIN_FOCUSED
                if &modified || cmd == "remote_vsplit"
                    execute 'vsplit ' .. file_path
                elseif cmd == "remote_tab"
                    echom "tabnew"
                    execute 'tabnew ' .. file_path
                else
                    execute "edit " .. file_path
                endif
            endif
        endif
    endif
enddef
