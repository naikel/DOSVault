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

get_game_list() {
    local dirs=$(find ${exodos_dir} -maxdepth 1 -mindepth 1 -type d | grep -Ev '/!dos$' | sort)
    local list=
    if [ -n "$dirs" ]; then
        for dir in $dirs
        do  
            local name="$(find $dir -name \*exo -exec basename '{}' \; | sed s/.exo$//)"
            if [ -n "$name" ]; then
                entry=$(printf "%s\n%s\n" "${dir}" "${name}")
                if [ -z "${list}" ]; then
                    list="${entry}"
                else
                    list=$(printf "%s\n%s\n" "${list}" "${entry}")
                fi
            fi
        done
        game=$(printf "$list\n" \
            | zenity --list --title="DOSVault Administration Tool" --text "Select an installed game" --column="option" --column="description" --hide-header --hide-column=1 ${z_options} | sed 's/ //g')
    else
        game=
        zenity --warning --title DOSVault --text "You haven't installed a game yet"
    fi
}

GTK_THEME=Adwaita:dark
if [ "${steam_deck}" = "true" -a "${XDG_CURRENT_DESKTOP}" = "gamescope" ]; then
    GDK_DPI_SCALE=3.5
    z_options="--width=1280 --height=800"
else
    z_options="--width=640 --height=480"
fi
export GTK_THEME GDK_DPI_SCALE GDK_SCALE

option=
while [ "${option}" != "5" ] 
do
    option=$(printf "1\nReset all mappings\n\
    2\nReset mapping of a game\n\
    3\nUninstall a game\n\
    4\nUninstall eXoDOS\n\
    5\nExit\n\
    " | zenity --list --title="DOSVault Administration Tool" --text "Select one option below" --column="option" --column="description" --hide-header --hide-column=1 ${z_options} | sed 's/ //g')

    case "${option}" in
        "1") 
            zenity --question --title DOSVault --text "Are you sure you want to reset ALL game mappings?"
            if [ $? -eq 0 ]; then
                find "${exodos_dir}/!dos" -name mapper.map -exec rm -f '{}' \;
                zenity --warning --title DOSVault --icon=info --text "All game mappings have been reset"
            fi
            ;;
        "2")
            get_game_list
            if [ -n "${game}" ]; then             
                name="$(find $game -name \*exo -exec basename '{}' \; | sed s/.exo$//)"
                zenity --question --title DOSVault --text "Are you sure you want to reset the mapping for ${name}?"
                if [ $? -eq 0 ]; then
                    rm -f "${exodos_dir}/!dos/$(basename $game)/mapper.map"
                    zenity --warning --title DOSVault --icon=info --text "The mapping has been reset"
                fi
            fi
            ;;
        "3")
            get_game_list
            if [ -n "${game}" ]; then 
                name="$(find $game -name \*exo -exec basename '{}' \; | sed s/.exo$//)"
                zenity --question --title DOSVault --text "Are you sure you want to uninstall ${name}?"
                if [ $? -eq 0 ]; then
                    conf="\/$(basename $game)\/dosbox.conf"
                    sed -i "/${conf}/d" "${installed_xml_file}"
                    rm -fr "${game}"
                    zenity --warning --title DOSVault --icon=info --text "${name} has been uninstalled"
                fi
            fi
            ;;            
        *)
            exit 0
            ;;
    esac
done
