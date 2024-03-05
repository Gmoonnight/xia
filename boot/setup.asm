[bits 16]
jmp main:

	gdt_start:
		dq 0x0 									; null sd
		dq 0x00C09A00000007FF					; csd, r/e, 0x0, 8MB
		dq 0x00C09200000007FF					; dsd, r/w, 0x0, 8MB

	gdt_len equ $ - gdt_start

	gdt_info:
		dw gdt_len 								; GDT bytes
		dd gdt_start 							; GDT base memory address

	%include "boot/legacy_a20.asm"

main:
	; Don't assume the segment registers are set properly.
	mov ax, 0x3000
	mov ds, ax
	mov ax, 0x0
	mov ss, ax
	mov sp, 0xFFFF

	; Reduce legacy A20 issue.
	call reduce_a20

	; Enter protected mode.
	cli 										; disable interrupts
	lgdt [gdt_info]								; load the information of GDT to the register GDTR, 48 bits
	mov eax, cr0
	or eax, 1
	mov cr0, eax 								; enable protected mode
	jmp dword 0x0008:0x30800 					; mixed size jump
