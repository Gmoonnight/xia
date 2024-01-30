; Copy boot sector from memory address [0x07C00, 0x07Dff] to [0x90000, 0x901FF] by ds:si and es:di
mov ax, 0x07C0
mov ds, ax
xor si, si
mov ax, 0x9000
mov es, ax
xor di, di

times 256 movsw

; Do some initial work for registers
jmp 0x9000:go
go:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0xFF00

; Read 4 sectors from driver to memory address 0x90200
mov ax, 0x0204	; ah = read sectors from drive, al = sectors to read count
mov dh, 0x00	; dh = head number, dl = driver number (BIOS has written driver number to dl) 
mov cx, 0x0002	; ch = cylinder number, cl = sector number
mov bx, 0x0200	; phsical address of memory = es:bx = 0x9000:0x0200

int 0x13

; Read 240 sectors from disk to memory address 0x10000
mov ax, 0x02F0
mov dh, 0x00
mov cx, 0x0006
mov bx, 0x1000
mov es, bx
mov bx, 0x0000

int 0x13

jnc print_welcome_string

jmp $

; Print OS welcome string
print_welcome_string:
	mov ax, 0x1301	; ah = print string, al = update cursor, the color of background and string depends on bx
	mov bx, 0x000F	; bh = page number(0), bl = background color(4 bits, black) + string color(4 bits, white) 
	mov cx, welcome_str_len	; cx = length of string
	mov dx, 0x9000	; es:bp points to the memory position where string is to be stored
	mov es, dx
	mov bp, welcome_str
	mov dx, 0x0000	; dh = row position where string is to be written, dl = column position where string is to be written
	
	int 0x10

jmp 0x9000:0x0200

welcome_str db "Hello, World!"
welcome_str_len equ $ - welcome_str

times 510 - ($ - $$) db 0	; just fill the remain space of 510 B with 0

dw 0xaa55	; magic number
