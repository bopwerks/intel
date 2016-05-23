#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

/* This is a NASM listing for procedure that takes a single integer N
 * as a parameter and computes and returns the Nth fibonacci number.
 */
/*  3                                  fib: */
/*  4 00000000 55                        push rbp     ; save the old base pointer */
/*  5 00000001 4889E5                    mov rbp, rsp ; base pointer now points to saved base pointer */
/*  6                                     */
/*  7 00000004 53                        push rbx     ; callee-save registers */
/*  8 00000005 4154                      push r12 */
/*  9 00000007 4155                      push r13 */
/* 10                                     */
/* 11 00000009 48B801000000000000-       mov rax, 1   ; first fibonacci number */
/* 12 00000012 00                  */
/* 13 00000013 48BB01000000000000-       mov rbx, 1   ; second fibonacci number */
/* 14 0000001C 00                  */
/* 15 0000001D 49BC01000000000000-       mov r12, 1   ; temporary, initialized to rax */
/* 16 00000026 00                  */
/* 17                                   */
/* 18                                  fib_loop: */
/* 19 00000027 4881FF01000000            cmp rdi, 1   ; 0 - rdi */
/* 20 0000002E 7414                      je fib_end */
/* 21                                     */
/* 22 00000030 4989C4                    mov r12, rax ; r12 <- rax + rbx */
/* 23 00000033 4901DC                    add r12, rbx */
/* 24 00000036 4889D8                    mov rax, rbx ; rax <- rbx */
/* 25 00000039 4C89E3                    mov rbx, r12 ; rbx <- r12 */
/* 26 0000003C 48FFCF                    dec rdi      ; decrement the counter */
/* 27 0000003F E9E3FFFFFF                jmp fib_loop ; loop */
/* 28                                     */
/* 29                                  fib_end: */
/* 30 00000044 415D                      pop r13      ; restore registers */
/* 31 00000046 415C                      pop r12 */
/* 32 00000048 5B                        pop rbx */
/* 33 00000049 C9                        leave        ; rsp <- rbp, rbp <- old rbp */
/* 34 0000004A C3                        ret          ; result in rax */
unsigned char opcodes[] = {
   0x55, 0x48, 0x89, 0xE5, 0x53,
   0x41, 0x54, 0x41, 0x55, 0x48,
   0xB8, 0x01, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x48,
   0xBB, 0x01, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x49,
   0xBC, 0x01, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x48,
   0x81, 0xFF, 0x01, 0x00, 0x00,
   0x00, 0x74, 0x14, 0x49, 0x89,
   0xC4, 0x49, 0x01, 0xDC, 0x48,
   0x89, 0xD8, 0x4C, 0x89, 0xE3,
   0x48, 0xFF, 0xCF, 0xE9, 0xE3,
   0xFF, 0xFF, 0xFF, 0x41, 0x5D,
   0x41, 0x5C, 0x5B, 0xC9, 0xC3
};

typedef int (*Function)(int);

int
main(void)
{
   int i, rval;
   char *code;

   /* The opcodes[] array cannot be executed directly as code
    * because it's defined in the data section of the executable
    * which the kernel makes read-write-only. We have to explictly
    * request a block of memory from the kernel that's executable
    * and copy the contents of opcodes[] there to execute it. We
    * use the mmap() function to do this. The first parameter is
    * the address to use for the block. NULL indicates the kernel
    * should choose a suitable location. The second parameter is
    * the size of the block. We only need enough space for the
    * contents of the opcodes[] array. The third parameter is the
    * the bitfield specifying properties of the block -- in this
    * case, it's write- and execute-enabled. The fourth parameter
    * specifies flags. MAP_PRIVATE indicates that this block should
    * not be accessible to other processes. MAP_ANON indicates
    * that no file descriptor is associated with this block. The
    * fifth parameter is the file descriptor; -1 indicates no
    * descriptor. The last parameter is an offset, which is unused.
    */
   code = mmap(NULL, sizeof(opcodes), PROT_EXEC | PROT_WRITE,
            MAP_PRIVATE | MAP_ANON, -1, 0);
   if (code == MAP_FAILED) {
      perror("mmap");
      return EXIT_FAILURE;
   }
   memmove(code, opcodes, sizeof(opcodes));
   for (i = 1; i <= 20; ++i)
      printf("%d\n", ((Function) code)(i));
   rval = munmap(code, sizeof(opcodes));
   if (rval == -1)
      perror("munmap");
   return EXIT_SUCCESS;
}
