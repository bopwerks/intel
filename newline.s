%ifndef NEWLINE_S
%define NEWLINE_S

%include "putchar.s"

; bios_newline: print a newline
bios_newline:
    push bp    ; save old base pointer
    mov bp, sp ; set up stack at current location
    
    push 0x0d         ; push '\r'
    call bios_putchar ; print the character
    add sp, 2         ; clean up the stack
    
    push 0x0a         ; push '\n'
    call bios_putchar ; print the character
    add sp, 2         ; clean up the stack
    
    pop bp ; restore bp
    ret    ; pop return address into ip and jump

%endif
