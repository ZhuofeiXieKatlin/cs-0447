.data 
    msg1: .asciiz "Enter a number between 0 and 9: "
    msg2: .asciiz "Your guess is too low "
    msg3: .asciiz "Your guess is too high"
    msg4: .asciiz "You lose. The number was "
    msg5: .asciiz "Congratulation! You win!"
    msg6: .asciiz "\n"
.text  
# generate a random number
    addi $v0, $zero, 42 # Syscall 42: Random int range
    add $a0, $zero, $zero # Set RNG ID to 0 
    addi $a1, $zero,10 # set upper bound to 10(exclusive) 
    syscall # Generate a random number and put it in $a0
    add $s1, $zero, $a0 # Copy the random number to $s1
# generate a varibale and set to the run times 
    addi $s2, $zero, 3
     
#j main # jump to the main method 
main: 
    beq  $s2, $zero, lose # to check if we finish all tries 
    
    addi $v0, $zero, 4 
    la $a0, msg1 # print out the message in the window "4"
    syscall 
    addi $v0, $zero, 5 # enter an integer in the screen by "5"
    syscall 
    add $s0, $zero, $v0 # set the value of input to $s0           
    
    beq $s1, $s0, done #if the number is equal to the random number, the program is finished
    bne $s1, $s0, find 
            
find:      
     slt $t0, $s0, $s1 #set t0 = 1, if s0<s1
     beq $t0, $zero, high 
     bne $t0, $zero, low 
     
     high: 
         addi $s2, $s2, -1
         addi $v0, $zero, 4 # if the guess is too high, print out the too high message 
         la $a0, msg3
         syscall  
         addi $v0, $zero, 4
         la $a0, msg6
         syscall
         j main 
        
     low: 
         addi $s2, $s2, -1
         addi $v0, $zero, 4
         la $a0, msg2
         syscall 
         addi $v0, $zero, 4
         la $a0, msg6
         syscall
         j main
         
lose: 
    addi $v0, $zero, 4
    la $a0, msg4 
    syscall 
    addi $v0, $zero, 1
    add $a0, $zero, $s1
    syscall
    addi $v0, $zero, 10 # end the project 
    syscall 
            
done: 
     addi $v0, $zero, 4
     la $a0, msg5
     syscall 
     addi $v0, $zero, 10 # end the project 
     syscall 
     
    
    
    
