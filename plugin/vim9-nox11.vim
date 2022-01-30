vim9script

import "./job_handler.vim" as job_handler

if !empty($VIM9_NOX11_VIMSERVER) && empty($VIM9_NOX11_CURRENT_VIMSERVER)
    job_handler.StartServer($VIM9_NOX11_VIMSERVER)
endif
