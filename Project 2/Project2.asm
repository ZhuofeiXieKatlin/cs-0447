# Zhuofei Xie 
# Project 2 
.data
    board: .space 256
    colunm: .asciiz " column "
    colon: .asciiz ": "
    EmptyLine: .asciiz "\n"
    Number1: .asciiz "1"
    Number2: .asciiz "2"
    Number3: .asciiz "3"
    Number4: .asciiz "4"
    Number5: .asciiz "5"
    Number6: .asciiz "6"
    Number7: .asciiz "7"
    Number8:.asciiz "8"
    Blank:.asciiz "Nothing"
    Mine:   .asciiz "Mine"
    Left: .asciiz "Left-Click at row "
    Right: .asciiz "Right-Click at row "
        
    
.text 
# Part I: Randomly Place Mines
 
 # Initialize the game 


    addi $t9, $zero, 0x400a0808
wait: 
    beq $t9, $zero, wait
    beq $t9, 0x400a0808,generate10Mines
    beq $t9, 0x200a0808,generate10Mines
    beq $t9, 0x400F0c0c,generate15Mines
    beq $t9, 0x200F0c0c,generate15Mines
    beq $t9, 0x40141010,generate20Mines
    beq $t9, 0x20141010,generate20Mines
    add $t9, $zero, $zero
    j wait

waiting: 
    beq $t9, $zero, waiting
    beq $t9, 0x400a0808,wait
    beq $t9, 0x200a0808,wait
    beq $t9, 0x400F0c0c,wait
    beq $t9, 0x200F0c0c,wait
    beq $t9, 0x40141010,wait
    beq $t9, 0x20141010,wait
    bne $t9, $zero, Inputing
    add $t9, $zero, $zero
    j waiting

generate10Mines:    
    jal Initialize
    la   $s0, 0xffff8000		# Set $s0 to the address of the Minesweeper board
    addi $s1, $zero, 0          	# the counter 
    addi $s2, $zero, 10		        # Upper Bound 
    addi $s5, $zero, 64
    addi $t1, $t1, 64
    j clean

generate15Mines:    
    jal Initialize
    la   $s0, 0xffff8000		# Set $s0 to the address of the Minesweeper board
    addi $s1, $zero, 0          	# the counter 
    addi $s2, $zero, 15		        # Upper Bound 
    addi $s5, $zero, 144
    addi $t1, $t1, 144
    j clean


generate20Mines:    
    jal Initialize
    la   $s0, 0xffff8000		# Set $s0 to the address of the Minesweeper board
    addi $s1, $zero, 0          	# the counter 
    addi $s2, $zero, 20		        # Upper Bound 
    addi $s5, $zero, 256
    addi $t1, $t1, 256
    j clean
    
clean:      
    sb $0, 0($s0)
    sb $0, 0($t2)
    subi $t1, $t1, 1 
    addi $s0, $s0, 1
    addi $t2, $t2, 1
    bne $t1, $zero, clean
    j generateMinesPart2
    
generateMinesPart2: 
    la $s6, board
    addi $v0, $zero, 42 # Syscall 42: Random int range
    add $a0, $zero, $zero # Set RNG ID to 0 
    add $a1, $zero, $s5 # set upper bound to 10(exclusive) 
    syscall # Generate a random number and put it in $a0
    add $s4, $zero, $a0 # Copy the random number to $s4
    j generateMines

generateMines: 
    add $t1, $zero, $s4 
    la   $s0, 0xffff8000
    add $s0, $s0, $s4
    lb $t0, 0($s0)
    beq $t0, 0x0A, generateMinesPart2
    add $s6, $s6, $s4 
    sb $s3, 0($s6)
    sb $s3, 0($s0)
    addi $s1, $s1, 1
    bne $s1, $s2, generateMinesPart2
    #beq $s1, $s2, Initialize

InitializeCells: 
    la   $s0, 0xffff8000
    la $s6, board # the address for the board 
    beq $t9,0x400A0808, add64
    beq $t9,0x200A0808, add64
    beq $t9, 0x400F0c0c, add144
    beq $t9, 0x200F0c0c, add144
    beq $t9, 0x40141010, add256
    beq $t9, 0x20141010, add256

add64:
    addi $t7, $s6, 64
    addi $s1, $zero, 8
    addi $s2, $zero, 7
    addi $s3, $zero, 9 
    j placeNumbers

add144:
    addi $t7, $s6, 144
    addi $s1, $zero, 12
    addi $s2, $zero, 11
    addi $s3, $zero, 13
    j placeNumbers

add256:
    addi $t7, $s6, 256
    addi $s1, $zero, 16
    addi $s2, $zero, 15
    addi $s3, $zero, 17
    j placeNumbers

placeNumbers: 
    add $t6, $zero, $zero # number of mines around the cell 
    lb $t3, 0($s6) # the byte in the array 
    bgt $s6, $t7, UserInput
    beq $t3, 0x0a, increase_s6
    bne $t3, 0x0a, checkintheleft
