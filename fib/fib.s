%define SYSCALL_WRITE 0x2000004
%define SYSCALL_READ  0x2000003
%define SYSCALL_EXIT  0x2000001

bits 64

section .text
        
global start
start:
  mov rdi, 10  ; pass 10 as the first and only parameter
  call fib     ; invoke the function
  mov rdi, rax ; put the result in rax in rdi for the exit syscall

  mov rax, SYSCALL_EXIT ; exit
  syscall

;; fib -- given a non-negative integer in rdi, compute
;; the rdi'th fibonacci number
fib:
  push rbp     ; save the old base pointer
  mov rbp, rsp ; base pointer now points to saved base pointer
  
  push rbx     ; callee-save registers
  push r12
  push r13
  
  mov rax, 1   ; first fibonacci number
  mov rbx, 1   ; second fibonacci number
  mov r12, 1   ; temporary, initialized to rax

fib_loop:
  cmp rdi, 1   ; 0 - rdi
  je fib_end
  
  mov r12, rax ; r12 <- rax + rbx
  add r12, rbx
  mov rax, rbx ; rax <- rbx
  mov rbx, r12 ; rbx <- r12
  dec rdi      ; decrement the counter
  jmp fib_loop ; loop
  
fib_end:
  pop r13      ; restore registers
  pop r12
  pop rbx
  leave        ; rsp <- rbp, rbp <- old rbp
  ret          ; result in rax

section .bss
buf: resb 10
        
section .data
str:
  db "Hello, assembly!", 0x0a ; to use escape sequences, use backticks
  strlen equ $ - str
        
