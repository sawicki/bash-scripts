#!/bin/bash

# Get the file system disk space usage for the root partition
df_output=$(df -h / | awk 'NR==2')

# Extract total size, used space, and available space
TOTAL_SIZE=$(echo $df_output | awk '{print $2}')
USED_SPACE=$(echo $df_output | awk '{print $3}')
AVAILABLE_SPACE=$(echo $df_output | awk '{print $4}')
USED_PERCENTAGE=$(echo $df_output | awk '{print $5}')

# Output the results
echo "####################################################"
echo ""
echo "Note that the  total size is the size of the partition the RPI is using"
echo "Compare that to the physical size of the card to see if the partition should be expanded"
echo ""
echo "Total size of SDHC card partition: $TOTAL_SIZE"
echo "Used space: $USED_SPACE"
echo "Available space: $AVAILABLE_SPACE"
echo "Percentage of SDHC card partition used: $USED_PERCENTAGE"
echo "####################################################"
echo ""
