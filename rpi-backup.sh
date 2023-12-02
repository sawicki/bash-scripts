#!/bin/bash

# This script creates a backup image of the Raspberry Pi's SD card.
# Create a mountpoint for the network share called WindowsShare
# in the home directory of the user running the script.

# Create a directory called scripts in the user's home directory and put this script in it.
# chmod +x rpi-backup.sh to make the script executable.

# This script requires the following environment variables to be set:
# SMB_USERNAME - username for the network share
# SMB_PASSWORD - password for the network share
# These can be set in a .env file in the same directory as the script or in the environment.

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi


# Change to the user's home directory
cd ~

# Load environment variables from .env file
source /home/pi/scripts/.env   # comment out if not using .env file

# Get the hostname of the machine
hostname=$(hostname)

# Define the backup filename
filename="${hostname}-backup.img"

# Define WindowsShare directory path
windowsShareDir=~/WindowsShare

# Define the network share path
networkSharePath="//OFFICE-DESKTOP/RPI-Share"

# Create WindowsShare directory if it doesn't exist
mkdir -p "$windowsShareDir"

# Function to check if a directory is a mountpoint
is_mountpoint() {
    findmnt -rno SOURCE,TARGET "$1" >/dev/null
}

# Read username and password from environment variables
smbUsername="${SMB_USERNAME}"
smbPassword="${SMB_PASSWORD}"

# Check if WindowsShare is already mounted
if ! is_mountpoint "$windowsShareDir"; then
    # Mount the network share if not mounted
    sudo mount -t cifs -o username="$smbUsername",password="$smbPassword" "$networkSharePath" "$windowsShareDir"
    
    # Check if the mount was successful
    if [ $? -ne 0 ]; then
        echo "Mount failed. Aborting."
        exit 1
    else
        echo "Successfully mounted $networkSharePath to $windowsShareDir."
    fi
fi



# Full path for the backup file
backupFilePath="$windowsShareDir/$filename"

# Check if the file already exists
if [ -f "$backupFilePath" ]; then
    read -p "File $backupFilePath already exists. Overwrite? (y/N): " confirm
    if [[ $confirm != [yY] ]]; then
        echo "Operation aborted."
        exit 1
    fi
fi

# Run dd with real-time progress
sudo dd bs=4M if=/dev/mmcblk0 of="$backupFilePath" status=progress

# Check if the dd operation was successful
if [ $? -eq 0 ]; then
    echo "dd operation completed successfully."
    
    # Unmount the WindowsShare directory
    echo "Unmounting the WindowsShare directory..."
    sudo umount ~/WindowsShare
    
    if [ $? -eq 0 ]; then
        echo "Successfully unmounted WindowsShare."
    else
        echo "Failed to unmount WindowsShare. It may be in use."
    fi
else
    echo "dd operation failed."
fi

