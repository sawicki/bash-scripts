#!/bin/bash

# Script to backup an SDHC card to a USB SSD drive

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Define the device path for the SDHC card
SDHC_DEVICE="/dev/mmcblk0"     # SDHC card device

# Use the existing mount point for the SSD
MOUNT_POINT="/media/pi/Extreme SSD"

# Get the hostname of the Raspberry Pi
HOSTNAME=$(hostname)

# Define the backup file path with the hostname
BACKUP_FILE="${MOUNT_POINT}/${HOSTNAME}-backup.img"

# Check if the SDHC card is present
if [ ! -b $SDHC_DEVICE ]; then
    echo "SDHC card not found at $SDHC_DEVICE. Please check the device path."
    exit 1
fi

# Create a backup
echo "Starting backup of SDHC card to $BACKUP_FILE..."
if ! sudo dd if=$SDHC_DEVICE of="$BACKUP_FILE" bs=4M status=progress; then
    echo "Backup failed."
    exit 1
fi

echo "Backup completed successfully."
echo "Script completed. Backup created."
