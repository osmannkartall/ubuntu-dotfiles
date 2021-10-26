#!/bin/bash

copy_configs() {
    local -n sources=$1
    local -n destinations=$2
    local len=${#sources[@]}

    for (( i=0; i<$len; i++ )); do
        cp ${sources[i]} ${destinations[i]}
    done

    echo "Copying of config files is finished."
}

set_gnome_configs() {
    source=$1

    dconf load /org/gnome/ < $source
}

remove_configs() {
    local -n destinations=$1

    for path in "${destinations[@]}"; do
        rm $path
    done

    echo "Removing of config files is finished."
}