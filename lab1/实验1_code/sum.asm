    .globl main

    .data

arrs: .word 9, 7, 15, 19, 20, 30, 11, 18
Result: .asciiz "The result is: "

    .text

sumn:
    # initialize
    addi $sp, -32
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    # a1 = arrs, a2 = n, a0被预留给syscall的服务号
    add $s0, $0, $a1 # s0 get arrs address
    add $s1, $0, $a2 # s1 get n
    li $v1, 0 # sum(v1) = 0， v0被预留给syscall访问
    li $t0, 0 # idx(t0) = 0

loop:
    bge $t0, $s1, done
    sll $t1, $t0, 2 # idx * 4, offset
    add $t2, $s0, $t1 # t2 is the address of arrs[idx]
    lw $t3, ($t2) # t3 = arrs[idx]
    add $v1, $v1, $t3 # sum += arrs[idx]
    addi $t0, $t0, 1  # idx += 1
    j loop

done:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, 12

    jr $ra

main:
    la $a1, arrs # a1 = *arrs
    li $a2, 8 # a2 = 8
    jal sumn # call sumn

    # print result message
    li $v0, 4 
    la $a0, Result
    syscall
    # print result
    li $v0, 1    
    add $a0, $0, $v1
    syscall
    # return 0
    li $v0, 10
    syscall