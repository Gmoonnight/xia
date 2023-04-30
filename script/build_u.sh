#!/bin/zsh

# usage: zsh build_u.sh [device path of your u disk] [wether need to be format]
# ex: "zsh build_u.sh" is equal to "zsh build_u.sh /dev/disk2 false"

# Building startup u disk base on BIOS - MACOS
if [ "$1" = "" ]; then
	device_path="/dev/disk2"
else
	device_path="$1"
fi

# true - format your u disk, false - unformat your u disk
if [ "$2" = "true" ]; then
	diskutil eraseDisk FAT32 UNTITLED MBR "$device_path"
	diskutil unmountDisk "$device_path"
fi

nasm -f bin -o ../tmp/boot_sector.bin -i ../ ../boot_sector.asm
diskutil unmountDisk ${device_path}
sudo dd if=../tmp/boot_sector.bin of="$device_path" bs=512b count=1 seek=0
rm -rf ../tmp/boot_sector.bin

echo "Build Successful!"