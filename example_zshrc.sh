# Usage
# 1. Install nox11-vim shell script to path and set compulsory environment variable (VIM9_NOX11_SOCK_DIR)
# 2. Optionally install other zsh functions in your zshrc or zshenv for replacing vim and opening files without full path

# This environment must exist and used by vim9-nox11
export VIM9_NOX11_SOCK_DIR=$HOME/.vim/pack/plugins/opt/vim9-nox11/.ipc
export EDITOR=nox11-vim
# Optionally replace vim
alias vim=nox11-vim


# Optional setting for opening files without full path with completion
_zsh_cvim_completion() {
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
    compdef _zsh_cvim_completion cvim
fi

cvim() {
    local vim_cmd=`whence -p vim`
    local vim_server
    local file_name
    local search_path
    local arg
    local result
    local found=0
    local git_root_dir
    local cmd='/e'
    # Parse arg based on string instead of position or option
    for arg in "$@"; do
        if [[ -d $arg ]]; then
            search_path=$arg
        elif [[ -f $arg ]]; then
            file_name=$arg
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

    ## Now we can execute vim
    # Empty argument or only server name
    if [[ -z $file_name ]]; then
        VIM9_NOX11_VIMSERVER=$vim_server $vim_cmd
    # Accessible file argument
    elif [[ -f $file_name ]]; then
        VIM9_NOX11_VIMSERVER=$vim_server nox11-vim $file_name $cmd
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
            VIM9_NOX11_VIMSERVER=$vim_server nox11-vim $result $cmd
            found=1
        fi
    fi
    # Exit vim shell to go to the opened file, in case of vim terminal, keep it open
    if [[ $found -eq 1 && ! -z $VIM && -z $VIM_TERMINAL ]]; then
        exit
    fi
}
