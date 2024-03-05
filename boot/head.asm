[bits 32]

main:
	; Don't assume the segment registers are set properly.
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov esp, 0x7FFFF
	mov ax, 0x0
	mov ds, ax
	mov gs, ax
	sti

set_cr3:
	xor eax, eax
	mov cr3, eax 						; points to pd memory address 0x0, set page cache, set write back

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

	extern _main
	call _main 									; enter kernel

unexpect_loop:
	hlt
	jmp unexpect_loop
