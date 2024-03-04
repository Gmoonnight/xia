%ifndef PRINT_STRING
	%define PRINT_STRING

	; usage: ds:si indicates the start address of the target string
	print_string:
	mov ah, 0xE			; function code

	print_char:
	mov al, [ds:si]
	cmp al, 0x0

	jz return

	int 0x10
	add si, 1
	jmp print_char
	return:	
	ret

%endif
