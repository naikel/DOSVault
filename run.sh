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

printf "DOSVault version %s\n" ${dosvault_version}

# Check if DOSVault is installed properly
if [ ! -f $xml_file ]; then
    # Install DOSVault
    LC_ALL=en_US.UTF-8 uxterm $xterm_mode -e /bin/bash $lib_dir/install.sh
    
    # Reload settings
    source ${lib_dir}/global.sh
fi

# If it was installed correctly in the previous step, let's run pegasus
if [ -f $xml_file ]; then
    if [ $(check_if_last_version) -eq 1 ]; then
        LC_ALL=en_US.UTF-8 uxterm $xterm_mode -e /bin/bash $lib_dir/upgrade.sh
    fi
    LC_ALL=en_US.UTF-8 pegasus-fe
fi

