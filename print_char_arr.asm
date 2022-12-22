; load the external glibc functions
extern exit, puts, printf, putchar, strlen

section .data

hello_world: db 'Hello, World!'

section .text

; following the convention to be compiled by gcc
global main

; print the string/array of characters
print:
    push    rbp
    mov     rbp, rsp

    ; initialize the counter
    sub     rsp, 16 
    mov     [rbp-16], byte 0

    jmp     loop

; loop through the string/array of characters
loop:
    ; print the character
    movzx   rcx, byte [rbp-16]
    mov     rdi, [hello_world+rcx]
    call    putchar

    ; check the length of the string
    lea     rdi, [hello_world]
    call    strlen

    movzx   rcx, byte [rbp-16]

    add     rcx, 1
    mov     [rbp-16], rcx

    ; compare the counter w/ the length of the string
    cmp     rcx, rax
    jne      loop

    leave
    ret

main:
    push    rbp
    mov     rbp, rsp
    
    ; call print, no param passing, it's a global variable
    call    print
    
    ; exit
    mov     rdi, 0
    call    exit