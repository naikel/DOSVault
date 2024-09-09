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

source ${lib_dir}/global.sh

############################################ END-INIT

title_screen

last_version=$(cat "${dosvault_dir}/VERSION")
printf "Upgrading from version ${last_version} to version ${dosvault_version}...\n\n"
    
upgrade_version

# Check if there's a gamepad present
if [ -n "$steam_deck" ]; then
    key_option="-p"
    key_string="button"
else
    gamepads=$($base_dir/bin/getpadbuttonSDL2 -n | awk '{print $3}')
    gamepads=${gamepads//[$'\t\r\n ']}
    if [ -n "${gamepads}" -a "${gamepads}" -lt 1 ]; then
        key_option="-k"
        key_string="key"
    else
        key_option=
        key_string="key or button"
    fi
fi

str="\nPress any $key_string to continue\n"
k=$($base_dir/bin/getpadbuttonSDL2 $key_option -t "$(printf "$str")" | awk '{print $2}')
