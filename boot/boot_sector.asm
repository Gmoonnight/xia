[bits 16]

jmp main

main:

	; Read 4 sectors from boot disk to memory address 0x90200 for jump to here later
	mov ax, 0x9000
	mov es, ax
	mov bx, 0x0200	; target memory address = es:bx = 0x9000:0x0200
	mov ax, 0x0204	; ah = function code indicates reading sectors from driver, al = read how much sectors
	mov dh, 0x00	; dh = which head(0, 1, ...), dl = which boot driver(BIOS has written driver number to dl) (0x00, 0x01, ..., 0x80, 0x81, ...)
	mov cx, 0x0002	; ch = which cylinder(0, 1, ...), cl = which sector to be read firstly(1, 2, ...)

	int 0x13

	; Save boot driver number to 0x90000 for later using
	mov ax, 0x9000
	mov ds, ax
	mov [ds:0x0000], dx

	jmp 0x9020:0x0000 	; jump to next step

times 510 - ($ - $$) db 0	; just fill the remain space of 510 B with 0
dw 0xAA55	; magic number
