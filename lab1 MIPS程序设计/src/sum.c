#include <stdio.h>

int sumn(int *arrs, int n)
{
    int sum = 0;
    for (int idx = 0; idx < n; idx++)
        sum += arrs[idx];
    return sum;
}

int mian()
{
    int arrs[] = {9, 7, 15, 19, 20, 30, 11, 18};
    int N = 8;
    int result = sumn(arrs, N);
    printf("The result is: %d", result);

    return 0;
}
