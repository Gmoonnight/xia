[bits 16]
jmp main

	welcome_msg: db "Welcome to setup.", 0x0A, 0x0D, 0x00

	; GDT table(segment table) is prepared for entering protected mode
	gdt_base:
    dq 0x0000000000000000   ; first descriptor in GDT is not used
    dq 0x00C09A00000007FF   ; code segment, read and execute, base address = 0x00000000, limit = 0x007FF, G = 1(unit: 4KB) => 8MB
    dq 0x00C09200000007FF   ; data segment, read and write, base address = 0x00000000, limit = 0x007FF, G = 1(unit: 4KB) => 8MB

	gdt_len equ $ - gdt_base
	
	; The metadata of GDT
	gdt_info:
    dw gdt_len	; the number of gdt bytes
    dd gdt_base

	%include "tools/print_string.asm"
	%include "boot/legacy_a20.asm"

main:
	; Print welcome msg to screen
	mov ax, 0x9020
	mov ds, ax
	mov si, welcome_msg
	call print_string

	; Initialize stack registers, it will be used by function open_A20
	mov ax, 0x9000
	mov ss, ax
	mov sp, 0xFF00	; the initial stack bottom pointer is 0x9FF00

	; Read boot driver number from memory address 0x90000 to dl
	mov ax, 0x9000
	mov ds, ax
	mov dx, [ds:0x0000]
	
	; Read 240 sectors from boot disk to memory address 0x00000 for jump to here later
	xor ax, ax
	mov es, ax
	mov bx, 0x0000 	; target memory address = es:bx = 0x0000:0x0000
	mov ax, 0x02F0 	; ah = function code indicates reading sectors from driver, al = read how much sectors
	mov dh, 0x00 	; dh = which head(0, 1, ...), dl = which boot driver(0x00, 0x01, ..., 0x80, 0x81, ...)
	mov cx, 0x0006 	; ch = which cylinder(0, 1, ...), cl = which sector to be read firstly(1, 2, ...)

	int 0x13

	; Enter protected mode from real mode
	cli 	; disable interrupts
	call reduce_a20	; reduce A20 issue
	lgdt [gdt_info]	; load the metadata of GDT to the register GDTR
	mov eax, cr0
	or eax, 1
	mov cr0, eax 	; enable protected mode
	jmp dword 0x0008:0x00000000 	; mixed size jump to the code segment by new addressing mode(segment selector : segment offset)
	sti 	; enable interrupts
	
