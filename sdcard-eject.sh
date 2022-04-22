#!/bin/bash

#Place path to your SD Card here
PATH_TO_SDCARD="/media/c1e4/NIKON D7100"

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

MOUNTED_MSG="Mounted on"
UNMOUNTED_MSG="No such file or directory"

#function that checks whether a substring is in string 
#returns 1 if yes, 1 if no
check_substring_occurence(){
	SUBSTRING=$1
	STRING=$2
	if echo "$STRING" | grep -q "$SUBSTRING"; then
		echo "1";
	else
		echo "0";
	fi
}

#-----------------------------------------------------------------------
#Checks if SD card is mounted at the moment
echo "Check if device is mounted..."
OUTPUT=$( { df "$PATH_TO_SDCARD"; } 2>&1 )
IS_MOUNTED=$(check_substring_occurence "$MOUNTED_MSG" "$OUTPUT")

if [ "$IS_MOUNTED" = "1" ]; then
	#echo "The SD Reader is mounted at the moment"
	printf "${ORANGE}The SD Reader is mounted at the moment${NC}\n"
else
	printf "${GREEN}The SD Reader is already unmounted, exit${NC}\n"
	exit 1
fi

#check if script ran as root
if [ "$EUID" -ne 0 ]; then 
	echo -e "${RED}Please run as me as root${NC}"
	exit 1
fi

#-----------------------------------------------------------------------
#Sync (flush) all pending data to drives in order to prevent corruption
echo "Syncing to force-write all pending data..."
sync &

#wait till sync finishes
wait %1
echo "Sync complete"

#-----------------------------------------------------------------------
#Unmount the device
echo "Unmounting..."
sudo umount "$PATH_TO_SDCARD"

#-----------------------------------------------------------------------
#Check for results
echo "Checking the results..."
OUTPUT=$( { df "$PATH_TO_SDCARD"; } 2>&1 )
IS_MOUNTED=$(check_substring_occurence "$UNMOUNTE_MSG" "$OUTPUT")

if [ "$IS_MOUNTED" = "1" ]; then
	echo "The SD Reader is unmounted"
	printf "${GREEN}Success!${NC}\n"

else
	echo "The SD Reader is still mounted at the moment "
	printf "${RED}Fail, try again${NC}\n"
fi
