[org 0x90200]
[bits 16]
jmp label_begin

%include "legacy_a20.asm"

; We need prepare some data for transitioning from real mode to protected mode
gdt_base:
	dq 0x0000000000000000	; first descriptor in GDT is not used
	dq 0x00C09A00000007FF	; code segment, read and execute, base address = 0x00000000, limit = 0x007FF, G = 1(8MB)
	dq 0x00C09200000007FF	; data segment, read and write, base address = 0x00000000, limit = 0x007FF, G = 1(8MB)

gdt_len equ $ - gdt_base

gdtr_:
	dw gdt_len
	dd gdt_base

label_begin:
	; Initialize registers
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0xFF00

	; The steps of switching from real mode to protected mode
	; 1. Disable interrupts
	cli
	; 2. Open A20
	call open_a20
	; Load GDTR register
	lgdt [gdtr_]
	; Enable interrupts
	sti