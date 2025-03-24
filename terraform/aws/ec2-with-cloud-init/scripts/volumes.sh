#!/bin/bash

# Exit on error and print each command before execution
set -ex  

# Activate all volume groups
vgchange -ay

# Get filesystem type of the device (empty if not formatted)
DEVICE_FS=`blkid -o value -s TYPE ${DEVICE} || echo ""`

if [ "`echo -n $DEVICE_FS`" == "" ] ; then 
  # Wait for the device to be attached and detected by the system
  DEVICENAME=`echo "${DEVICE}" | awk -F '/' '{print $3}'`
  DEVICEEXISTS=''
  while [[ -z $DEVICEEXISTS ]]; do
    echo "checking $DEVICENAME"
    DEVICEEXISTS=`lsblk |grep "$DEVICENAME" |wc -l`
    if [[ $DEVICEEXISTS != "1" ]]; then
      sleep 15  # Wait and retry until the device shows up
    fi
  done

  # Wait until the device file actually exists in /dev/
  count=0
  until [[ -e ${DEVICE} || "$count" == "60" ]]; do
   sleep 5
   count=$(expr $count + 1)
  done

  # Create physical volume, volume group, logical volume, and format it
  pvcreate ${DEVICE}
  vgcreate data ${DEVICE}
  lvcreate --name volume1 -l 100%FREE data
  mkfs.ext4 /dev/data/volume1
fi

# Mount the logical volume to /data and persist in /etc/fstab
mkdir -p /data
echo '/dev/data/volume1 /data ext4 defaults 0 0' >> /etc/fstab
mount /data
