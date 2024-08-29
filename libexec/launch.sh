#!/bin/bash

LD_PRELOAD=
export LD_PRELOAD

############################################ BEGIN-INIT

# Get the base dir
if [ -n "${FLATPAK_ID}" ]; then
    # We are inside a flatpak
    base_dir=/app
else
    base_dir=${PWD}
fi

lib_dir=$base_dir/libexec
res_dir=$base_dir/resources

source $lib_dir/global.sh

############################################ END-INIT

# Check if the user selected the administration tool

if [ "$(basename "$1")" = "admin.sh" ]; then
    $1
    exit 0
fi

# Check if the game is installed

dosbox_conf="$1"
game_metadata_dir=$(dirname "${dosbox_conf}")
game_install_dir="${exodos_dir}/$(basename "${game_metadata_dir}")"
game_name=$(ls ${game_metadata_dir}/*.bat | grep -Ev "(install|exception)\.bat")

if [ ! -d "${game_install_dir}" ]; then

    base_name=$(basename "${game_name}" | sed "s/\.bat$/.zip/")
    real_name="$(echo "${base_name}" | sed "s/.zip$//")"

    echo ${real_name} is not installed
    LC_ALL=en_US.UTF-8 uxterm $xterm_mode -geom 85x26 -fg gray -bg black -fa 'DejaVu Sans Mono' -fs 19 -e /bin/bash $lib_dir/install_game.sh "${base_name}" "$1"
fi

# Launch the game if it's installed

if [ -d "${game_install_dir}" ]; then

    echo Launching ${game_name}
    mapper="${game_metadata_dir}/mapper.map"
    if [ ! -f "${mapper}" ]; then 
	    cp "${res_dir}/mapper-dosbox-x.map" ${mapper}
    fi
    
    if [ ! -f "${dosbox_conf}.DOSVault" ]; then
        sed 's@\\@/@g' "${dosbox_conf}" > "${dosbox_conf}.DOSVault"
    fi
    
    if [ "${steam_deck}" = "true" -a "${XDG_CURRENT_DESKTOP}" = "gamescope" ]; then
        dosbox_options='-set "sdl windowresolution=1280x800" -set "sdl showmenu=false"'
    else
        dosbox_options="-fullscreen"
    fi
    
    dosbox-x -conf ${dosbox_conf}.DOSVault -defaultdir "${exo_dir}" -exit -set saveremark=false -set captures="${game_install_dir}/save" ${dosbox_options}
fi

