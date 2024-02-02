[bits 16]
jmp main

	welcome_msg: db "Welcome to setup.", 0x0A, 0x0D, 0x00

	%include "tools/print_string.asm"

main:
	mov ax, 0x9020
	mov ds, ax
	mov si, welcome_msg
	call print_string
	
	jmp $

; Read 240 sectors from disk to memory address 0x10000
; mov ax, 0x02F0
; mov dh, 0x00
; mov cx, 0x0006
; mov bx, 0x1000
; mov es, bx
; mov bx, 0x0000

; int 0x13
