%ifndef PUTS_S
%define PUTS_S

%include "putchar.s"

; puts: takes a char* as input and prints it with a newline
bios_puts:
    push bp        ; store old base pointer
    mov bp, sp     ; start frame at current location
    
    push ax        ; save ax to restore later
    push si        ; save si to restore later
    
    mov si, [bp+4] ; copy character pointer to si
bios_puts_loop:
    lodsb              ; load byte from si into al
    or al, al          ; if it's the end of the string
    jz bios_puts_end   ; go to the end
    push ax            ; push ax for putchar
    call bios_putchar  ; print value of al
    add sp, 2          ; clean up stack
    jmp bios_puts_loop ; loop
bios_puts_end:
    call bios_newline ; print a newline
    pop si            ; restore si
    pop ax            ; restore ax
    pop bp            ; restore the base pointer
    ret               ; pop return addr into sp and jump

%endif
