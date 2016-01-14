%ifndef GETKEY_S
%define GETKEY_S

; bios_getkey: wait for a keypress
bios_getkey:
    push bp    ; save old base pointer
    mov bp, sp ; set up stack at current location
    push ax    ; save ax to restore after syscall
    
    mov ah, 0  ; interrupt value
    int 0x16   ; BIOS Keyboard Service
    
    pop ax     ; restore ax
    pop bp     ; restore old base pointer
    ret        ; pop return addr into ip and jump

%endif
