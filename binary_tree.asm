; load the external glibc functions
extern exit, malloc, free, fopen, fclose, fread, fwrite

section .bss
buffer resb 1024

section .data
input: db "in.bin", 0
output: db "out.bin", 0
read_mode: db "r", 0
write_mode: db "w", 0
len_buffer: dq 64

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


load_binary_tree:
    ; takes a sequential binary tree and loads it into memory
    ; as a binary tree (left and right pointer)

    ; [rbp-8] -> allocated array of nodes (sequential binary tree)

    push    rbp
    mov     rbp, rsp
    
    sub     rsp, 16
    mov     qword [rbp-16], 0   ; counter
    
    ; sequential binary tree (mirror array for debugging purposes)
    mov     rdi, [len_buffer]
    imul    rdi, 8
    call    malloc
    mov     [rbp-8], rax

    ; create binary tree root
    mov     rdx, [buffer+8]     ; frequency
    push    rdx     
    mov     rdx, [buffer]       ; value
    push    rdx
    call    binary_tree
    add     rsp, 16 

    mov     rcx, 0

    ; save root to the allocated mirror array
    mov     rsi, [rbp-8]
    mov     [rsi+rcx*8], rax

    ; save root index
    push    rcx

    .traverse:

        ; recursion cond
        mov     rdx, [len_buffer]
        dec     rdx
        mov     rax, [rbp-16]        ; saved counter value
        cmp     rax, rdx             ; len_buffer-1
        jge     .exit                ; all items has been loaded

        cmp     rcx, [len_buffer]      ; len_buffer

        ; add left node (sten into)
        jl      .add_left_node
        
        ; step out to parent
        pop     rcx

        ; step into right node
        jmp     .add_right_node

        leave
        ret

    .add_left_node:
        ; rcx = rcx*2+1 > new left
        imul    rcx, 2
        inc    rcx

        ; check if out of scope
        cmp    rcx, [len_buffer]
        jge     .continue_left

        ; save rcx because it will be overwritten
        push    rcx 

        ; create binary tree node (left)    
        ; i cannot use [buffer+rcx*16] because it is a 16 byte array
        ; so splitting it into 8 byte chunks is necessary
        lea     rdx, [rcx*8]
        lea     rdx, [rdx*2]
        mov     rdx, [buffer + rdx + 8]  ; next 8 bytes: frequency
        push    rdx
        lea     rdx, [rcx*8]
        lea     rdx, [rdx*2]
        mov     rdx, [buffer + rdx]      ; first 8 bytes: value
        push    rdx
        call    binary_tree
        add     rsp, 16

        ; pop rcx
        pop     rcx

        ; add to allocated mirror array
        mov     rsi, [rbp-8]
        mov     [rsi+rcx*8], rax

        ; load parent node into rbx
        mov     rbx, [rsp]          ; parent index
        mov     rdx,[rbp-8]         ; mirror array address
        mov     rbx, [rdx+rbx*8]    ; parent node's allocated address

        ; add left node to parent
        push    rax
        push    rbx
        call    add_left
        add     rsp, 16

        ; save the left node as a parent to its children
        push    rcx

        ; increment counter
        inc     qword [rbp-16]
        jmp     .traverse
        

    .add_right_node:
        ; save parent index on stack for later (adding right node to it)
        mov      rbx, rcx
        push     rbx
        
        ; 2*rcx + 2
        add     rcx, rcx
        add     rcx, 2

        ; check if out of scope
        cmp     rcx, [len_buffer]
        jge     .continue_right

        ; save rcx because it will be overwritten
        push    rcx

        ; create binary tree node (right)    
        ; i cannot use [buffer+rcx*16] because it is a 16 byte array
        ; so splitting it into 8 byte chunks is necessary
        lea     rdx, [rcx*8]
        lea     rdx, [rdx*2]
        mov     rdx, [buffer + rdx + 8]  ; next 8 bytes: frequency
        push    rdx
        lea     rdx, [rcx*8]
        lea     rdx, [rdx*2]
        mov     rdx, [buffer + rdx]      ; first 8 bytes: value
        push    rdx
        call    binary_tree
        add     rsp, 16

        pop     rcx

        ; add to allocated mirro array
        mov     rsi, [rbp-8]
        mov     [rsi+rcx*8], rax

        ; get the parent node's address
        pop     rbx
        mov     rdx,[rbp-8]
        mov     rbx, [rdx+rbx*8] 

        ; add right node to parent node
        push    rax
        push    rbx
        call    add_right
        add     rsp, 16

        ; save as parent for children
        push    rcx
        inc     qword [rbp-16]
        jmp     .traverse
        
    .continue_left:
        jmp   .traverse

    .continue_right:
        ; step out to parent
        pop     rbx

        ; continue
        jmp   .traverse

    ; exit (success)
    .exit:
        mov     rax, [rbp-8]
        mov     rax, [rax]
        leave
        ret

