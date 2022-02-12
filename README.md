# sdcard-eject
Allows to safely eject SD card from integrated  card reader on UNIX systems

Problem:
If you have a laptop or any other device with integrated SD card reader and UNIX system on board, then you probably have encountered the issue with impossibility to eject SD card after you finished working.

"Error ejecting /dev/mmcblk0: Command line eject eject '/dev/-mmcblk0' - if this issue seems familiar, then the script is for you.

How it works:
1) Checks if SD card still is still mounted on the system
2) Performs flushing all pending data
3) Unmounts the device
4) Checks if SD card is unmounted successfully

Installation: 
1. Clone entire repository or download only the script (sdcard-eject.sh). 
2. Place it in the path directory (~/bin, /usr/bin, etc) to your liking.
3. Edit the script and change path to yours (variable PATH_TO_SDCARD)
4. Add alias/keyboard shortcut
5. To safely eject the SD card, run the script
