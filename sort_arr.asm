; load the external glibc functions
extern exit, puts, printf, putchar, strlen

section .data

lst: times 5 dq 3, 2, 5, 1, 3, 7, 2, 4, 5, 6
format_string: db "%d", 10, 0
len_lst: dq 10

section .text

global main

get_pos:
    push   rbp
    mov    rbp, rsp

    ; get the next position
    sub    rsp, 16
    mov    rax, [rbp+16]    ; rax = counter passed as argument
    inc    rax

    mov    [rbp-16], rax

    ; this var will hold the position of the biggest element
    mov    [rbp-8], byte 0

    ; rax = biggest element value thus far
    ; used in comparison
    mov    rax, [lst+rax*8]

    jmp    .loop

    ; loop through what's remaining of the array 
    .loop:
        ; loop condition
        movzx  rcx, byte [rbp-16]
        cmp    rcx, [len_lst]
        jge    .end_not_found

        ; compare the current element with the biggest element thus far
        mov    rdx, [lst+rcx*8]
        cmp    rdx, rax
        jge     .found

        ; increment counter
        inc    byte [rbp-16]
        jmp    .loop

    ; when a bigger element is found;
    .found:
        ; save the position of the bigger element
        mov    [rbp-8], rcx
    
        ; save the value of the bigger element to rax
        ; for the next comparision
        mov    rax, rdx

        ; increment counter
        inc    byte [rbp-16]
        
        jmp   .loop

    ; when the end of the array is reached
    .end_not_found:
        ; return the position of the biggest element
        mov    rax, [rbp-8]
        leave
        ret

selection_sort:
    push    rbp
    mov     rbp, rsp

    ; initialize the counter
    sub     rsp, 16 
    mov     qword [rbp-16], 0

    jmp    .loop

    ; loop through the array
    .loop:
        movzx  rcx, byte [rbp-16]

        ; check counter == len(lst)-1
        mov    rax, [len_lst]
        lea    rax, [rax-1]
        cmp    rcx, rax
        jge    .finish

        ; get the position of the biggest element in the array
        ; the couter is passed as an argument
        call    get_pos

        ; if current element is the biggest, skip
        cmp     rax, 0
        jg     .exchange

        ; exchange the current element with the biggest element
        .exchange:
            mov     rbx, [lst+rax*8]

            mov     rcx, [rbp-16]
            mov     rdx, [lst+rcx*8]
            
            mov     [lst+rax*8], rdx
            mov     [lst+rcx*8], rbx

        ; increment counter
        mov    rcx, [rbp-16]
        inc    byte [rbp-16]

        jmp    .loop

    ; exit function
    .finish:
        leave
        ret

print_list:
    push    rbp
    mov     rbp, rsp

    ; initialize the counter
    sub     rsp, 16
    mov     qword [rbp-16], 0

    jmp     .loop

    ; loop through the array
    .loop:
        ; loop condition
        movzx  rcx, byte [rbp-16]
        cmp    rcx, [len_lst]
        jge    .finish
        
        ; print the integer in a decimal formating with printf("%d\n")
        lea     rdi, [format_string]
        mov     rsi, [lst+rcx*8]
        xor     rax, rax
        call    printf

        ; increment counter
        inc     byte [rbp-16]
        jmp     .loop

    ; exit function
    .finish:
        leave
        ret

main:
    push    rbp
    mov     rbp, rsp
    
    ; sort the global array `lst`
    call    selection_sort

    ; print `lst` after sorting
    call    print_list
    
    ; exit
    mov     rdi, rax
    call    exit