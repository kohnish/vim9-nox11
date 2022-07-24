vim9script

if empty($VIM9_NOX11_VIMSERVER) 
    finish
endif

import autoload "../lazyload/window_handler.vim" as window_handler

const script_dir = fnamemodify(resolve(expand('<script>:p')), ':h')
var default_executable_path = script_dir .. "/../bin/vim9-nox11"

def StartServer(server_name: string): void
    var job_opt = {
        "out_cb": (_, msg) => window_handler.HandleJsonInput(json_decode(msg)),
        "out_mode": "raw",
        "in_mode": "json",
        "stoponexit": "int",
    }

    var executable = default_executable_path
    if !exists('g:vim9_nox11_exe_path')
        if has("win64") || has("win32") || has("win16")
            executable = default_executable_path .. ".exe"
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
        echom "Vim9-nox11: Invalid socket directory"
        return
    endif

    var sock_path = sock_dir .. "/" .. server_name .. ".sock"

    job_start([executable, sock_path], job_opt)
enddef

StartServer($VIM9_NOX11_VIMSERVER)
