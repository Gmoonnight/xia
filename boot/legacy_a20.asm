%ifndef LEGACY_A20
	%define LEGACY_A20

	a20_on_msg: db "A20 is on!", 0x0A, 0x0D, 0x00
	a20_off_msg: db "A20 is off! Your machine is too old.", 0x0A, 0x0D, 0x00

	%include "tools/print_string.asm"

	reduce_a20:
		; Save the data of memory to stack
		xor ax, ax	; reset ax to 0x0000
		mov ds, ax
		mov si, 0x0520	; memory address 1 - 0x00520

		not ax	; rest ax to 0xFFFF
		mov es, ax
		mov di, 0x0530 	; memory address 2 - 0x100520

		mov al, byte [ds:si]
		mov ah, byte [es:di]

		push ax

		; Check wether A20 is open firstlly
		mov byte [ds:si], 0x00
		mov byte [es:di], 0xFF

		cmp byte [ds:si], 0x00

		; Restore the data of memory from stack
		pop ax
		mov byte [es:di], ah
		mov byte [ds:si], al

		je a20_on 	; A20 is on

		jmp a20_off 	; A20 is off

	a20_on:
		mov ax, 0x9020
		mov ds, ax
		mov si, a20_on_msg
		
		ret

	a20_off:
		mov ax, 0x9020
		mov ds, ax
		mov si, a20_off_msg
	
		; The demand of opening A20 could be extended in here if it's really needed.

		jmp $

%endif