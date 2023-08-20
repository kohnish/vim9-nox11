vim9script

if empty($VIM9_NOX11_VIMSERVER) 
    finish
endif

import autoload "../lazyload/window_handler.vim"

var g_initialised = false

def StartServer(server_name: string): void
    if g_initialised
        return
    endif

    var job_opt = {
        "out_cb": (_, msg) => window_handler.HandleJsonInput(json_decode(msg)),
        "env": { "UV_THREADPOOL_SIZE": 1 },
        "out_mode": "raw",
        "in_mode": "json",
        "stoponexit": "int",
    }

    var script_dir = fnamemodify(resolve(expand('<script>:p')), ':h')
    var default_executable_path = script_dir .. "/../bin/vim9-nox11"

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
    g_initialised = true
enddef

if exists('g:vim9_nox11_init_on_term') && g:vim9_nox11_init_on_term
    augroup Vim9NoX11
        autocmd TerminalOpen,ShellCmdPre * StartServer($VIM9_NOX11_VIMSERVER)
    augroup END
else
    StartServer($VIM9_NOX11_VIMSERVER)
endif

def Make(...args: list<any>): void
    execute "!" .. "sh -c 'cd " ..  expand('<script>:p:h') .. "/../" .. " && make -j4 " .. join(args) .. "'"
enddef

command! -nargs=* Vim9Nox11Make Make(<q-args>)
