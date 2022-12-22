# Compiling `.asm`
e.g. `sort_arr.asm`:
`nasm -g -f elf64 -o sort_arr.o sort_arr.asm && gcc -g -o sort_arr sort_arr.o -no-pie`
