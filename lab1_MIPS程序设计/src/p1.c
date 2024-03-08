#include <stdio.h>

int main()
{
    int t1, t2, sum;
    int t3;
    do
    {
        printf("Please enter 1st number:");
        scanf("%d", t1);
        printf("Please enter 2nd number:");
        scanf("%d", t2);
        sum = t1 + t2;
        printf("The result of %d & %d is : %d", t1, t2, sum);
        printf("Do you want to try another?(0-continue/1-exit)");
        scanf("%d", t3);
    } while (t3 == 0);
    return 0;
}