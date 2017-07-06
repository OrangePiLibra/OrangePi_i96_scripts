#!/bin/bash
set -e

# Change File and dirent

## The absolute path of file
change_file=(
lichee/tools/pack/chips/sun50iw2p1/configs/cheetah-p1/sys_config.fex
android/hardware/libhardware_legacy/wifi/wifi.c
android/hardware/libhardware_legacy/wifi_hardware_info/wifi_hardware_info.c
android/hardware/libhardware/include/hardware/bluetooth.h
)

## The absolute path of dirent.
change_dirent=(
android/packages/apps/Bluetooth
lichee/linux-3.10/arch/arm64/boot/dts
android/device/softwinner/cheetah-p1
android/hardware/broadcom
android/device/softwinner/common/rtkbt
)

########################################
##
## Change different platform
########################################
export ROOT=`pwd`

echo "===========Platfor Option ================="
echo "0. OrangePi PC2"
echo "1. OrangePi Prime"
echo "2. OrangePi ZeroPlus2"
echo "==========================================="
read OPTION

if [ $OPTION = "0" ]; then
    PLATFORM="OrangePiH5_PC2"
elif [ $OPTION = "1" ]; then
    PLATFORM="OrangePiH5_Prime"
elif [ $OPTION = "2" ]; then
    PLATFORM="OrangePiH5_ZeroPlus2"
fi

################################################################
## Dangerous Area !! Don't edit !!
#################################################################
VERSION=$ROOT/version
# Create Version state file
if [ ! -f $VERSION ]; then
	echo "$PLATFORM" > $VERSION
fi
OLD_PLATFORM=`cat $VERSION`

if [ $PLATFORM = $OLD_PLATFORM ]; then
	exit 0
fi 

echo "$PLATFORM" > $VERSION

# Setup different version
CURRENT_VERSION=$PLATFORM
OLD_VERSION=$OLD_PLATFORM
BUFFER="$ROOT/BUFFER"
BUFFER_FILE="$BUFFER/FILE"
############# Don't edit

name=""

# Chech all source have exist!
# If not, abort exchange!
function source_check()
{
    for file in ${change_file[@]}; do
        if [ ! -f ${ROOT}/${file} ]; then
           echo "${ROOT}/${file} doesn't exist!"
           exit 0
        fi  
    done

    # Change dirent
    for dirent in ${change_dirent[@]}; do
        if [ ! -d ${ROOT}/${dirent} ]; then
            echo "${ROOT}/${dirent} doesn't exist!" 
            exit 0
        fi
    done
}

# Check argument from another scripts
function argument_check()
{
    if [ -z $CURRENT_VERSION -o -z $OLD_VERSION ]; then
        echo "Pls offer valid version!"
        exit 0
    fi
    if [ -z $ROOT ]; then
        echo "Pls offer valid root path!"
        exit
    fi

    if [ ! -d $BUFFER_FILE ]; then
        mkdir -p $BUFFER_FILE
    fi
}

# Exchange file and dirent
function change_version()
{
    # Change file
    for file in ${change_file[@]}; do
       name=${file##*/}
       cp $ROOT/$file $BUFFER_FILE/${OLD_VERSION}_${name}
       if [ ! -f ${BUFFER_FILE}/${CURRENT_VERSION}_${name} ]; then
           cp ${BUFFER_FILE}/${OLD_VERSION}_${name} ${BUFFER_FILE}/${CURRENT_VERSION}_${name}
       fi
       cp ${BUFFER_FILE}/${CURRENT_VERSION}_${name} $ROOT/$file
    done

    # Change dirent
    for dirent in ${change_dirent[@]}; do
        name=${dirent##*/}
        if [ -d ${BUFFER}/${OLD_VERSION}_${name} ]; then
            rm -rf ${BUFFER}/${OLD_VERSION}_${name}
        fi
        
        mv $ROOT/$dirent ${BUFFER}/${OLD_VERSION}_${name}
        
        if [ ! -d ${BUFFER}/${CURRENT_VERSION}_${name} ]; then
            cp -rf ${BUFFER}/${OLD_VERSION}_${name} ${BUFFER}/${CURRENT_VERSION}_${name}
        fi
        cp -rf ${BUFFER}/${CURRENT_VERSION}_${name} $ROOT/$dirent
    done
}

# To-do 
source_check
argument_check
change_version
