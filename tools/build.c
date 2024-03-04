#include <stdio.h>

int main() {
	// Target file - os
	FILE *os = fopen("os", "w");

	// Source files
	FILE *boot_sector = fopen("boot/boot_sector", "r");	
	FILE *setup = fopen("boot/setup", "r");
	FILE *head = fopen("boot/head", "r");
	
	// Write boot sector to os
	char bs_buf[512];

	unsigned long bs_rc = fread(bs_buf, 1, 512, boot_sector);

	if(bs_rc != 512 || *(unsigned short *)(bs_buf + 510) != 0xAA55) {
		printf("Please check wether boot sector is correct.\n");
		return 0;
	}

	fwrite(bs_buf, 1, bs_rc, os);
	fclose(boot_sector);

	// Write setup to os
	char s_buf[512 * 4];

	unsigned long s_rc = fread(s_buf, 1, 512 * 4, setup);

	fwrite(s_buf, 1, 512 * 4, os);
	fclose(setup);

	// Write head to os
	char h_buf[512 * 240];

	unsigned long h_rc = fread(h_buf, 1, 512 * 240, head);
	fwrite(h_buf, 1, 512 * 240, os);
	fclose(head);

	// All things done.
	fclose(os);

	return 0;
}
