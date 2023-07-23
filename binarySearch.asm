
%ifndef SYS_EQUAL
%define SYS_EQUAL

    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
   
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
     

    sys_mkdir       equ 83
    sys_makenewdir  equ 0q777


    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
   
     
    sys_exit     equ     60
   
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
PROT_NONE  equ   0x0
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
   
    ;access mode
    O_DIRECTORY equ     0q0200000
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000


    BEG_FILE_POS    equ     0
    CURR_POS        equ     1
    END_FILE_POS    equ     2
   
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0xA
    Space         equ   0x20

%endif

%ifndef NOWZARI_IN_OUT
%define NOWZARI_IN_OUT

;----------------------------------------------------
newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret
;---------------------------------------------------------
putc:

   push   rcx
   push   rdx
   push   rsi
   push   rdi
   push   r11

   push   ax
   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout
   syscall
   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi
   push   r11

 
   sub    rsp, 1
   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall
   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx,  rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx
   cmp    bl, 0
   je     sEnd
   neg    rax
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret

;-------------------------------------------
printString:
   push    rax
   push    rcx
   push    rsi
   push    rdx
   push    rdi

   mov     rdi, rsi
   call    GetStrlen
   mov     rax, sys_write  
   mov     rdi, stdout
   syscall
   
   pop     rdi
   pop     rdx
   pop     rsi
   pop     rcx
   pop     rax
   ret
;-------------------------------------------
; rdi : zero terminated string start
GetStrlen:
   push    rbx
   push    rcx
   push    rax  

   xor     rcx, rcx
   not     rcx
   xor     rax, rax
   cld
         repne   scasb
   not     rcx
   lea     rdx, [rcx - 1]  ; length in rdx

   pop     rax
   pop     rcx
   pop     rbx
   ret
;-------------------------------------------

%endif



section .data
    no: db 'NaN', 0
    yes: db 'YES', 0

section .bss
    a: resb 100000000

section .text
    global _start


_start:

  call readNum
  cmp rax, 0
  jz notFound
  mov r8, rax ;len array - end index

xor rcx, rcx
mov2arr:
    call readNum
    mov [a + rcx], rax
    inc rcx
    cmp rcx, r8
    jnz mov2arr

call readNum
mov rbx, rax ;desired num

; xor rcx, rcx
; while2:
;     mov al, [a + rcx]
;     call writeNum
;     inc rcx
;     cmp rcx, r8
;     jnz while2
; call newLine

mov r9, a ;start index
xor r10, r10 ;mid index
add r8, a ;end index

; sub r8
; call writeNum
; call newLine

push r9
push r10
push r8
call BS

BS:
    push rbp
    mov rbp, rsp
    
    mov r8, [rbp + 16]
    mov r10, [rbp + 24]
    mov r9, [rbp + 32]
    
    cmp r9, r8
    jge done
    cmp r8, r9
    jle done
    
    mov r10, r8
    sub r10, r9
    shr r10, 1
    add r10, r9

    ; xor rax, rax
    ; mov rax, r8
    ; call writeNum
    ; call newLine
    
    ; xor rax, rax
    ; mov rax, r10
    ; call writeNum
    ; call newLine
    
    ; xor rax, rax
    ; mov rax, r9
    ; call writeNum
    ; call newLine
    
    ; xor rax, rax
    ; mov al, [r10]
    ; call writeNum
    ; call newLine

    cmp [r10], bl
    je found
    jbe isbigger
    dec r10
    mov r8, r10
    
    push r9
    push r10
    push r8
    
    call BS
    ret 16

isbigger:
    inc r10
    mov r9, r10
    push r9
    push r10
    push r8
    call BS

done:
    mov r10, r9
    cmp [r9], bl
    je found
    jmp notFound

found:
    xor rcx, rcx
    mov rcx, 0
    mov r11, r10
    find1num:
        cmp [r11], bl
        jne end
        mov r10, r11
        dec r11
        cmp r11, a
        jb end
        jmp find1num
   
   end:
    sub r10, a
    mov rax, r10
    call writeNum
    call Exit

notFound:
    mov rsi, no
    call printString
    call Exit

Exit:
    call newLine
    mov rax, sys_exit
    mov rdi, rdi
    syscall
