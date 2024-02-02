boot/boot_sector: tools/print_string.asm boot/boot_sector.asm
	nasm -f bin boot/boot_sector.asm -o boot/boot_sector
	echo 'Build boot/boot_sector...OK'

boot/setup: tools/print_string.asm boot/setup.asm
	nasm -f bin boot/setup.asm -o boot/setup
	echo 'Build boot/setup...OK'

tools/build:
	clang -std=c17 tools/build.c -o tools/build
	echo 'Build tools/build...OK'

os: boot/boot_sector boot/setup tools/build
	tools/build
	echo 'Build os by tools/build...OK'
	echo 'Success!'

erase_disk:
	diskutil eraseDisk FAT32 UNTITLED MBR /dev/disk2
	diskutil unmountDisk /dev/disk2
	echo 'Erase disk to FAT32...OK'
	echo 'Success!'

disk: os
	sudo dd if=os of=/dev/disk2 bs=512 seek=0
	echo 'Build disk...OK'
	echo 'Success!'

clean: 
	rm -rf boot/boot_sector boot/setup tools/build os
	echo 'Success!'