checkintheleft: 
    addi $s4, $s6, 0
    andi $s4, $s4, 0xff
    div  $s4, $s1
    mfhi $s5
    beq $s5, $s2, ignoreright
    beq $s5, 0, ignoreleft
    j find3

ignoreleft: 
    addi $t4, $s6, 0 # let the $t4 == the current cell 
    sub $t4, $t4, $s1 # T
    lb $t5, 0($t4)    
    jal addNumber
    addi $t4, $s6, 0 # let the $t4 == the current cell 
    sub $t4, $t4,$s2 # TR
    lb $t5, 0($t4)    
    jal addNumber
    addi $t4, $s6, 0 # let the $t4 == the current cell 
    addi $t4, $t4,1 # R
    lb $t5, 0($t4)    
    jal addNumber
    addi $t4, $s6, 0 # let the $t4 == the current cell 
    add $t4, $t4,$s1 # D
    lb $t5, 0($t4)    
    jal addNumber
    addi $t4, $s6, 0 # let the $t4 == the current cell 
    add $t4, $t4,$s3 # DR
    lb $t5, 0($t4)    
    jal addNumber   
    
    lb $t6, 0($s6)
    beq $t6, $zero, placeBlank
    beq $t6, 1, placeNumber1
    beq $t6, 2, placeNumber2
    beq $t6, 3, placeNumber3
    beq $t6, 4, placeNumber4
    beq $t6, 5, placeNumber5
    beq $t6, 6, placeNumber6
    beq $t6, 7, placeNumber7
    beq $t6, 8, placeNumber8
    j placeNumbers

ignoreright: 
    addi $t4, $s6, 0 # let the $t4 == the current cell 
    sub $t4, $t4,$s1 # T
    lb $t5, 0($t4)    
    jal addNumber
    addi $t4, $s6, 0 # let the $t4 == the current cell
    sub $t4, $t4,$s3 # TL 
    lb $t5, 0($t4)    
    jal addNumber
    addi $t4, $s6, 0 # let the $t4 == the current cell 
    addi $t4, $t4,-1 # TL1
    lb $t5, 0($t4)    
    jal addNumber
    addi $t4, $s6, 0 # let the $t4 == the current cell 
    add $t4, $t4,$s2 # DL
    lb $t5, 0($t4)    
    jal addNumber
    addi $t4, $s6, 0 # let the $t4 == the current cell 
    add $t4, $t4,$s1 # D
    lb $t5, 0($t4)    
    jal addNumber
    
    lb $t6, 0($s6)
    beq $t6, $zero, placeBlank
    beq $t6, 1, placeNumber1
    beq $t6, 2, placeNumber2
    beq $t6, 3, placeNumber3
    beq $t6, 4, placeNumber4
    beq $t6, 5, placeNumber5
    beq $t6, 6, placeNumber6
    beq $t6, 7, placeNumber7
    beq $t6, 8, placeNumber8
    j placeNumbers
    
find3:
    addi $t4, $s6, 0 # let the $t4 == the current cell 
    sub $t4, $t4,$s3 # TL
    lb $t5, 0($t4)    
    jal addNumber
next1:  
    addi $t4, $s6, 0
    sub $t4, $t4, $s1 # T
    lb $t5, 0($t4)    
    jal addNumber
next2: 
    addi $t4, $s6, 0
    sub $t4, $t4, $s2 # TR
    lb $t5, 0($t4)    
    jal addNumber
next3: 
    addi $t4, $s6, 0
    addi $t4, $t4, -1 # L
    lb $t5, 0($t4)    
    jal addNumber
next4: 
    addi $t4, $s6, 0
    addi $t4, $t4, 1 # R
    lb $t5, 0($t4)    
    jal addNumber
next5: 
    addi $t4, $s6, 0
    add $t4, $t4, $s2 # DR
    lb $t5, 0($t4)    
    jal addNumber
next6: 
    addi $t4, $s6, 0
    add $t4, $t4, $s1 # D
    lb $t5, 0($t4)    
    jal addNumber
next7: 
    addi $t4, $s6, 0
    add $t4, $t4, $s3 # DR
    lb $t5, 0($t4)    
    jal addNumber
    
    lb $t6, 0($s6)
    beq $t6, $zero, placeBlank
    beq $t6, 1, placeNumber1
    beq $t6, 2, placeNumber2
    beq $t6, 3, placeNumber3
    beq $t6, 4, placeNumber4
    beq $t6, 5, placeNumber5
    beq $t6, 6, placeNumber6
    beq $t6, 7, placeNumber7
    beq $t6, 8, placeNumber8
    j placeNumbers
addNumber: 
   #addi $sp $sp, -4
   #sw $t6, 0($sp)
   bne $t5, 0x0a, notadd 
   lb $t6, 0($s6)
   add $t6, $t6, 1
   sb $t6, 0($s6)
   #lw $t6, 0($sp)
   #addi $sp, $sp, 4
   jr $ra

notadd: 
    jr $ra 
   
