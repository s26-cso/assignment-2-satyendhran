#include <stdio.h>
#include <dlfcn.h>

int main(void) {
    char op[6];
    int num1, num2;

    while (scanf("%5s %d %d", op, &num1, &num2) == 3) {
        char libpath[16];
        snprintf(libpath, sizeof(libpath), "./lib%s.so", op);
        void *handle = dlopen(libpath, RTLD_LAZY);
        int (*fn)(int, int) = dlsym(handle, op);
        printf("%d\n", fn(num1, num2));
    }
    return 0;
}