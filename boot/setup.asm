[bits 16]
jmp main_16

	gdt_start:
		dq 0x0 									; null sd
		dq 0x00C09A00000007FF					; csd, r/e, 0x0, 8MB
		dq 0x00C09A00000007FF					; dsd, r/w, 0x0, 8MB

	gdt_len equ $ - gdt_start

	gdt_info:
		dw gdt_len 								; GDT bytes
		dd gdt_start 							; GDT base memory address

	%include "boot/legacy_a20.asm"

main_16:
	
	; Initialize segment register, and the values will not be changed on method call.
	mov ax, 0x3000
	mov ds, ax
	mov ax, 0x0
	mov es, ax
	mov ax, 0x7000
	mov ss, ax
	mov sp, 0xFFFF

	; Reduce legacy A20 issue.
	call reduce_a20

	; ------------------------------> Enable Protected Mode
	cli 										; disable interrupts
	lgdt [gdt_info]								; load the information of GDT to the register GDTR, 48 bits
	mov eax, cr0
	or eax, 1
	mov cr0, eax 								; enable protected mode
	jmp dword 0x0008:main_32 					; mixed size jump

[bits 32]
main_32:

	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov esp, 0x7FFFF
	mov ax, 0x0
	mov fs, ax
	mov gs, ax 									; Reload segment registers
	sti
	
	; -------------------------> Enable Page Mode
set_cr3:
	xor eax, eax
	mov cr3, eax 								; points to pd memory address 0x0, set page cache, set write back

set_pd:
	; 1 pd, 2 pde
	mov dword [0x0], 0x1007 					; points to pt-1 memory address 0x1000, page cache, write back, set supervisor, r/w
	mov dword [0x4], 0x2007 					; points to pt-2 memory address 0x2000, page cache, write back, supervisor, r/w

set_pt:
	; 2 pt, 1024 * 2 pte
	mov edi, 0x1000
	std
	mov eax, 0x7 								; points to corresponding memory, pte value, page cache, write back, supervisor, r/w
pte_loop:
	stosd 										; store eax to [es:edi]
	add eax, 0x1000
	cmp eax, 0x7FF7
	jg pte_loop

	mov eax, cr0
	or eax, 0x10000000
	mov cr0, eax 								; enable page mode

	call 0x30800 								; enter kernel

unexpect_loop:
	hlt
	jmp unexpect_loop