export_binary_tree:
    push    rbp
    mov     rbp, rsp

    sub     rsp, 32

    ; takes the address of a binary tree
    ; and the max level of the tree
    ; traverses it to an array

    ; allocate the array
    mov     cl, byte [rbp+24]    ; max level
    
    ; 2^max_level
    shl     rdi, cl

    ; malloc 2^max_level * 8 bytes 
    ; (complete binary tree representation requires this size)
    lea     rdi, [rax*8]
    call    malloc

    ; save the address of the array
    mov     [rbp-8], rax

    ; move the root address to local
    mov     rbx, [rbp+16]
    mov     [rbp-16], rbx

    ; move root to allocated array
    mov     rdi, [rbp-8]
    mov     rsi, [rbx]
    mov     [rdi], rsi
    mov     rsi, [rbx+8]
    mov     [rdi+8], rsi

    push    -1          ; indicator for passing root node (stopping reucrsion)
    mov     rcx, 0      ; counter
    push    rcx         ; push counter
    push    rbx         ; push root node address
    
    .traverse:
        mov     rbx, [rbp-16]
        cmp     qword [rbx + 16], 0
        jne     .go_left

    .go_left:
        ; go left: rcx = 2*rcx + 1
        add     rcx, rcx
        add     rcx, 1 

        ; step into left node
        mov     rbx, [rbx+16]

        ; check if left node exists
        cmp     rbx, 0
        je     .go_up   ; step out to paret 
        
        ; hacky way of addressing 16 byte chunks
        lea     rdx, [rcx*8]
        lea     rdx, [rdx*2]
        mov     rdi, [rbp-8]
        ; move the value and frequency to the sequential array
        mov     rsi, [rbx]
        mov     [rdi+rdx], rsi  
        mov     rsi, [rbx+8]
        mov     [rdi+rdx+8], rsi

        ; save the node if it has right elemets (to go back to after left is finished)
        cmp     qword [rbx + 24], 0
        je     .continue
        .has_right:
        push    rcx
        push    rbx

        .continue:
        cmp     qword [rbx + 16], 0
        jne     .go_left

        .go_up:
        ; step out to parent
        ; rcx = (rcx-1) // 2
        sub     rcx, 1
        shr     rcx, 1  ; //2
        pop     rbx
        pop     rcx

        ; recursion condition
        ; if we hit the -1 indicator, exit
        cmp     rbx, -1
        jne     .go_right
        jmp     .exit


    .go_right:
        ; go right: rcx = 2*rcx + 2

        add     rcx, rcx
        add     rcx, 2

        ; step into right node
        mov     rbx, [rbx+24]

        ; hacky way of addressing 16 byte chunks
        lea     rdx, [rcx*8]
        lea     rdx, [rdx*2]
        mov     rdi, [rbp-8]
        ; move the value and frequency to the sequential array
        mov     rsi, [rbx]
        mov     [rdi+rdx], rsi
        mov     rsi, [rbx+8]
        mov     [rdi+rdx+8], rsi

        ; check if node has right children
        cmp     qword [rbx + 24], 0
        je     .continue
        ; if has right nodes, add to go back to later
        push    rcx
        push    rbx

        .continue_right:
        jmp     .go_left

    .exit:
        leave
        ret

load_file:    
    push    rbp
    mov     rbp, rsp

    sub     rsp, 16

    ; call fopen to return a file pointer
    mov rdi, input
    mov rsi, read_mode
    call fopen
    mov rdi, rax
    mov [rbp-16], rdi

    ; read the file pointer into buffer
    mov     rdi, buffer
    mov     rsi, [len_buffer]
    mov     rdx, 8
    mov     rcx, [rbp-16]     ; fp
    call    fread

    ; close the file
    mov rdi, [rbp-16]
    call fclose

    leave
    ret

write_file:
    push   rbp
    mov    rbp, rsp

    sub    rsp, 16

    ; call fopen to return a file pointer
    mov     rdi, output
    mov     rsi, write_mode
    call    fopen
    mov     [rbp-16], rax

    ; write to the buffer
    mov     rdi, [rbp+16]
    mov     rsi, [len_buffer]
    mov     rdx, 8
    mov     rcx, [rbp-16]
    call    fwrite

    ; close
    ; somehow fclose didn't work!
    mov     rax, 3                 ; close
    mov     rdi, [rbp-16]          ; file descriptor
    syscall

    leave
    ret

main:
    push    rbp
    mov     rbp, rsp

    call    load_file
    call    load_binary_tree

    push    8
    push    rax
    call    export_binary_tree
    
    push    rax
    call write_file 

    mov     rdi, rax
    leave
    ret