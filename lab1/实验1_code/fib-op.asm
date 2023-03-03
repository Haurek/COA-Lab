## main--
## Registers used:
## $v0 - syscall parameter and return value.
## $a0 - syscall parameter-- the string to print.
        .text
main:
    subu $sp, $sp, 32 # Set up main’s stack frame:
    sw $ra, 28($sp)
    sw $fp, 24($sp)
    addu $fp, $sp, 32

    ## Get n from the user, put into $a0.
    li $v0, 5 # load syscall read_int into $v0.
    syscall # make the syscall.
    move $a0, $v0 # move the number read into $a0.
    jal fib # call fib.

    move $a0, $v0
    li $v0, 1 # load syscall print_int into $v0.
    syscall # make the syscall.

    la $a0, newline
    li $v0, 4
    syscall # make the syscall.

    li $v0, 10 # 10 is the exit syscall.
    syscall # do the syscall.

## fib--
## Registers used:
## $a0 - initially n.
## $t0 - index.
## $t1 - fib (n - 1).
## $t2 - fib (n - 2).
        .text
fib:
    li $t1, 1   # fib(n-1) = 1
    li $t2, 1   # fib(n-2) = 1
    li $v0, 1   # return value initialize
    li $t0, 2   # index = 1
loop:
    bgt $t0, $a0, done  # if index > n
    add $v0, $t1, $t2   # v0 = fib(n-1) + fib(n-2)
    move $t1, $t2       # fib(n-1) = fib(n-2)
    move $t2, $v0       # fib(n-2) = fib(n)
    addi $t0, 1         # index++
    j loop

done:
    jr $ra

        .data
newline: .asciiz "\n"