#!/bin/bash

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

torrent_file="$dosvault_dir/eXoDOS.torrent"

# Check if there's a gamepad present
if [ -n "$steam_deck" ]; then
    key_option="-p"
    key_install="the ${A_Button}"
    key_cancel="the ${B_Button}"
else
    gamepads=$($base_dir/bin/getpadbuttonSDL2 -n | awk '{print $3}')
    gamepads=${gamepads//[$'\t\r\n ']}
    if [ -n "${gamepads}" -a "${gamepads}" -lt 1 ]; then
        key_option="-k"
        key_install="${Green}Y${Color_Off}"
        key_cancel="any other key"
    else
        key_option=
        key_install="${Green}Y${Color_Off} on the keyboard or the ${A_Button} on the gamepad"
        key_cancel="any other key on the keyboard or the ${B_Button}"
    fi
fi

title_screen

game_name="$(echo "$1" | sed "s/.zip$//")"
base_name="$1"
printf "${LRed}${game_name}${Color_Off}\n\n"
printf "It appears you have not downloaded this game yet.\n"
file=$(aria2c --show-files "${torrent_file}" | grep -A1 "eXoDOS/eXo/eXoDOS/${base_name}")
index=$(echo $file | awk -F\| '{ print $1 }')
size=$(echo $file | awk -F\| '{ print $3 }')
printf "Download size is ${Green}$size${Color_Off}\n\n"

str="Press ${key_install} to download this game\r\nPress ${key_cancel} to cancel"
k=$($base_dir/bin/getpadbuttonSDL2 $key_option -t "$(printf "$str")" | tr '[:upper:]' '[:lower:]' | tr -d "[:space:]")

if [ "$k" = "key:y" -o "$k" = "button:a" ]; then
    printf "\nDownloading ${LRed}${game_name}${Color_Off}...\n"
    aria2c --select-file=$index --bt-remove-unselected-file=true --file-allocation=none --allow-overwrite=true --seed-time=0 --dir=$dosvault_dir $torrent_file
    rm -f "${dosvault_dir}/eXoDOS.aria2"

    if [ -f "${exodos_dir}/${base_name}" ]; then
        unzip -o "${exodos_dir}/${base_name}" -d "${exodos_dir}"
        echo "file: $2" >> ${installed_xml_file}
    fi
else
    printf "\nCancelling..."
    sleep 2
fi

