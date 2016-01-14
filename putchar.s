%ifndef PUTCHAR_S
%define PUTCHAR_S

; putchar: takes an int as input and prints an ascii character
bios_putchar:
	push bp        ; store previous base pointer
	mov bp, sp     ; start frame at current location
	
	push ax        ; save ax to restore later
	
	mov ax, [bp+4] ; copy param to ax
	mov ah, 0x0e   ; BIOS print interrupt
	int 0x10       ; interrupt
	
	pop ax         ; restore ax
	
	pop bp         ; restore previous base pointer
	ret            ; pop return addr into ip and jump

%endif
