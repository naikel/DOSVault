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
    
    if [ -f "${lib_dir}/version.sh" ]; then
        source "${lib_dir}/version.sh"
    else
        dosvault_version="unknown"
    fi
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

rebuild_installed_xml() {
    printf "collection: Installed\nfile: ${lib_dir}/adminTool\n" >${installed_xml_file}
    for d in $(find ${exodos_dir} -maxdepth 1 -mindepth 1 -type d | grep -Ev '/!dos$')
    do
        printf "file: %s/!dos/%s/dosbox.conf\n" ${exodos_dir} $(basename $d) >>${installed_xml_file}
    done        
}

convert_xml_to_pegasus() {
    printf "\n\n\033[2A"
    printf "Converting ${Cyan}LaunchBox XML file${Color_Off} to ${Green}Pegasus Metadata format${Color_Off}... "
    $lib_dir/xml2pegasus "${dosvault_dir}/eXoDOS/xml/all/MS-DOS.xml" "${dosvault_dir}" "${lib_dir}/launch.sh" >$xml_file
    sed "s@admin.sh@${lib_dir}/adminTool@" ${res_dir}/admin.txt | sed "s/@VERSION@/${dosvault_version}/" >>${xml_file}
    printf "asset.box_front: /app/grid/%s_p.png\nfile: %s/adminTool\n" ${FLATPAK_ID} ${lib_dir} >>${xml_file}

    rebuild_installed_xml
    printf "\n${Green}Pegasus Metadata file created successfully!${Color_Off}\n"
}

check_if_last_version() {
    if [ -f "${xml_file}" ]; then
        if [ ! -f "${dosvault_dir}/VERSION" ]; then
            touch "${dosvault_dir}/VERSION"
        fi

        last_version=$(cat "${dosvault_dir}/VERSION")
        printf "Installed DOSVault version: %s\n" ${last_version} >/dev/stderr
        if [ "${last_version}" != "${dosvault_version}" ]; then
            printf "An upgrade is needed\n" >/dev/stderr
            echo 1
            return
        fi
    fi
    echo 0
}

upgrade_version() {
    if [ -f "${xml_file}" ]; then
        if [ ! -f "${dosvault_dir}/VERSION" ]; then
            touch "${dosvault_dir}/VERSION"
        fi

        local last_version=$(cat "${dosvault_dir}/VERSION")
        if [ "${last_version}" != "${dosvault_version}" ]; then
        
            # Upgrade needed
            convert_xml_to_pegasus
        
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

