.data
    input1: .asciiz "Please enter a positive integer: "
    input2: .asciiz "Please enter another positive integer: "
    invalid: .asciiz "A negative integer is not allowed."
    blank: .asciiz "\n"
    multiple: .asciiz " * "
    exponent: .asciiz "^"
    equal: .asciiz " = "
    
    
.text
# let user input the first number and store this number to $s0 
#                                     store the second number to $s1
printMessage: 
    addi $t1, $zero, 0 # the product of the result 
    addi $t2, $zero, 0 # the exponent value for the result 
    addi $v0, $zero, 4  # print the input 1 message on the screen 
    la $a0, input1   
    syscall 
    addi $v0, $zero, 5  # read the input integer from the screen 
    syscall
    add $s0, $zero, $v0 # save the input number to $s0 
    add $s6, $zero, $s0
    slt $s2, $s0, $zero # set s1 = 1 if (s0<0)
    bne $s2, $zero, invalidMessage   # if s1 != 0, go to the InvalidMessage loop  
    beq $s2, $zero, calculateMessage 

invalidMessage: 
    addi $v0, $zero, 4
    la $a0, invalid
    syscall 
    addi $v0, $zero, 4
    la $a0, blank
    syscall 
    j printMessage 
 
calculateMessage: 
    addi $v0, $zero, 4
    la $a0, input2
    syscall
    addi $v0, $zero,5 # input an integer 
    syscall 
    add $s1, $zero, $v0
    add $s7, $zero, $s1
    add $s5, $zero, $s1
    
calculate: 
    beq $s1, $zero, printResult1
    andi $t0, $s1, 1 #get the LSB of the multiplier    
    bne $t0, 0, addToProduct # if the LSB is not 0, add to the product
    srl $s1, $s1, 1
    sll $s0, $s0, 1        
    

addToProduct: 
    add $t1, $t1, $s0
    srl $s1, $s1, 1
    sll $s0, $s0, 1
    j calculate 

resetvalue: 
    add $s0, $s6, $zero #reset the value
    add $s1, $s6, $zero

calculateExponential: 
    # add $s1, $s6, $zero
    beq $s1, $zero, loop  
    andi $t0, $s1, 1 #get the LSB of the multiplier    
    bne $t0, 0, addToProduct2 # if the LSB is not 0, add to the product
    srl $s1, $s1, 1
    sll $s0, $s0, 1

addToProduct2: 
    add $t2, $t2, $s0
    srl $s1, $s1, 1
    sll $s0, $s0, 1
    j calculateExponential

loop: 
    add $s0, $t2, $zero #set the mulpliant to the current value of t2
    add $s1, $s6, $zero # the value of s0 didn't change 
    subi $s5, $s5, 1
    beq $s5, 1, printResult2
    add $t2, $zero, $zero    
    j calculateExponential

             
printResult1:  
    addi $v0, $zero, 1 # print the integer on the screen 
    add $a0, $zero, $s6 
    syscall 
    add $v0, $zero, 4
    la $a0, multiple 
    syscall 
    addi $v0, $zero, 1
    add $a0, $zero, $s7
    syscall 
    addi $v0, $zero,4
    la $a0, equal 
    syscall 
    addi $v0, $zero, 1
    add $a0, $zero, $t1
    syscall 
    j resetvalue
    
printResult2:               
    addi $v0, $zero, 4
    la $a0, blank
    syscall 
    addi $v0, $zero, 1 # print the integer on the screen 
    add $a0, $zero, $s6 
    syscall 
    add $v0, $zero, 4
    la $a0, exponent
    syscall 
    addi $v0, $zero, 1
    add $a0, $zero, $s7
    syscall 
    addi $v0, $zero,4
    la $a0, equal 
    syscall 
    addi $v0, $zero, 1
    add $a0, $zero, $t2
    syscall 
    addi $v0, $zero, 10
    syscall 
    
    
 
    
    
    
    
    
    
    
    
    
    
