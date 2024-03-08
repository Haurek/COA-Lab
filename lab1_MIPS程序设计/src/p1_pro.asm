    .globl main

    .data

First:      .asciiz "Please enter 1st number:\n"
Second:     .asciiz "Please enter 2nd number:\n"
Result1:    .asciiz "The result of "
Result2:    .asciiz " & "
Result3:    .asciiz " is : "
Continue:   .asciiz "\nDo you want to try another?(0-continue/1-exit)\n"

    .text

main:

loop:
    # print "Please enter 1st number:\n"    
    li $v0, 4
    la $a0, First
    syscall 
    # read first num
    li $v0, 5
    syscall
    add $t2, $0, $v0
    # print "Please enter 2nd number:\n"
    li $v0, 4
    la $a0, Second
    syscall 
    # read second num
    li $v0, 5
    syscall
    add $t3, $0, $v0
    add $t4, $t2, $t3   #  t4 get t2 + t3
    # print "The result of "
    li $v0, 4
    la $a0, Result1
    syscall
    # print t2
    li $v0, 1
    add $a0, $0, $t2
    syscall
    # print " & "
    li $v0, 4
    la $a0, Result2
    syscall
    # print t3
    li $v0, 1
    add $a0, $0, $t3
    syscall 
    # print " is : "
    li $v0, 4
    la $a0, Result3
    syscall     
    # print sum
    li $v0, 1
    add $a0, $0, $t4
    syscall 
    # print "\nDo you want to try another?(0-continue/1-exit)\n"
    li $v0, 4
    la $a0, Continue
    syscall   
condition:    
    # read ans
    li $v0, 5
    syscall
    beq $v0, 0, loop
    beq $v0, 1, done
    j condition

done:
    li $v0, 10
    syscall