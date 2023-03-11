vim9script

const WIN_ALREADY_FOCUSED = 0 
const WIN_FOCUSED_ON_MODIFIABLE = 1
const WIN_NOT_FOUND = 2

def FocusIfOpen(filename: string): number
    var f_ret = WIN_NOT_FOUND
    for buf in getbufinfo()
        if buf.loaded && buf.name == filename && len(buf.windows) > 0
            win_gotoid(buf.windows[0])
            return WIN_ALREADY_FOCUSED
        elseif len(buf.windows) > 0 && getbufvar(buf.bufnr, '&buftype') != "terminal"
            if f_ret != WIN_FOCUSED_ON_MODIFIABLE
                win_gotoid(buf.windows[0])
                if !&modified
                    f_ret = WIN_FOCUSED_ON_MODIFIABLE
                endif
            endif
        endif
    endfor
    return f_ret
enddef

export def HandleJsonInput(json_msg: dict<any>): void
    var key_name = "file_path"
    var cmd = ""
    if has_key(json_msg, "cmd")
        cmd = json_msg["cmd"]
    endif
    if has_key(json_msg, key_name)
        var file_path = json_msg[key_name]
        var line = json_msg["line"][1 : -1]
        var f_ret = FocusIfOpen(file_path)
        if f_ret != WIN_ALREADY_FOCUSED
            if cmd == "/v"
                execute 'vsplit ' .. file_path
            elseif cmd == "/t"
                execute 'tabnew ' .. file_path
            else
                if f_ret == WIN_FOCUSED_ON_MODIFIABLE
                    execute "edit " .. file_path
                else
                    execute 'vsplit ' .. file_path
                endif
            endif
        endif
        execute ':' .. line
    endif
enddef
