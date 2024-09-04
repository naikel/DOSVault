#!/bin/bash

# Load all modules
source $lib_dir/format.sh

config_dir="$HOME/.var/app/${FLATPAK_ID}/config/DOSVault"
config_file="$config_dir/DOSVault.conf"

# Function to convert bytes to human-readable format
bytes_to_human() {
    local bytes="$1"
    local units=("B" "KB" "MB" "GB" "TB" "PB" "EB" "ZB" "YB")
    local unit_index=0

    # Loop until the bytes are less than 1024 or we run out of units
    while ((bytes >= 1024)) && ((unit_index < ${#units[@]} - 1)); do
        bytes=$((bytes / 1024))
        unit_index=$((unit_index + 1))
    done

    echo "$bytes ${units[unit_index]}"
}

disk_available() {
    df $1 | tail -1 | awk '{print $4}'
}

read_config() {
    if [ ! -f "${config_file}" ]; then
        mkdir -p "${config_dir}"
        touch "${config_file}"
    else
        source "${config_file}"
    fi
    dosvault_dir="${install_dir}/DOSVault"
    exodos_dir="${dosvault_dir}/eXoDOS/eXo/eXoDOS"
    exo_dir="${dosvault_dir}/eXoDOS/eXo"
    xml_file="${dosvault_dir}/eXoDOS/DOS.metadata.pegasus.txt"
    installed_xml_file="${dosvault_dir}/eXoDOS/Installed.metadata.pegasus.txt"
}

save_setting() {
    local setting="$1=$2"
    grep ^$1 "${config_file}" >/dev/null
    if [ $? -eq 0 ]; then
        sed -i s@^$1.*@${setting}@ $config_file
    else
        echo $setting >>$config_file
    fi
    read_config
}

title_screen() {
    printf "$LBlue"
    while IFS= read -r line; do
        center_text "${line}"
    done < $res_dir/title.txt
    printf "$Color_Off"
}

update_grid() {
    for user_id in "$(ls ${userdata_dir})"
    do
        local config_dir="${userdata_dir}/${user_id}/config"
        local grid_dir="${config_dir}/grid"
        local app_id=$(${lib_dir}/getsteamappid "${FLATPAK_ID}" "${config_dir}/shortcuts.vdf")
        if [ $? -eq 0 ]; then
            if [ ! -f "${grid_dir}/${app_id}.png" ]; then
                cp "${base_dir}/grid/${FLATPAK_ID}_hero.png" "${grid_dir}/${app_id}.png"
            fi
            if [ ! -f "${grid_dir}/${app_id}_hero.png" ]; then
                cp "${base_dir}/grid/${FLATPAK_ID}_hero.png" "${grid_dir}/${app_id}_hero.png"
            fi
            if [ ! -f "${grid_dir}/${app_id}_logo.png" ]; then
                cp "${base_dir}/grid/${FLATPAK_ID}_logo.png" "${grid_dir}/${app_id}_logo.png"
            fi
            if [ ! -f "${grid_dir}/${app_id}_p.png" ]; then
                cp "${base_dir}/grid/${FLATPAK_ID}_p.png" "${grid_dir}/${app_id}p.png"
            fi
        fi
    done
}

upgrade_version() {
    if [ -f "${xml_file}" ]; then
        if [ ! -f "${dosvault_dir}/VERSION" ]; then
            touch "${dosvault_dir}/VERSION"
        fi

        last_version=$(cat "${dosvault_dir}/VERSION")
        if [ "{$last_version}" != "${dosvault_version}" ]; then
            sed -i "s/game: DOSVault Configuration Tool.*/game: DOSVault Configuration Tool v${dosvault_version}/" ${xml_file}
            echo "${dosvault_version}" >"${dosvault_dir}/VERSION"
        fi
    fi
}

# steam_deck: true if this is a Steam Deck
if [[ -f "/sys/devices/virtual/dmi/id/product_name" &&  $(cat /sys/devices/virtual/dmi/id/product_name) =~ ^(Jupiter|Galileo)$ ]]; then
    steam_deck=true
    userdata_dir="$HOME/.local/share/Steam/userdata"
    xterm_mode="-fullscreen"
    if [[ -d "/run/media/mmcblk0p1/" ]]; then
        sdcard="/run/media/mmcblk0p1" 
    fi
    update_grid
else
    steam_deck=
    userdata_dir=
    sdcard=
    xterm_mode=
fi
xterm_mode="${xterm_mode} -geom 85x26 -fg gray -bg black -fa DejaVuSansMono -fs 19"

read_config

if [ -f "${lib_dir}/version.sh" ]; then
    source "${lib_dir}/version.sh"
else
    dosvault_version="unknown"
fi
