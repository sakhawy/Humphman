#include <stdio.h>
#include <string.h>

int print_array(char chars[]);


int print_array(char chars[]) {
    for (int i = 0; i < strlen(chars); i++) {
        printf("%c", chars[i]);
    }
}

int main(){
    char hello_world[] = "Hello, world!";
    print_array(hello_world);
    return 0;
}