#!/bin/bash

################################################################################
### Constants
################################################################################

#Place path to your SD Card here (hardcoded path)
DEFAULT_PATH="/media/c1e4/NIKON D7100"

#colors for stdout
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

MOUNTED_MSG="Mounted on"
UNMOUNTED_MSG="No such file or directory"

################################################################################
### Help function (to display help message)                                      
################################################################################
display_help(){
	echo "This script will allow to safely eject SD card from integrated card reader on UNIX systems"
	echo "Please be aware that it needs to be run as root in order to properly perform unmount operation."
	echo "Usage: sdcard-eject.sh [-h|p|d]"
	echo "options:"
	echo "-h (--help) Display this help message"
	echo "-p (--path) Provide path parameter as an argument to the script"
	echo "-d (--default) Use path that is hardcoded in the beginning of the script"
	echo "if no arguments provided it will prompt you to input path to SD card"
	echo "Examples:"
	echo "1) Eject by providing path of SD card to the script:"
	echo "sudo ./sdcard-eject.sh -p \"/media/c1e4/9016-4EF8\""
	echo "2) Eject by using hardcoded path:"
	echo "sudo ./sdcard-eject.sh -d"
	echo "3) Just run this script to be prompted to input the path to SD card:"
	echo "sudo ./sdcard-eject.sh"
	echo
}

################################################################################
### Main
################################################################################

#check if script ran as root
if [ "$EUID" -ne 0 ]; then 
	echo -e "${RED}Please run as me as root${NC}"
	display_help;
	exit 1
fi

#check if args provided
#yes args
POSITIONAL_ARGS=()
if [[ $# -ne 0 ]]; then

#	echo "Args provided."

while [[ $# -gt 0 ]]; do
	case $1 in
		-h|--help)
			DISPLAY_HELP=true
			shift # past argument
			#shift # past value
			;;
		-p|--path)
			PATH_TO_SDCARD="$2"
			shift # past argument
			shift # past value
			;;
		-d|--default)
			PATH_TO_SDCARD="${DEFAULT_PATH}"
			shift # past argument
			;;
		#	--help)
			#		DISPLAY_HELP=true
			#		shift # past argument
			#		;;		
		-*|--*)
			echo "Unknown option $1"
			exit 1
			;;
		*)
			POSITIONAL_ARGS+=("$1") # save positional arg
			shift # past argument
			;;
	esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ -n $1 ]]; then
	echo "Last line of file specified as non-opt/last argument:"
	tail -1 "$1"
fi

#no args
else
	read -p 'No args provided, please enter path to your SD card: ' PATH_TO_SDCARD;

fi

#show help
if [[ ${DISPLAY_HELP} == true ]]; then
	display_help;
	exit 1;
fi


echo "Specified directory is: ${PATH_TO_SDCARD}"
#get user confirmation before proceeding
read -p 'Proceed? Y/N: ' choice
#lowercase user input
choice=$(echo "${choice}" | tr '[:upper:]' '[:lower:]')

echo "received choice: ${choice}"

#If Y or Yes, then proceed with renaming
if [ "${choice}" != "yes" ] && [ "${choice}" != "y" ]; then
	#printf "${GREEN}In progress...${NC}\n"
	#else
	printf "${RED}Abort.${NC}\n"
	exit 1;
fi

#check if SD Card path does not exist
if [[ ! -d "${PATH_TO_SDCARD}" ]]; then
	printf "${RED}Please check the correctness of path to SD Card and try again${NC}\n"
	exit 1;
fi


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
