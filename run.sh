#!/bin/bash

declare -a config_paths=(
    # SOURCE                                # DEST
    "config/git/.gitconfig                  ${HOME}/.gitconfig"
    "config/git/.gitignore                  ${HOME}/.gitignore"
    "config/zsh/.zshrc                      ${HOME}/.zshrc"
    "config/zsh/.p10k.zsh                   ${HOME}/.p10k.zsh"
    "config/vscode/settings.json            ${HOME}/.config/Code/User/settings.json"
    "config/vscode/keybindings.json         ${HOME}/.config/Code/User/keybindings.json"
)

declare -a program_names=(
    "zsh"
    "vscode"
    "nvm"
    "postman"
    "dbeaver"
    "jq"
    "bat"
    "java"
    "maven"
    "docker"
    "python3_addons"
    "chrome"
    "intellij"
    "discord"
    "sublime-merge"
    "virtualbox"
    "vagrant"
    "mongodb"
    "tree"
    "htop"
    "netcat"
    "watch"
)

declare -a config_sources=()
declare -a config_destinations=()

for path in "${config_paths[@]}"; do
    # Split source and destination into an array based on space delimiter.
    read -a strarr <<< "$path"
    config_sources+=(${strarr[0]})
    config_destinations+=(${strarr[1]})
done

source $(dirname "$0")/programs.sh
source $(dirname "$0")/configs.sh

case "$1" in
    setup)
        sudo apt update && sudo apt upgrade -y
        install_programs program_names
        copy_configs config_sources config_destinations
        set_gnome_configs config/gnome/settings.dconf
        ;;
    clear)
        uninstall_programs
        remove_configs config_destinations
        ;;
    *)
        echo "Usage: $0 {setup | clear}"
        echo ""
        echo "$0 setup"
        echo "    Install all the programs listed in program_names array if their installations are available and copy config files."
        echo ""
        echo "$0 clear"
        echo "    Uninstall all the installed programs and remove config files."
esac
