; ds:bx indicates the start address of the target string
print_string_rm:
	mov ah, 0xe

print_char:
	mov al, [bx]
	cmp al, 0x0

	jz return

	int 0x10
	add bx, 1
	jmp print_char
return:	
	ret