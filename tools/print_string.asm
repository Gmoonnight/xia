; ds:si indicates the start address of the target string
print_string:
	mov ah, 0x0E

print_char:
	mov al, [ds:si]
	cmp al, 0x00

	jz return

	int 0x10
	add si, 0x0001
	jmp print_char
return:	
	ret
