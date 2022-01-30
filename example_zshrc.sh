# ToDo: make it work on Mac as well

# Usage 1
# nox11vim filename
# inside vim :sh or :term
# vim command or nox11vim command should reopen in the existing vim session

# Usage 2
# nox11vim filename VIMS(capital starts with VIM)
# inside vim :sh or :term
# vim command or nox11vim command should reopen in the existing vim session

# Usage 3
# nox11vim VIMS(capital starts with VIM) filename
# inside vim :sh or :term
# vim command or nox11vim command should reopen in the existing vim session

# Usage 4
# nox11vim VIMS(capital starts with VIM) (starts blank session with vim server enabled)
# inside vim :sh or :term
# vim command or nox11vim command should reopen in the existing vim session


# This environment must exist and used by vim9-nox11
export VIM9_NOX11_SOCK_DIR=$HOME/.vim/pack/plugins/opt/vim9-nox11/.ipc

ipc_vim() {
    local full_file_path=`realpath $1`
    local sock_name=$2
    echo $full_file_path | nc -U ${VIM9_NOX11_SOCK_DIR}/${sock_name}.sock
}

local_vim() {
    local vim_cmd=`which --skip-alias --skip-functions vim`
    local file_path=`realpath $1`
    local sock_name=$2
    VIM9_NOX11_VIMSERVER=$sock_name $vim_cmd $file_path
}

vim() {
    local vim_cmd=`which --skip-alias --skip-functions vim`
    local full_file_path
    if [[ ! -z $VIM && -z $VIM_TERMINAL && ! -z $VIM9_NOX11_VIMSERVER && -f $1  && -z $2 ]]; then
        full_file_path=`realpath $1`
        echo $full_file_path | nc -U ${VIM9_NOX11_SOCK_DIR}/${VIM9_NOX11_VIMSERVER}.sock
        exit
    elif [[ ! -z $VIM ]]; then
        echo "Already in vim shell without X server"
    else
        $vim_cmd $@
    fi
}

nox11vim() {
    # When inside the vim shell, no new blank session
    if [[ ! -z $VIM && -z $VIM9_NOX11_VIMSERVER ]]; then
       echo "Already in vim shell without X server"
       return
    elif [[ ! -z $VIM9_NOX11_VIMSERVER && -z $1 ]]; then
       echo "Already in vim shell"
       return
    fi

    local vim_server
    local file_name
    local search_path
    local real_search_path
    local arg
    local result
    local vim_exe=`which --skip-alias --skip-functions vim`
    local vim_cmd
    local is_vim_ipc=0
    # Parse arg based on string instead of position or option
    for arg in "$@"; do
        if [[ $arg =~ '^(.*/|\.\.|\.)$' ]]; then
            search_path=$arg
        elif [[ $arg =~ '^VIM[A-Z]+$' ]]; then
            vim_server=$arg
        else
            file_name=$arg
        fi
    done

    # Make sure vim_server is set
    if [[ -z $vim_server && ! -z $VIM9_NOX11_VIMSERVER ]]; then
        vim_server=$VIM9_NOX11_VIMSERVER
    elif [[ -z $vim_server ]]; then
        vim_server=VIMX
    fi

    if [[ -S ${VIM9_NOX11_SOCK_DIR}/${vim_server}.sock ]]; then
        is_vim_ipc=1
        vim_cmd=ipc_vim
    else
        vim_cmd=local_vim
    fi

    ## Now we can execute vim
    # Empty argument or only server name
    if [[ -z $file_name ]]; then
        VIM9_NOX11_VIMSERVER=$vim_server VIM9_NOX11_VIMSERVER=$vim_server $vim_exe
    # Accessible file argument
    elif [[ -f $file_name ]]; then
        $vim_cmd $file_name $vim_server
    # Search file
    else 
        # First search the current path
        if [[ -z $search_path ]]; then
            real_search_path=.
        else
            real_search_path=$search_path
        fi
        result="$(rg --files $real_search_path | rg /$file_name\$)"
        # When no search path is specified, try parent directory as well 
        if [[ -z $result && -z $search_path ]] then;
            result="$(rg --files .. | rg /$file_name\$)"
        fi
        if [[ -z $result ]]; then
            echo "File not found"
            return
        fi
        if [ `wc -l <<< $result` -ne 1 ]; then
            echo "Multiple files found"
            echo $result
            return
        fi
        $vim_cmd $result $vim_server
    fi
    if [[ ! -z $VIM && -z $VIM_TERMINAL ]]; then
        exit
    fi
}

