#!/bin/bash

echo "[PROGRESS] Do you wish to set up a google drive folder using rclone (IMPORTANT: name the drive 'gdrive')?"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
	rclone config
	mkdir -p ~/Remote/gdrive
	echo "[PROGRESS] The latest drive (stored in ~/Remote/gdrive) can be accessed by running the gdrive command (alias), and will continue to update until the mounting is ended by stopgdrive."
fi

#echo "[PROGRESS] Do you wish to set up a google photos folder using rclone (IMPORTANT: name the drive 'gphotos')?"
#read input
#if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
#	rclone config
#	mkdir -p ~/Remote/gphotos
#	echo "[PROGRESS] The latest drive (stored in ~/Remote/gphotos) can be accessed by running the gphotos command (alias), and will continue to update until the mounting is ended by stopgphotos."
#fi

#echo "[PROGRESS] Do you wish to set up a(n) OneDrive folder for university using rclone (IMPORTANT: name the drive 'oduni')?"
#read input
#if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
#	rclone config
#	mkdir -p ~/Remote/oduni
#	echo "[PROGRESS] The latest drive (stored in ~/Remote/oduni) can be accessed by running the oduni command (alias), and will continue to update until the mounting is ended by stopoduni."
#fi

echo "[PROGRESS] Do you wish to set up a(n) OneDrive folder for a google account using rclone (IMPORTANT: name the drive 'odgoogle')?"
read input
if [[ "$input" == "Y" || "$input" == "y" || -z "$input" ]]; then
	rclone config
	mkdir -p ~/Remote/odgoogle
	echo "[PROGRESS] The latest drive (stored in ~/Remote/odgoogle) can be accessed by running the odgoogle command (alias), and will continue to update until the mounting is ended by stopodgoogle."
fi



