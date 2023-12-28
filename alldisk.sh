#!/bin/bash

# Display total size of the SD card
echo "Checking total size of the SD card..."
total_size=$(sudo fdisk -l | grep "Disk /dev/mmcblk0:" | awk '{print $5}')
echo "Total size of SD card: $total_size bytes"

# Display size of the partitions
echo "Checking size of the partitions..."
partition_sizes=$(sudo fdisk -l /dev/mmcblk0 | grep "/dev/mmcblk0" | awk '{print $5}')
total_partition_size=0

for size in $partition_sizes; do
    # Convert the size to bytes before adding it to the total
    size_in_bytes=$(numfmt --from=iec $size)
    total_partition_size=$(($total_partition_size + $size_in_bytes))
done

echo "Total size of partitions: $total_partition_size bytes"

# Compare total size with partition sizes
if [ $total_partition_size -lt $total_size ]; then
    echo "Not all of the SD card's space is being used."
    echo "You might consider expanding the filesystem."
else
    echo "The SD card's space is fully utilized."
fi

# End of script