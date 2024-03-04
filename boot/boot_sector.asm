[bits 16]

jmp main

	; LBA - DAP(Logical Block Addressing - Disk Address Packet)
	lba_dap: 
		db 16						; bytes of DAP, fixed 0x10
		db 0						; unused, fixed at 0x0
		dw 264						; number of sectors to be read
		dd 0x30000000 				; segment:offset points to the memory address where the sectors to be store to
		dq 1						; the number of the first sector to be read(0, 1, 2, 3, ...)

main:
	; Don't assume the segment registers are set properly. Segment registers will not be changed on method call.
	mov ax, 0x07C0
	mov ds, ax
	mov ax, 0x7000
	mov ss, ax
	mov sp, 0xFFFF					; ss:sp will be used by interrupts mechanism for pushing cs:ip and other stuff to stack

	; Read 264 sectors from boot disk to memory address 0x30000
	mov ah, 0x42 					; function code
	mov si, lba_dap					; ds:si points to the LBA - DAP
	int 0x13

	jmp 0x3000:0x0000 				; enter next step

times 510 - ($ - $$) db 0	; just fill the remain space of 510 B with 0
dw 0xAA55	; magic number
