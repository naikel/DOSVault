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

print_available() {
    local free=$(($(disk_available $1)*1024))
    if [ $free -gt 12884901888 ]; then
        free_c=$Green
    else
        free_c=$Red
    fi
    printf "Your $2 has${free_c} $(bytes_to_human $free)${Color_Off} free\n"
}

choose_install_dir() {
    if [[ -z "$dosvault_dir" ]] || [[ ! -d "$dosvault_dir" ]]; then
        needed=12582912
        printf "You need at least 12 GB free to install DOSVault in your system\n"
        #steam_deck=1
        if [ -n "$steam_deck" ]; then
            # This is a Steam Deck!
            print_available $HOME "Internal Drive"
            if [ -n "$sdcard" ]; then
                print_available $sdcard "MicroSD Card"
            fi
            printf "\n"
            str=
            if [[ $(disk_available $HOME) -gt $needed ]]; then
                str="${str}Press the $Y_Button to install DOSVault in the Internal Storage\r\n"
                can_install_home=true
            fi
            if [[ -n "$sdcard" && $(disk_available $sdcard) -gt $needed ]]; then
                str="${str}Press the $A_Button to install DOSVault in the MicroSD Card\r\n"
                can_install_sd=true
            fi
            
            if [[ "$can_install_home" = "false" && "$can_install_sd" = "false" ]]; then
                str="${str}${Red}You have no available space left! Free some space!${Color_Off}\r\n\n"
                str="${str}Press any $key_string to exit\r\n"
            else
                str="${str}Press the $B_Button to cancel\r\n"
            fi
            key=
            while [ "$key" != "y" -a "$key" != "a" -a "$key" != "b" ]; do
                key=$($base_dir/bin/getpadbuttonSDL2 $key_option -t "$(printf "$str")" | awk '{print $2}')
                key=${key//[$'\t\r\n ']}
                if [ "$key" = "y" -a "$can_install_home" = "true" ]; then
                    install_dir=$HOME
                elif [ "$key" = "a" -a "$can_install_sd" = "true" ]; then
                    install_dir=$sdcard
                elif [ "$key" != "b" ]; then
                    key=
                fi
            done
        else
            # This is a Linux box
            
            success=
            while [ -z "$success" ]; do
                str="\nPress any $key_string to choose a folder in which to install DOSVault\n"
                k=$($base_dir/bin/getpadbuttonSDL2 $key_option -t "$(printf "$str")" | awk '{print $2}')

                install_dir=$(zenity --title "Choose a folder in which to install DOSVault" --filename=$HOME/DOSVault --file-selection --directory 2>/dev/null)
                if [ -n "$install_dir" ]; then
                    free=$(disk_available $install_dir)
                    print_available $install_dir "$install_dir folder"
                    if [[ ${free} -lt 10485760 ]]; then
                        printf "There's not enough free space in $install_dir to install DOSVault\nChoose another location\n"
                    else
                        success=1
                    fi
                else
                    success=1
                fi
            done
        fi
        
        if [ -z "$install_dir" ]; then
            printf "\nCancelling..."
            sleep 2
            exit 1
        fi
        
        save_setting install_dir $install_dir
        mkdir -p $dosvault_dir
    fi

    printf "\nDOSVault is going to be installed in ${LGreen}$dosvault_dir${Color_Off}\n\n"
}

get_torrent_file() {
    local torrent_file="${dosvault_dir}/eXoDOS.torrent"

    if [ ! -f $torrent_file ]; then
        printf "Getting .torrent file...\n"
        magnet=$(cat $res_dir/source.txt | base64 -d)
        tmp_file=${dosvault_dir}/$(echo $magnet | grep -o "btih:[^&]*" | awk -F: '{print $2}' | tr '[:upper:]' '[:lower:]').torrent
        
        aria2c --bt-metadata-only --bt-save-metadata --dir=$dosvault_dir "$magnet"
        if [ -f $tmp_file ]; then
            mv ${tmp_file} $torrent_file 
            printf "${Green}Torrent file downloaded successfully!${Color_Off}\n"
        else
            printf "${Red}Couldn't download the DOSVault torrent file. Check your Internet connection.${Color_Off}\n"
            str="\nPress any $key_string to exit\n"
            k=$($base_dir/bin/getpadbuttonSDL2 $key_option -t "$(printf "$str")" | awk '{print $2}')
            exit 1
        fi
    else
        printf "${LBlue}Torrent file${Color_Off} was already downloaded!\n"
    fi
}

download_metadata() {
    local torrent_file="${dosvault_dir}/eXoDOS.torrent"
    local files=("eXoDOS/Content/!DOSmetadata.zip" "eXoDOS/Content/XODOSMetadata.zip" "eXoDOS/eXo/util/util.zip")
    local indexes=""
    local present=true
    
    for i in ${files[*]} ; do
        if [ ! -f "${dosvault_dir}/$i" ]; then
            printf "${dosvault_dir}/$i metadata file was not found\n"
            present=
        fi
        indexes="${indexes}$(aria2c --show-files $torrent_file | grep $i | awk -F\| '{print $1}' | tr -d "[:space:]") "
    done
    
    if [ -z "$present" ]; then
        printf "Downloading metadata...\n"
        indexes=$(echo $indexes | sed 's/ $//' | tr " " ",")
        aria2c --select-file=$indexes --bt-remove-unselected-file=true --file-allocation=none --allow-overwrite=true --seed-time=0 --dir=$dosvault_dir $torrent_file 
        rm -f "${dosvault_dir}/eXoDOS.aria2"
        printf "${Green}Metadata downloaded successfully!${Color_Off}\n"
    else
        printf "${LBlue}Metadata${Color_Off} was already downloaded!\n"
    fi
    
    # Unzip content
    if [ ! -d "${dosvault_dir}/eXoDOS/eXo/eXoDOS/!dos" ]; then
        printf "Decompressing configuration data...\n"
        unzip -o "${dosvault_dir}/${files[0]}" -d "${dosvault_dir}/eXoDOS"
    fi
    
    if [ ! -d "${dosvault_dir}/eXoDOS/Images" ]; then
        printf "Decompressing images...\n"
        unzip -o "${dosvault_dir}/${files[1]}" -d "${dosvault_dir}/eXoDOS"
    fi
    
    if [ ! -d "${dosvault_dir}/eXoDOS/eXo/mt32" ]; then
        printf "Decompressing MT32 roms...\n"
        unzip -o ${dosvault_dir}/${files[2]} EXTDOS.zip -d "${dosvault_dir}/eXoDOS/Content"
        unzip "${dosvault_dir}/eXoDOS/Content/EXTDOS.zip" mt32/* -d "${dosvault_dir}/eXoDOS/eXo"
    fi
}

convert_xml_to_pegasus() {
    if [ ! -f "$xml_file" ]; then
        clear
        printf "Converting ${Cyan}LaunchBox XML file${Color_Off} to ${Green}Pegasus Metadata format${Color_Off}... "
        $lib_dir/xml2pegasus "${dosvault_dir}/eXoDOS/xml/all/MS-DOS.xml" "${dosvault_dir}" "${lib_dir}/launch.sh" >$xml_file
        head -2 $xml_file | sed s/DOS/Installed/ >${installed_xml_file}
        printf "file: ${lib_dir}/admin.sh\n" >>${installed_xml_file}
        sed "s@admin.sh@${lib_dir}/admin.sh@" ${res_dir}/admin.txt | sed "s/@VERSION@/${dosvault_version}/" >>${xml_file}
        printf "asset.box_front: /app/grid/${FLATPAK_ID}_p.png\n" >>${xml_file}
        printf "\n${Green}Pegasus Metadata file created successfully!${Color_Off}\n"
        pegasus_dir="$HOME/.var/app/${FLATPAK_ID}/config/pegasus-frontend"
        mkdir -p ${pegasus_dir}
        echo "${dosvault_dir}/eXoDOS" > ${pegasus_dir}/game_dirs.txt
    fi
}

copy_resources() {

    if [ ! -f "${dosvault_dir}/mapper-dosbox-x.map" ]; then
        cp "${res_dir}/mapper-dosbox-x.map" "${dosvault_dir}/mapper-dosbox-x.map"
    fi
}

install_DOSVault() {
    title_screen
    
    local can_install_home=false
    local can_install_sd=false
    install_dir=
    
    printf "$LRed"
    center_text "Welcome to DOSVault"
    printf "$Color_Off"
    center_text "An eXoDOS installation for Steam Deck and Linux"
    printf "\n\n" 
    
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

    choose_install_dir
    
    get_torrent_file
    
    download_metadata
    
    copy_resources
    
    convert_xml_to_pegasus
    
    upgrade_version

}

install_DOSVault
sleep 5

