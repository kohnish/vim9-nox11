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
        git_root_dir=`git rev-parse --show-toplevel 2> /dev/null`
        if [ ! -z $git_root_dir ]; then
            _comp_file_names=($(git ls-files --full-name $git_root_dir | awk -F '/' '{print $NF}'))
        else
            _comp_file_names=($(rg --files | awk -F '/' '{print $NF}'))
        fi
        compadd $_comp_file_names
    else
        compadd $_comp_file_names
    fi
}

if [[ ! -z $VIM ]]; then
    compdef _zsh_nox11vim_completion nox11vim
fi

# This environment must exist and used by vim9-nox11
export VIM9_NOX11_SOCK_DIR=$HOME/.vim/pack/plugins/opt/vim9-nox11/.ipc
export vim_cmd=`whence -p vim`
export EDITOR=$vim_cmd

cross_realpath() (
    if [ -x "$(command -v realpath)" ]; then
        echo `realpath $1`
    else
        local orig_dir=$PWD
        cd "$(dirname "$1")"
        local real_path="$PWD/$(basename "$1")"
        cd "$orig_dir"
        echo "$real_path"
    fi
)

ipc_vim() {
    local full_file_path=`cross_realpath $1`
    local sock_name=$2
    local cmd=$3
    echo $full_file_path $cmd | nc -U ${VIM9_NOX11_SOCK_DIR}/${sock_name}.sock
}

local_vim() {
    local vim_cmd=`whence -p vim`
    local full_file_path=`cross_realpath $1`
    local sock_name=$2
    VIM9_NOX11_VIMSERVER=$sock_name $vim_cmd $full_file_path
}

vim() {
    for arg in "$@"; do
        if [[ $arg == "/v" ]]; then
            cmd="/v"
        elif [[ $arg == "/t" ]]; then
            cmd="/t"
        elif [[ $arg == "/e" ]]; then
            cmd="/e"
        fi
    done
    if [[ (! -z $VIM || ! -z $VIM_TERMINAL) && ! -z $VIM9_NOX11_VIMSERVER && ! -z $1  && (! -z $cmd || -z $2 ) ]] then
        if [[ ! -r $1 ]]; then
            echo "Cannot open non-existent file with ipc_vim"
        else
            ipc_vim $1 ${VIM9_NOX11_VIMSERVER} $cmd
            if [[ -z $VIM_TERMINAL ]]; then
                exit
            fi
        fi
    elif [[ ! -z $VIM ]]; then
        echo "Already in vim shell without socket"
    else
        local vim_cmd=`whence -p vim`
        VIM9_NOX11_VIMSERVER=VIM`date +%s` $vim_cmd $@
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
    local vim_or_nc_cmd
    local found=0
    local vim_cmd=`whence -p vim`
    local git_root_dir
    local cmd='/e'
    # Parse arg based on string instead of position or option
    for arg in "$@"; do
        if [[ -d $arg ]]; then
            search_path=$arg
        elif [[ $arg =~ '^VIM([A-Z]+|[0-9]+)$' ]]; then
            vim_server=$arg
        elif [[ $arg == "/v" ]]; then
            cmd="/v"
        elif [[ $arg == "/t" ]]; then
            cmd="/t"
        elif [[ $arg == "/e" ]]; then
            cmd="/e"
        else
            file_name=$arg
        fi
    done

    # Make sure vim_server is set
    if [[ -z $vim_server && ! -z $VIM9_NOX11_VIMSERVER ]]; then
        vim_server=$VIM9_NOX11_VIMSERVER
    elif [[ -z $vim_server ]]; then
        vim_server=VIM`date +%s`
    fi

    if [[ -S ${VIM9_NOX11_SOCK_DIR}/${vim_server}.sock ]]; then
        vim_or_nc_cmd=ipc_vim
    else
        vim_or_nc_cmd=local_vim
    fi

    ## Now we can execute vim
    # Empty argument or only server name
    if [[ -z $file_name ]]; then
        VIM9_NOX11_VIMSERVER=$vim_server $vim_cmd
    # Accessible file argument
    elif [[ -f $file_name ]]; then
        $vim_or_nc_cmd $file_name $vim_server $cmd
        found=1
    # Search file
    else 
        git_root_dir=`git rev-parse --show-toplevel 2> /dev/null`
        if [[ ! -z $git_root_dir && -z $search_path ]]; then
            result=$(git ls-files $git_root_dir | egrep "(/|^)${file_name}$")
        elif [[ ! -z $git_root_dir && ! -z $search_path ]]; then
            result=$(git ls-files $search_path | egrep "(/|^)${file_name}$")
        elif [[ ! -z $search_path ]]; then
            result=$(rg --files $search_path | egrep "(/|^)${file_name}$")
        else
            result=$(rg --files | egrep "(/|^)${file_name}$")
        fi
        if [[ -z $result ]]; then
            echo "File not found"
        elif [ `wc -l <<< $result` -ne 1 ]; then
            echo "Multiple files found"
            echo $result
        else
            $vim_or_nc_cmd $result $vim_server $cmd
            found=1
        fi
    fi
    # Exit vim shell to go to the opened file, in case of vim terminal, keep it open
    if [[ $found -eq 1 && ! -z $VIM && -z $VIM_TERMINAL ]]; then
        exit
    fi
}

