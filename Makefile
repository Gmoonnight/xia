boot/boot_sector: boot/boot_sector.asm tools/print_string.asm 
	nasm -f bin boot/boot_sector.asm -o boot/boot_sector
	echo 'Build boot/boot_sector...OK'

boot/setup: tools/print_string.asm boot/legacy_a20.asm
	nasm -f bin boot/setup.asm -o boot/setup
	echo 'Build boot/setup...OK'

boot/system: boot/head.asm kernel/kernel.c
	nasm -f elf32 boot/head.asm -o boot/head.o
	clang -c -std=c17 -m32 -ffreestanding kernel/kernel.c -o kernel/kernel.o
	
tools/build: tools/build.c
	clang -std=c17 tools/build.c -o tools/build
	echo 'Build tools/build...OK'

os: boot/boot_sector boot/setup boot/head tools/build
	tools/build
	echo 'Build os...OK'
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
	rm -rf boot/boot_sector boot/setup boot/head.o kernel/kernel.o boot/system tools/build os
	echo 'Success!'
