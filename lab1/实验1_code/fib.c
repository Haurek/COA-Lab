#include<stdio.h>

int fib(int n)
{
    int first = 1;
    int second = 1;
    int third = 1;
    for (int i = 1; i < n; ++i)
    {
        third = first + second;
        first = second;
        second = third;
    }
    return third;
}

int main()
{
    int n;
    scanf("%d", &n);
    printf("%d", fib(n));
    return 0;
}