placeBlank: 
   addi $t1, $zero, 0x09
   sb $t1, 0($s6)
   sb $t1, 0($s0)
   addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber1: 
   addi $t1, $zero, 0x01
   sb $t1, 0($s6)
   sb $t1, 0($s0)
   addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber2: 
   addi $t1, $zero, 0x02
   sb $t1, 0($s6)
   sb $t1, 0($s0)
   addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber3: 
   addi $t1, $zero, 0x03
   sb $t1, 0($s6)
   sb $t1, 0($s0)
   addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber4: 
   addi $t1, $zero, 0x04
   sb $t1, 0($s6)
   sb $t1, 0($s0)
   addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers   

placeNumber5: 
   addi $t1, $zero, 0x05
   sb $t1, 0($s6)
   sb $t1, 0($s0)
   addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber6: 
   addi $t1, $zero, 0x06
   sb $t1, 0($s6)
   sb $t1, 0($s0)
   addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber7: 
   addi $t1, $zero, 0x07
   sb $t1, 0($s6)
   sb $t1, 0($s0)
   addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber8: 
   addi $t1, $zero, 0x08
   sb $t1, 0($s6)
   sb $t1, 0($s0)
   addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers
   
increase_s6:
   addi $s6, $s6, 1
   addi $s0, $s0, 1
   j placeNumbers


UserInput: 
   add $t9, $zero, $zero
   j waiting

Inputing: 
    andi $t8, $t9, 0xf000000
    jal printmessage1 
    andi $t8, $t9, 0x0000ff00
    srl $t8, $t8, 8
    add $s2, $t8, $zero # row number
    jal printmessage2
    andi $t8, $t9, 0xff
    add $s3, $t8, $zero # colomn number
    jal printmessage3
    add $t9, $zero, $zero
    jal printEmptyLine 
    j waiting
    

printmessage1:
    beq $t8, 0, printleft
    beq $t8, 0x08000000, printright
printleft: 
    li $v0, 4
    la $t8, Left
    add $a0, $t8, $zero
    syscall 
    jr $ra

printright: 
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $v0, 4
    la $t8, Right
    add $a0, $t8, $zero
    syscall 
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

printmessage2: 
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $v0, 1
    add $a0, $t8, $zero
    syscall 
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

printmessage3: 
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $v0, 4
    la $t7, colunm
    add $a0, $t7, $zero
    syscall
    li $v0, 1
    add $a0, $t8, $zero
    syscall
    li $v0, 4
    la $t7, colon 
    add $a0, $t7, $zero
    syscall 
    jal FigureOut
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

printEmptyLine: 
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $v0, 4
    la $t8, EmptyLine
    add $a0, $t8, $zero
    syscall 
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

FigureOut: 
    add $s4, $zero, $zero
    la $s6, board
    mul $s4, $s1, $s2
    add $s4, $s4, $s3
    add $s6, $s6, $s4 
    lb $s5, 0($s6)
    beq $s5, 0x01, printNumber1
    beq $s5, 0x02, printNumber2 
    beq $s5, 0x03, printNumber3 
    beq $s5, 0x04, printNumber4
    beq $s5, 0x05, printNumber5
    beq $s5, 0x06, printNumber6
    beq $s5, 0x07, printNumber7
    beq $s5, 0x08, printNumber8  
    beq $s5, 0x09, printNothing
    beq $s5, 0x0A, printNumberMine

printNumber1: 
    li $v0, 4
    la $t7, Number1
    add $a0, $t7, $zero
    syscall
    jr $ra

printNumber2: 
    li $v0, 4
    la $t7, Number2
    add $a0, $t7, $zero
    syscall
    jr $ra

printNumber3: 
    li $v0, 4
    la $t7, Number3
    add $a0, $t7, $zero
    syscall
    jr $ra

printNumber4: 
    li $v0, 4
    la $t7, Number4
    add $a0, $t7, $zero
    syscall
    jr $ra   

printNumber5: 
    li $v0, 4
    la $t7, Number5
    add $a0, $t7, $zero
    syscall
    jr $ra  

printNumber6: 
    li $v0, 4
    la $t7, Number6
    add $a0, $t7, $zero
    syscall
    jr $ra

printNumber7: 
    li $v0, 4
    la $t7, Number7
    add $a0, $t7, $zero
    syscall
    jr $ra

printNumber8: 
    li $v0, 4
    la $t7, Number8
    add $a0, $t7, $zero
    syscall
    jr $ra

printNothing: 
    li $v0, 4
    la $t7, Blank
    add $a0, $t7, $zero
    syscall
    jr $ra

printNumberMine: 
    li $v0, 4
    la $t7, Mine
    add $a0, $t7, $zero
    syscall
    jr $ra

Initialize: 
    la   $s0, 0xffff8000
    la $s6, board   #load the address of the board 
    add $t2, $s6, $zero   # add the address of the board to the $t2
    #add $t9, $zero, $zero 
    add $s1, $zero, $zero 
    add $s2, $zero, $zero  
    add $s4, $zero, $zero 
    add $t4, $zero, $zero
    add $t7, $zero, $zero 
    addi $s3, $zero, 0x0A  # the mines 
    jr $ra
   