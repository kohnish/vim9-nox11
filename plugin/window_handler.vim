vim9script

var focused = "f"
var not_found_focused_on_non_terminal = "t"
var not_found_only_terminal = "o"
var not_found = "n"

def FocusIfOpen(filename: string): string
    for buf in getbufinfo()
        if buf.loaded && buf.name == filename && len(buf.windows) > 0
            win_gotoid(buf.windows[0])
            return focused
        elseif &buftype == "terminal" && buf.loaded && len(buf.windows) > 0 && getbufvar(buf.bufnr, '&buftype') != "terminal"
            win_gotoid(buf.windows[0])
            return not_found_focused_on_non_terminal
        endif
    endfor
    if &buftype == "terminal"
        return not_found_only_terminal
    endif
    return not_found
enddef

export def HandleJsonInput(json_msg: dict<any>): void
    var key_name = "file_path"
    if has_key(json_msg, key_name)
        var file_path = json_msg[key_name]
        if filereadable(file_path)
            var f_ret = FocusIfOpen(file_path)
            if f_ret == not_found_only_terminal
                execute 'tabnew ' .. file_path
            elseif f_ret != focused
                if &modified
                    execute 'vsplit ' .. file_path
                else
                    execute "edit " .. file_path
                endif
            endif
        endif
    endif
enddef
