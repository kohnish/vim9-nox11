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


_zsh_nox11vim_completion() {
    if ! (( ${#_comp_file_names[@]} )); then
        local git_root_dir
        git_root_dir=`git rev-parse --show-toplevel` 2>/dev/null
        if [[ -z $git_root_dir ]]; then
            git_root_dir=.
        fi
        if [ ! -z $git_root_dir ]; then
            cd $git_root_dir > /dev/null
            _comp_file_names=($(rg --files -g '!*.jpg' -g '!*.png' -g '!*.gif' -g '!*.bmp' -g '!*.jar' -g '!build/' -g'!cmake-build-*/' . | awk -F'/' '{print $NF}'))
            cd - > /dev/null
        fi
    fi
    compadd $_comp_file_names
}

if [[ ! -z $VIM ]]; then
    compdef _zsh_nox11vim_completion nox11vim
fi

# This environment must exist and used by vim9-nox11
export VIM9_NOX11_SOCK_DIR=$HOME/.vim/pack/plugins/opt/vim9-nox11/.ipc
export vim_cmd=`which vim`

cross_realpath() (
    local orig_dir=$PWD
    cd "$(dirname "$1")"
    local link=$(readlink "$(basename "$1")")
    while [ "$link" ]; do
        cd "$(dirname "$link")"
        link=$(readlink "$(basename "$1")")
    done
    local real_path="$PWD/$(basename "$1")"
    cd "$orig_dir"
    echo "$real_path"
)

ipc_vim() {
    local full_file_path=`cross_realpath $1`
    local sock_name=$2
    echo $full_file_path | nc -U ${VIM9_NOX11_SOCK_DIR}/${sock_name}.sock
}

vim() {
    if [[ (! -z $VIM || ! -z $VIM_TERMINAL) && ! -z $VIM9_NOX11_VIMSERVER && -f $1  && -z $2 ]]; then
        local full_file_path=`cross_realpath $1`
        ipc_vim ${full_file_path} ${VIM9_NOX11_VIMSERVER}
        if [[ -z $VIM_TERMINAL ]]; then
            exit
        fi
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
        vim_server=VIM9_NOX
    fi

    ## Now we can execute vim
    # Empty argument or only server name
    if [[ -z $file_name ]]; then
        VIM9_NOX11_VIMSERVER=$vim_server VIM9_NOX11_VIMSERVER=$vim_server $vim_cmd
    # Accessible file argument
    elif [[ -f $file_name ]]; then
        ipc_vim $file_name $vim_server
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
        ipc_vim $result $vim_server
    fi
    if [[ ! -z $VIM && -z $VIM_TERMINAL ]]; then
        exit
    fi
}

