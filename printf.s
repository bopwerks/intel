%ifndef PRINTF_S
%define PRINTF_S

%include "putchar.s"
%include "printd.s"

; printf: print an interpolated format string
bios_printf:
    push bp        ; store previous base pointer
    mov bp, sp     ; start frame at current location
    
    push ax
    push bx
    push cx
    push dx
    
    mov cx, 0      ; set the 0-based parameter counter to 0
    mov ax, 2 ; move 2 to ax
    imul cx   ; multiple ax by cx
    mov bx, ax ; copy to bx
    add bx, bp ; offset to the base pointer
    add bx, 4 ; skip over return value
    mov si, [bx] ; get int parameter from stack params
printf_next_char:
    lodsb                  ; read character from si into al and inc si
    or  al, al             ; if the character is not '\0',
    jnz printf_handle_char ; handle it
    mov ax, 0              ; otherwise, signal success
    jmp printf_end         ;
printf_handle_char:
    mov bl, al     ; copy the character to bl for comparison
    xor bl, '%'    ; if we have a format character
    jz printf_fmt  ; handle the format character
    push ax        ; push the character
    call bios_putchar   ; print the character
    add sp, 2      ; clean up the stack
    jmp printf_next_char ; handle the next char
printf_fmt:
    add cx, 1      ; increment the param counter
    lodsb          ; read the format specifier
    mov bl, al     ; copy the character to bl for comparison
    xor bl, 'c'    ; if we're just printing a character,
    jz printf_ch   ; print the character
    mov bl, al     ; otherwise, copy the character to bl for comparison
    xor bl, 's'    ; if we have a string param,
    jz printf_s    ; print the string
    mov bl, al     ; otherwise, copy the character to bl for comparison
    xor bl, 'd'    ; if we have an int,
    jz printf_d    ; print it
    mov ax, 1      ; otherwise signal error
    jmp printf_end ; and exit
printf_ch:
    mov ax, 2 ; move 2 to ax
    imul cx   ; multiple ax by cx
    mov bx, ax ; copy to bx
    add bx, bp ; offset to the base pointer
    add bx, 4 ; skip over return value
    mov ax, [bx] ; get int parameter from stack params
    push ax        ; print the character parameter
    call bios_putchar   ; print the character
    add sp, 2      ; clean up the stack
    jmp printf_next_char ; loop back to read next char
printf_s:
    mov ax, 2 ; move 2 to ax
    imul cx   ; multiple ax by cx
    mov bx, ax ; copy to bx
    add bx, bp ; offset to the base pointer
    add bx, 4 ; skip over return value
    push si
    mov si, [bx] ; get int parameter from stack params
printf_s_loop:
    lodsb          ; load character into al
    or al, al      ; if the character is '\0'
    jz printf_s_end ; clean up and read next param
    push ax        ; otherwise print the character
    call bios_putchar   ; print the character
    add sp, 2      ; clean up stack
    jmp printf_s_loop ; read the next character from the string param
printf_s_end:
    pop si         ; restore the si for the fmt string
    jmp printf_next_char ; read the next character in the format string
printf_d:
    mov ax, 2 ; move 2 to ax
    imul cx   ; multiple ax by cx
    mov bx, ax ; copy to bx
    add bx, bp ; offset to the base pointer
    add bx, 4 ; skip over return value
    mov ax, [bx] ; get int parameter from stack params
    push ax ; push the integer argument
    call bios_printd ; print the integer
    add sp, 2 ; clean up the stack
    jmp printf_next_char ; read the next character from the format string
printf_end:
    pop dx
    pop cx
    pop bx
    pop ax
    
    pop bp         ; restore previous base pointer
    ret            ; pop return addr from sp into ip and jump

%endif
