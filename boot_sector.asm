[org 0x7c00]

[bits 16]

mov bp, 0x9000
mov sp, bp

mov bx, rm_welcome_msg
call print_string_rm

%include "./print_string_rm.asm"

jmp $

rm_welcome_msg:
	db "Welcome to RM World!", 0

times 510 - ($ - $$) db 0	; just fill the remain space of 512 B with 0b

dw 0xaa55
