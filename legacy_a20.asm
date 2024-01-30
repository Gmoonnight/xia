%ifndef LEGACY_A20
	%define LEGACY_A20

	%include "print_string.asm"

	a20_on_msg: db "A20 is on!", 0x0A, 0x0D
	a20_on_msg_len equ $ - a20_on_msg

	a20_off_msg: db "A20 is off!", 0x0A, 0x0D
	a20_off_msg_len equ $ - a20_off_msg

	a20_fail_msg: db "Try to open A20, but it fails. Sorry, your machine is too old!", 0x0A, 0x0D
	a20_fail_msg_len equ $ - a20_fail_msg

	open_a20:
		call check_a20

		test bx, bx
		jz a20_off_reduce

		mov bp, a20_on_msg
		mov cx, a20_on_msg_len	
		call print_string
		ret

	check_a20:
		; Save the data of registers to stack
		push ds
		push si
		push es
		push di

		; Save the data of memory to stack
		xor ax, ax	; rest ax to 0x0000
		mov ds, ax
		mov si, 0x0520

		not ax	; rest ax to 0xFFFF
		mov es, ax
		mov di, 0x0530

		mov al, byte [ds:si]
		mov ah, byte [es:di]

		push ax

		; Check wether A20 is open firstlly
		mov byte [ds:si], 0x00
		mov byte [es:di], 0xFF

		cmp byte [ds:si], 0x00

		mov bx, 0x0001	; A20 is open!
		je check_a20_exit

		mov bx, 0x0000	; A20 is close!
		jmp check_a20_exit

	check_a20_exit:
		; Restore the data of memory from stack
		pop ax
		mov byte [es:di], ah
		mov byte [ds:si], al

		; Restore the data of registers from stack
		pop di
		pop es
		pop si
		pop ds

		ret

	a20_off_reduce:
		mov bp, a20_off_msg
		mov cx, a20_off_msg_len
		call print_string

		; Don't want to support too old machine, if the machine is really needed, here could be extended for specific machine.
		mov bp, a20_fail_msg
		mov cx, a20_fail_msg_len
		call print_string
		jmp $

%endif
