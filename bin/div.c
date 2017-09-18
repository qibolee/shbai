#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, const char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "%s div1 div2", argv[0]);
        return -1;
    }
    double a = atof(argv[1]);
    double b = atof(argv[2]);
    if (b == 0.0) {
        printf("-");
        return -1;
    }
    double c = a / b;
    if (argc == 4 && strcmp(argv[3], "%") == 0) {
        printf("%g%%", c * 100);
    } else {
        printf("%g", c);
    }
    return 0;
}
