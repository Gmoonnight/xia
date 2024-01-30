%ifndef PRINT_STRING
	%define PRINT_STRING

	; parameters:
	;	es:bp: the memory address of target string
	;	cx: the character number of target string
	print_string:
		; get cursor position
		mov ah, 0x03	; function code of getting curosr position
		int 0x10	; return cursor position = (x, y) = (dh, dl)

		; print string, the print position has loaded in dx already
		mov ax, 0x1301	; ah = 0x13, function code of printing string; al = 0x01, function code of updating cursor
		mov bx, 0x000f  ; bh = 0x00, page number; bl = 0x0f, background color(4 bits, black) + string color(4 bits, white)

		int 0x10
		ret
%endif