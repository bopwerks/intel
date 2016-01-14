%ifndef PRINTD_S
%define PRINTD_S

bios_printd:
    push bp ; store previous base pointer
    mov bp, sp ; start frame at current location
    push ax
    push bx
    push cx
    push dx
    
    mov ax, [bp+4]     ; ax holds the dividend and quotient
    mov bx, ax         ; bx is a scratch register
    mov cx, 0          ; cx holds the number of digits read
    mov dx, 0          ; dx acts as the upper 16 bits of dividend; zero out
    and bx, 0x8000     ; if the number is non-negative
    jz bios_pd_digits ; start reading digits
    push '-'           ; otherwise, push the sign character
    call bios_putchar  ; print the character
    add sp, 2          ; clean up stack
    mov bx, -1         ; make value in ax positive
    imul bx            ; multiply ax by -1
bios_pd_digits:
    mov bx, 10         ; put divisor in bx
    idiv bx            ; divide dx:ax by bx; quotient in ax, remainder in dx
    add dx, '0'        ; offset remainder to make it an ascii character
    push dx            ; save the character
    inc cx             ; increment digit count
    mov dx, 0          ; zero out upper 16 bits of dividend
    cmp ax, 0          ; if number is not zero,
    jnz bios_pd_digits ; handle next digit
bios_pd_print:
    cmp cx, 0 ; if digit count is zero
    jz bios_pd_end ; finish up
    pop bx
    push bx
    call bios_putchar ; will pop a char off the stack
    add sp, 2 ; clear the last char off the stack
    dec cx ; decrement digit count
    jmp bios_pd_print
bios_pd_end:
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret

%endif
