# by MaxXing

.data
prompt_a:
    .asciiz "input a: "
prompt_b:
    .asciiz "input b: "
prompt_plus:
    .asciiz "a + b = "

.text
main:
    la $a0, prompt_a
    jal print
    nop                         # delay slot, same as below
    li $v0, 5
    syscall
    move $t0, $v0

    la $a0, prompt_b
    jal print
    nop
    li $v0, 5
    syscall
    move $t1, $v0

    add $t2, $t0, $t1

    la $a0, prompt_plus
    jal print
    nop

    move $a0, $t2
    li $v0, 1
    jal newline
    syscall
    j exit

print:
    li $v0, 4
    jr $ra
    syscall

newline:
    li $a0, 10
    li $v0, 11
    jr $ra
    syscall

exit:
    li $v0, 10
    syscall
