.data 
    mainmenu: .asciiz "Main Menu"
    slash:    .asciiz "========="
    message1: .asciiz "  1. String to Morse Code"
    message2: .asciiz "  2. Morse code to string"
    message3: .asciiz "  3. Exit program"
    output:  .asciiz "What do you want to do? (1 or 3): "
    invalid: .asciiz "Invalid option"
    emptyline: .asciiz "\n"
    enterAString: .asciiz "Please enter a string: "
    enterAMorse: .asciiz "Please enter a morse code: "
    Stringarray: .byte 'A','B','C', 'D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'
    MorseArray: .ascii   ".-  ", "-...","-.-.","-.. ",".   ","..-.","--. ","....","..  ",".---","-.- ",".-..","--  ","-.  ","--- ",".--.","--.-",".-. ","... ","-   ","..- ","...-",".-- ","-..-","-.--","--.."
    Stringarray2: .byte '\n','\n','E','T','I','A','N','M','S','U','R','W','D','K','G','O','H','V','F','\n','L','\n','P','J','B','X','C','Y','Z','Q','\n','\n'
    String: .space 20
    tansfer: .space 20
    Morse: .space 40
    emptyspace: .asciiz " "
    
.text  
j printMenu
cleardata: 
    add $t0, $zero, $zero
    add $t1, $zero, $zero
    add $s1, $zero, $zero
    add $s1, $zero, $zero
    addi $v0,$zero,4
    la $a0, emptyline
    syscall
    j printMenu
printMenu: 
    addi $v0, $zero, 4
    la $a0, mainmenu 
    syscall 
    la $a0, emptyline
    syscall  
    la $a0, slash
    syscall 
    la $a0, emptyline
    syscall 
    la $a0, message1 
    syscall 
    la $a0, emptyline
    syscall 
    la $a0, message2
    syscall 
    la $a0, emptyline
    syscall 
    la $a0, message3
    syscall 
    la $a0, emptyline
    syscall 
    la $a0, output
    syscall 
    addi $v0, $zero, 5  # read the input integer from the screen 
    syscall
    add $s0, $zero, $v0 # save the input number to $s0 
    
    beq $s0, 1, StringtoMorse
    beq $s0, 2, MorsetpString
    beq $s0, 3, done 
    j invalidOption

StringtoMorse: 
    addi $v0, $zero, 4   
    la $a0, enterAString     # enter a string 
    syscall 
    addi $v0, $zero,8 #let the user input a string 
    la $a0, String 
    li $a1, 60
    syscall  
    la $s0, MorseArray # $s0 = the address of the morse array
    la $s1, String # $s1 = the address of a string    

loop: 
    add $t3,$zero, $zero
    add $t1, $zero, $zero
    lbu $t0, 0($s1) #load the first byte of the String
    blt $t0,32, cleardata # clear the data after finishing the string morse conversion
    bgt $t0,96,change # we need to change the lowercase letter to uppercase 
    subi $t1,$t0,65      #t0=the adress of the word
    sll $t1,$t1,2        # address = (word - 65)*4 + $s0
    add $t1,$s0,$t1
    addi $s1, $s1,1

print: 
    add $t3, $t3, $zero
    beq $t0, 32, printspace
    lb $t2, 0($t1)
    beq $t2, 32, printspace
    beq $t3,4,printspace
    addi $v0, $zero,11
    lb $a0, 0($t1)
    syscall 
    addi $t1, $t1, 1
    addi $t3, $t3,1
    j print

printspace: 
    addi $v0, $zero,4
    la $a0, emptyspace
    syscall 
    j loop    
    
change: 
    subi $t1, $t0, 97
    sll $t1,$t1,2
    add $t1,$s0,$t1
    addi $s1, $s1,1 #increment the size 
    j print
       
    
MorsetpString: 
    addi $v0, $zero, 4
    la $a0, enterAMorse      # enter a morse
    syscall 
    addi $v0, $zero,8 #let the user input a morse
    la $a0, Morse
    li $a1, 60
    syscall  
    
    la $s0, Morse #load the address of the entered Morse code
    la $s1, Stringarray2 #load the adress of the string array
    addi $t1, $zero, 1

loop2: 
    lb $t0, 0($s0) #load the byte of the morse array
    add $t8, $s0, $zero
    subi $t8, $t8,1
    lb $t9, 0($t8)
    beq $t0, 32, checkspace
   
    beq $t0,32, print2 # if the index is null stop the code
    beq $t0,10,print2
    beq $t0, 46, double
    beq $t0, 45, doubleplus
    j print 

checkspace: 
    beq $t0, $t9, printspace2
    j print2
        
double: 
    sll $t1, $t1,1 #double the index of the array
    addi $s0, $s0,1 # increment the index 
    j loop2 # going back to the loop
    
doubleplus: 
    sll  $t1,$t1, 1 #double the index of the array then plus 1
    addi $s0, $s0,1 #increment the index 
    addi $t1, $t1, 1
    j loop2 # going back to the loop

print2: 
    add $t1, $s1, $t1
    addi $v0, $zero,11
    lb $a0, 0($t1)
    syscall 
    beq $t0,10,cleardata
    addi $t1, $zero, 1
    add $s0, $s0, 1
    j loop2

printspace2: 
    addi $v0, $zero,4
    la $a0, emptyspace
    syscall 
    add $s0, $s0, 1
    addi $t1, $zero, 1
    j loop2

invalidOption:  
    addi $v0, $zero, 4
    la $a0, invalid
    syscall
    addi $v0, $zero,4
    la $a0, emptyline
    syscall 
    j printMenu
    
done: 
    addi $v0, $zero, 10
    syscall 
