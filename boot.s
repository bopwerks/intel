bits 16    ; set CPU to 16-bit Real Mode
org 0x7c00 ; load code at this address

jmp main ; jump to program entry point

%include "puts.s"
%include "newline.s"
%include "reset.s"
%include "printd.s"

main:
push sp
call bios_printd
call bios_newline
hlt

IRQSTR  db "This is being printed by an IRQ!", 0x0


my_interrupt:
   push bp
   mov bp, sp
   
   mov ax, 23
   
   pop bp
   iret

; main: program entry point
;main:
   cli        ; clear interrupts
   mov ax, cs ; setup stack segments            
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov word [0x80], my_interrupt
   mov word [0x82], cs
   sti
   
   ; invoke interrupt handler
   int 0x20
   
   push ax
   call bios_printd
   
   call bios_newline
   
   push sp
   call bios_printd
   call bios_newline
   push sp
   call bios_printd
   call bios_newline
   push sp
   call bios_printd
   call bios_newline
   
   ;push my_interrupt
   ;call bios_printd
   
   call bios_newline ; print a newline
   call bios_reset   ; wait for input and reboot

   times 510 - ($-$$) db 0 ; fill the rest of the bootloader with zeros 
   dw 0xaa55               ; boot signature
