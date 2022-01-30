vim9script

import "./window_handler.vim" as window_handler

def HandleStdin(channel: channel, msg: string): void
    try
        var json_msg = json_decode(msg)
        window_handler.HandleJsonInput(json_msg)
    catch
        ## Solve this issue...
        #echom msg
    endtry
enddef

export def StartServer(server_name: string): void
    var job_opt = {
        "out_cb": HandleStdin,
        "out_mode": "raw",
        "in_mode": "json",
        "stoponexit": "int",
    }
    var executable = ""
    var script_dir = fnamemodify(resolve(expand('<stack>:p')), ':h')
    if !exists('g:vim9_nox11_exe_path')
        executable = script_dir .. "/../bin/vim9-nox11"
        if has("win64") || has("win32") || has("win16")
            executable = executable .. ".exe"
        endif
    else
        executable = g:vim9_nox11_exe_path
    endif

    # ToDo: Investigate how windows IPC works
    var sock_dir = script_dir .. "/../.ipc"
    
    if !empty($VIM9_NOX11_SOCK_DIR)
        sock_dir = $VIM9_NOX11_SOCK_DIR
    endif

    if filereadable(sock_dir)
        echom "Invalid socket directory"
        return
    endif

    var sock_path = sock_dir .. "/" .. server_name .. ".sock"

    job_start([executable, sock_path], job_opt)
enddef

