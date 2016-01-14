%ifndef RESET_S
%define RESET_S

%include "getkey.s"

; bios_reset: reset the machine
bios_reset:
	add sp, 2        ; clean up the stack
	call bios_getkey ; wait for input

	; send us to the end of the memory
	; causing reboot 
	db 0x0ea
	dw 0x0000
	dw 0xffff

%endif
