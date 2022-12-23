; load the external glibc functions
extern exit, malloc, free

section .data

section .text

global main

binary_tree:
    ; [rbp+16] -> value
    ; [rbp+24] -> frequency

    ; returns a 32 byte node:
    ; char[] -> 8 bytes
    ; frequency -> 8 bytes
    ; *left -> 8 bytes (NULL)
    ; *right -> 8 bytes (NULL)

    push    rbp
    mov     rbp, rsp

    ; value: equ qword [rbp+8]
    ; frequency: equ qword [rbp+16]

    ; allocate memory for the node    
    sub     rsp, 16
    ; [rbp-16] -> *node

    mov     rdi, 32
    call    malloc 
    mov     [rbp-16], rax

    ; initialize the node
    mov     rax, [rbp-16]

    ; value
    mov     rbx, [rbp+16]   ; first arg
    mov     qword [rax], rbx
    ; frequency
    mov     rdx, [rbp+24]   ; second arg
    mov     qword [rax+8], rdx
    ; left
    mov     qword [rax+16], 0
    ; right
    mov     qword [rax+24], 0

    ; mov     rdi, [rbp-16]
    ; call    free

    mov     rax, [rbp-16]

    leave
    ret

add_left:
    ; [rbp+16] -> parent
    ; [rbp+24] -> left child

    ; assigns a *node to the left branch of the parent node

    push    rbp
    mov     rbp, rsp

    ; parent
    mov     rbx, [rbp+16]   ; first arg

    ; child
    mov     rdx, [rbp+24]   ; second arg

    ; move the child node to the left of the parent node
    mov     [rbx+8*2],  rdx

    leave
    ret

add_right:
    ; [rbp+16] -> parent
    ; [rbp+24] -> right child

    ; assigns a *node to the right branch of the parent node

    push    rbp
    mov     rbp, rsp

    ; parent
    mov     rbx, [rbp+16]   ; first arg

    ; child
    mov     rdx, [rbp+24]   ; second arg

    ; move the child node to the right of the parent node
    mov     [rbx+8*3],  rdx

    leave
    ret

main:
    push    rbp
    mov     rbp, rsp
    
    sub     rsp, 64
    ; [rbp-64] -> local_var1
    ; [rbp-56] -> local_var2
    ; [rbp-48] -> local_var3
    ; [rbp-32] -> parent
    ; [rbp-24] -> left child
    ; [rbp-16] -> right child


    ; create parent node
    mov     qword [rbp-64], 0x40    ; pass first arg (char) = 'A'
    mov     qword [rbp-56], 100     ; pass second arg (frequency)
    call    binary_tree
    mov     [rbp-32], rax           ; store parent's allocated memory address

    ; create left node
    mov     qword [rbp-64], 0x41    ; 'B'
    mov     qword [rbp-56], 101
    call    binary_tree
    mov     [rbp-24], rax

    ; create right node
    mov     qword [rbp-64], 0x42    ; 'C'
    mov     qword [rbp-56], 102
    call    binary_tree
    mov     [rbp-16], rax

    ; add left node to parent
    mov     rsi, [rbp-32]
    mov     rdi, [rbp-24]
    mov     qword [rbp-64], rsi
    mov     qword [rbp-56], rdi
    call    add_left

    ; add right node to parent
    mov     rsi, [rbp-32]
    mov     rdi, [rbp-16]
    mov     qword [rbp-64], rsi
    mov     qword [rbp-56], rdi
    call    add_right

    ; exit (success)
    mov     rdi, 0
    call    exit