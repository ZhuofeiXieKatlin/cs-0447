# Zhuofei Xie 
# Project 2 
.data
    board: .space 256
    s:.space 10
    BeginTheGame: .asciiz "\n Press Enter key to continue...  "
    winMessage: .asciiz " \n You Win !!!"
    OpenCell: .asciiz " \nNumber of open cells: "
    NumberofFlags: .asciiz "  Number of falgs: "
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
    bne $t9, $zero, findLOR
    add $t9, $zero, $zero
    j waiting

generate10Mines:    
    jal Initialize
    la   $s0, 0xffff8000		# Set $s0 to the address of the Minesweeper board
    la $s6, board 
    addi $s1, $zero, 0          	# the counter 
    addi $s2, $zero, 10		        # Upper Bound 
    addi $s5, $zero, 64
    addi $t1, $zero, 256
    j clean

generate15Mines:    
    jal Initialize
    la   $s0, 0xffff8000		# Set $s0 to the address of the Minesweeper board
    la $s6, board 
    addi $s1, $zero, 0          	# the counter 
    addi $s2, $zero, 15		        # Upper Bound 
    addi $s5, $zero, 144
    addi $t1, $zero, 256
    j clean


generate20Mines:    
    jal Initialize
    la   $s0, 0xffff8000		# Set $s0 to the address of the Minesweeper board
    la $s6, board 
    addi $s1, $zero, 0          	# the counter 
    addi $s2, $zero, 20		        # Upper Bound 
    addi $s5, $zero, 256
    addi $t1, $zero, 256
    j clean
    
clean:      
    sb $0, 0($s0)
    sb $0, 0($s6)
    #sb $0, 0($t2)
    subi $t1, $t1, 1 
    addi $s0, $s0, 1
    addi $s6, $s6, 1 
    #addi $t2, $t2, 1
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
    la   $s6, board
    add $s6, $s6, $s4
    lb $t0, 0($s6)
    beq $t0, 0x0A, generateMinesPart2
    sb $s3, 0($s6)
    addi $s1, $s1, 1
    bne $s1, $s2, generateMinesPart2
    #beq $s1, $s2, Initialize

InitializeCells: 
    #la   $s0, 0xffff8000
    la $s6, board # the address for the board 
    beq $t9,0x400A0808, add64
    beq $t9,0x200A0808, add64
    beq $t9, 0x400F0c0c, add144
    beq $t9, 0x200F0c0c, add144
    beq $t9, 0x40141010, add256
    beq $t9, 0x20141010, add256

add64:
    addi $t7, $s6, 63
    addi $s1, $zero, 8
    addi $s2, $zero, 7
    addi $s3, $zero, 9 
    j placeNumbers

add144:
    addi $t7, $s6, 143
    addi $s1, $zero, 12
    addi $s2, $zero, 11
    addi $s3, $zero, 13
    j placeNumbers

add256:
    addi $t7, $s6, 255
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
   #sb $t1, 0($s0)
   #addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber1: 
   addi $t1, $zero, 0x01
   sb $t1, 0($s6)
   #sb $t1, 0($s0)
   #addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber2: 
   addi $t1, $zero, 0x02
   sb $t1, 0($s6)
   #sb $t1, 0($s0)
   #addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber3: 
   addi $t1, $zero, 0x03
   sb $t1, 0($s6)
   #sb $t1, 0($s0)
   #addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber4: 
   addi $t1, $zero, 0x04
   sb $t1, 0($s6)
   #sb $t1, 0($s0)
   #addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers   

placeNumber5: 
   addi $t1, $zero, 0x05
   sb $t1, 0($s6)
   #sb $t1, 0($s0)
   #addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber6: 
   addi $t1, $zero, 0x06
   sb $t1, 0($s6)
   #sb $t1, 0($s0)
   #addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber7: 
   addi $t1, $zero, 0x07
   sb $t1, 0($s6)
   #sb $t1, 0($s0)
   #addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers

placeNumber8: 
   addi $t1, $zero, 0x08
   sb $t1, 0($s6)
   #sb $t1, 0($s0)
   #addi $s0, $s0, 1
   addi $s6, $s6, 1
   j placeNumbers
   
increase_s6:
   addi $s6, $s6, 1
   #addi $s0, $s0, 1
   j placeNumbers


UserInput: 
   add $t1, $zero, $zero
   la $s0, 0xffff8000
   la $s6, board
   jal copyboard 
   add $t9, $zero, $zero
   j BeginGame


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

copyboard:  
    lb $t2, 0($s6)
    sb $t2, 0($s0)
    addi $t1, $t1, 1
    addi $s6, $s6, 1
    addi $s0, $s0, 1
    bne $t1, 256,copyboard
    jr $ra
    
BeginGame: 
    la $v0, 4
    la $t1, BeginTheGame
    add $a0, $t1, $zero
    syscall 
    la $v0, 8 
    la $a0, s
    addi $a1, $zero,1 
    syscall 
    la $s0, 0xffff8000	
    add $t0, $zero, $zero
    j closeCell

closeCell: 
    sb $0, 0($s0)
    addi $t0, $t0, 1
    addi $s0, $s0, 1
    blt $t0, 256, closeCell
    jal CountingopenCells
    j waiting 

findLOR:
    andi $t8, $t9, 0xf000000
    andi $t7, $t9, 0x0000ff00
    srl $t7, $t7, 8
    add $s2, $t7, $zero # row number
    andi $t6, $t9, 0xff
    add $s3, $t6, $zero # colomn number
    add $s4, $zero, $zero
    la $s6, board
    la $s0, 0xffff8000	
    mul $s4, $s1, $s2
    add $s4, $s4, $s3   # the cell number
    add $s6, $s6, $s4 
    add $s0, $s0, $s4
    lb $s5, 0($s6)   # THE THING UNDER THIS CELL
    lb $t4, 0($s0)
    beq $t8, 0, left
    beq $t8, 0x08000000, right 
    
left: 
    la $s6, board 
    la $s0, 0xffff8000
    add $t0, $zero, $zero
    beq $t4, 0x0c, doNothing
    beq $s5, 0x0a, boom
    beq $s5, 0x09, CallMethodPrintRelated 
    j isNumber
    
CallMethodPrintRelated: 
    add $a0, $s4, $zero 
    jal PrintRelated
    jal CountingopenCells
    add $t9, $zero, $zero
    j waiting 
    
isNumber:   
    la $s0, 0xffff8000
    la $s6, board 
    add $t0, $s0, $s4      # in the game
    add $t1, $s6, $s4 	   # in the board 
    lb $t2, 0($t0)       # in the game
    lb $t3, 0($t1)       # in the board 
    beq $t2, 0x00, openItDirectly
    #beq $t2, $t3, gotoChecktheFlagAroundTheCell
    jal gotoChecktheFlagAroundTheCell
    jal CountingopenCells
    add $t9, $zero, $zero
    j waiting

openItDirectly: 
    sb $t3, 0($t0)
    jal CountingopenCells
    add $t9, $zero, $zero
    j waiting

gotoChecktheFlagAroundTheCell: 
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    bne $t2, $t3,goingBacktoTheMain
    add $s2, $s4, $zero 
    div $s2, $s1 
    mfhi $t8
    sub $t4, $s1, 1
    beq $t8, 0, ignoreleft3 
    beq $t8, $t4, ignoreright3 
    j openTheSurroundingCells 
    
goingBacktoTheMain: 
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra 
    
ignoreleft3: 
    add $t5, $zero, $zero 
    sub $t0, $t0, $s1   # T in the game 
    jal checkflag 
    addi $t0, $t0, 1 
    jal checkflag       # TR
    add $t0, $t0, $s1 
    jal checkflag 
    add $t0, $t0, $s1  # R
    jal checkflag 
    subi $t0, $t0, 1    # DR 
    jal checkflag 
    beq $t5, $zero, goingBacktoTheMain
    bne $t5, $t3, goingBacktoTheMain
    j openThem 
    
ignoreright3: 
    add $t5, $zero, $zero 
    sub $t0, $t0, $s1   # T in the game 
    jal checkflag 
    subi $t0, $t0, 1 
    jal checkflag       # TL
    add $t0, $t0, $s1 
    jal checkflag 
    add $t0, $t0, $s1  # L
    jal checkflag 
    addi $t0, $t0, 1    # D 
    jal checkflag 
    beq $t5, $zero, goingBacktoTheMain
    bne $t5, $t3, goingBacktoTheMain
    j openThem 
    
openTheSurroundingCells: 
    add $t5, $zero, $zero 
    sub $t0, $t0, $s1   # T in the game 
    jal checkflag 
    addi $t0, $t0, 1 
    jal checkflag       # TR
    add $t0, $t0, $s1 
    jal checkflag 
    add $t0, $t0, $s1  # R
    jal checkflag 
    subi $t0, $t0, 1 # D 
    jal checkflag 
    subi $t0, $t0, 1    # DR 
    jal checkflag 
    sub $t0, $t0, $s1	
    jal checkflag 
    sub $t0, $t0, $s1 
    jal checkflag 
    beq $t5, $zero, goingBacktoTheMain
    bne $t5, $t3, goingBacktoTheMain
    j openThem 
    
checkflag: 
    lb $t2, 0($t0)
    beq $t2, 0x0c, IncreaseNumber
    jr $ra 
IncreaseNumber: 
    addi $t5, $t5, 1  # t5 the number of flag around the cell
    jr $ra

openThem: 
    la $s0, 0xffff8000
    la $s6, board 
    add $t0, $s0, $s4
    add $t1, $s6, $s4
    # check in the corner or not  
    beq $t8, 0, ignoreleft4 
    beq $t8, $t4, ignoreright4 
    j openTheSurroundingCellsAgain  

ignoreleft4: 
    sub $t0, $t0, $s1   # T in the game 
    sub $t1, $t1, $s1
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    addi $t0, $t0, 1 
    addi $t1, $t1, 1
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow        # TR
    add $t0, $t0, $s1 
    add $t1, $t1, $s1 
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    add $t0, $t0, $s1  # R
    add $t1, $t1, $s1 
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    subi $t0, $t0, 1    # DR 
    subi $t1, $t1, 1
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    j goingBacktoTheMain

ignoreright4: 
    sub $t0, $t0, $s1   # T in the game 
    sub $t1, $t1, $s1
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    subi $t0, $t0, 1 
    subi $t1, $t1, 1
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow    #Tl
    add $t0, $t0, $s1 
    add $t1, $t1, $s1 
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    add $t0, $t0, $s1  # L
    add $t1, $t1, $s1 
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    addi $t0, $t0, 1    # D 
    addi $t1, $t1, 1
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    j goingBacktoTheMain

openTheSurroundingCellsAgain:
    sub $t0, $t0, $s1   # T in the game 
    sub $t1, $t1, $s1
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    addi $t0, $t0, 1 
    addi $t1, $t1, 1
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow
    add $t0, $t0, $s1 
    add $t1, $t1, $s1
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow  
    add $t0, $t0, $s1  # R
    add $t1, $t1, $s1 
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    subi $t0, $t0, 1    # DR 
    subi $t1, $t1, 1
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    subi $t0, $t0, 1
    subi $t1, $t1,1 
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    sub $t0, $t0, $s1
    sub $t1, $t1, $s1	
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    sub $t0, $t0, $s1 
    sub $t1, $t1, $s1
    lb $t3, 0($t0)
    lb $t4, 0($t1)
    addi $sp, $sp, -12  
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    jal openItNow 
    j goingBacktoTheMain

 
openItNow: 
    sw $ra, 0($sp)
    beq $t3, 0x0c, notOpen 
    beq $t4, 0x09,CallMethodPrintRelatedAgain
    beq $t4, 0x0a, BOOMWithWrongFlagInitial
    sb $t4, 0($t0)
    j notOpen
CallMethodPrintRelatedAgain: 
    andi $t1, $t1, 0xff
    add $a0, $t1, $zero 
    jal PrintRelated   
notOpen:  
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    addi $sp, $sp, 12
    jr $ra 

BOOMWithWrongFlagInitial:
    add $t6, $s6, $zero 
BOOMWithWrongFlag: 
    lb $t1, 0($t6)
    beq $t1, 0x0a, boomTheMine
    addi $t6, $t6, 1
    andi $t5, $t6, 0xfff
    beq $t5, 256, notOpen
    j BOOMWithWrongFlag
boomTheMine: 
    andi $t5, $t6, 0xff
    la $s0, 0xffff8000
    add $s0, $s0, $t5
    addi $t6, $t6, 1
    andi $t5, $t6, 0xff
    beq $t5, 256, notOpen
    sb $t1, 0($s0)
    j BOOMWithWrongFlag
 
PrintRelated:
    addi $sp, $sp, -12 
    sw $ra, 4($sp)
    add $s4, $a0, $zero 
    la $s0, 0xffff8000
    la $s6, board       # s4 is the cell nuumber 
    add $t0, $s4, $s0
    add $t1, $s4, $s6 # the cell number address 
    lb $s5, 0($t1)
    lb $t6, 0($t0)   
    add $s2, $s4, $zero   # check reminder
    div  $s2, $s1
    mfhi $t8
    
    beq $t6, 0x09, jumpback  
    bne $s5, 0x09, EnterANumber
    
    sb $s5, 0($t0)
    
    sw $s4, 0($sp)
    sw $t8, 8($sp)
    sub $s4, $s4, $s1               # -8
    add $a0, $s4, $zero
    jal PrintRelated
    lw $s4, 0($sp) 
    lw $t8, 8($sp)
    
    sw $s4, 0($sp)
    sw $t8, 8($sp)
    add $s4, $s4, $s1             #+8
    add $a0, $s4, $zero
    jal PrintRelated
    lw $s4, 0($sp)
    lw $t8, 8($sp)
    

    beq $t8, 0, ignoreleft2
    
    sw $s4, 0($sp)
    sw $t8, 8($sp)
    addi $s1, $s1, 1                # -9
    sub $s4, $s4, $s1
    subi $s1, $s1, 1 
    add $a0, $s4, $zero
    jal PrintRelated
    lw $s4, 0($sp)
    lw $t8, 8($sp)
     
    sw $s4, 0($sp)
    sw $t8, 8($sp) 
    subi $s4, $s4, 1 
    add $a0, $s4, $zero
    jal PrintRelated                # -1
    lw $s4, 0($sp)
    lw $t8, 8($sp)
    
    sw $s4, 0($sp)
    sw $t8, 8($sp)
    subi $s1, $s1, 1
    add $s4, $s4, $s1          #+7
    addi $s1, $s1, 1
    add $a0, $s4, $zero
    jal PrintRelated
    lw $s4, 0($sp)
    lw $t8, 8($sp)
 
    subi $t0, $s1, 1
    beq $t8, $t0, jumpback
    
ignoreleft2: 
    sw $s4, 0($sp)
    sw $t8, 8($sp)
    subi $s1, $s1, 1
    sub $s4, $s4, $s1            # -7
    addi $s1, $s1, 1
    add $a0, $s4, $zero
    jal PrintRelated
    lw $s4, 0($sp)
    lw $t8, 8($sp)

    sw $s4, 0($sp)
    sw $t8, 8($sp)
    add $s4, $s4, 1            # +1 
    add $a0, $s4, $zero
    jal PrintRelated
    lw $s4, 0($sp)
    lw $t8, 8($sp)
    
    
    sw $s4, 0($sp)
    sw $t8, 8($sp)
    addi $s1, $s1, 1 
    add $s4, $s4, $s1            #+9
    subi $s1, $s1, 1 
    add $a0, $s4, $zero
    jal PrintRelated
    lw $s4, 0($sp) 
    lw $t8, 8($sp)
    

EnterANumber: 
    sb $s5, 0($t0)
    #lw $ra, 0($sp)
    #addi $sp, $zero, 4 
jumpback: 
    lw $ra, 4($sp) 
    addi $sp, $sp, 12 
    jr $ra      
 
boom: 
    lb $t4, 0($s6)
    addi $t1,$zero, 0x0a
    addi $t2, $zero, 0x0d
    beq $t4, 0x0a, displaymine
    addi $t0, $t0, 1
    addi $s6, $s6, 1
    beq $t0, 256, gotowaiting 
    bne $t4, 0x0a, boom

displaymine: 
    beq $t0, $s4, boomMine
    la $s0, 0xffff8000
    add $s0, $s0, $t0
    sb $t1, 0($s0)
    addi $t0, $t0, 1
    addi $s6, $s6, 1
    beq $t0, 256, gotowaiting 
    j boom

boomMine: 
    la $s0, 0xffff8000
    add $s0, $s0, $t0
    sb $t2, 0($s0)
    addi $t0, $t0, 1
    addi $s6, $s6, 1 
    beq $t0, 256, gotowaiting 
    j boom

gotowaiting: 
    jal CountingopenCells
    add $t9, $zero, $zero
    j waiting 
    
doNothing: 
    jal CountingopenCells
    add $t9, $zero, $zero
    j waiting 


right: 
    addi $t0, $zero, 0x0c
    la $s0, 0xffff8000	
    add $s0, $s0, $s4
    lb $s5, 0($s0)
    beq $s5, 0x0c, removeflag
    bne $s5, 0x00, GotoWaitting
    sb $t0, 0($s0)
    jal CountingopenCells
    add $t9, $zero, $zero
    j waiting 
removeflag: 
    addi $t0, $zero, 0x00
    la $s0, 0xffff8000	
    add $s0, $s0, $s4
    sb $t0, 0($s0)
    jal CountingopenCells
    add $t9, $zero, $zero
    j waiting 

GotoWaitting: 
    jal CountingopenCells
    add $t9, $zero, $zero
    j waiting

CountingopenCells: 
    la $s0, 0xffff8000
    add $t0, $zero, $zero    # number of open cells 
    add $t1, $zero, $zero    # number of flags 
    add $t3, $s0, $zero      # the copy of the address of the game 
    add $t4, $zero, $zero    # the counter 
checkNumberopenandflag: 
    lb $t5, 0($t3)
    bne $t5, 0x00, IncreasetheNumberforflagoropenCell
    addi $t3, $t3, 1 
    addi $t4, $t4, 1
    bgt $t4, 256, GoHome
    j checkNumberopenandflag
    
IncreasetheNumberforflagoropenCell: 
    beq $t5, 0x0c, IncreaseTheNumberOfFlag
    addi $t3, $t3, 1 
    addi $t0, $t0, 1
    addi $t4, $t4, 1
    bgt $t4, 256, GoHome
    j checkNumberopenandflag
IncreaseTheNumberOfFlag: 
    addi $t1, $t1, 1 
    addi $t3, $t3, 1
    addi $t4, $t4, 1 
    bgt $t4, 256, checkWinORNotInitial
    j checkNumberopenandflag
    
GoHome: 
    addi $v0, $zero, 4
    la $a0, OpenCell
    syscall 
    addi $v0, $zero, 1
    add $a0, $t0, $zero
    syscall 
    addi $v0, $zero, 4
    la $a0, NumberofFlags
    syscall 
    addi $v0, $zero, 1
    add $a0, $t1, $zero
    syscall 
    j checkWinORNotInitial

checkWinORNotInitial: 
    la $s0, 0xffff8000
    add $t0, $s0, $zero
    add $t1, $zero, $zero
    la $s6, board 
    add $t7, $s6, $zero
checkWinORNot: 
    lb $t2, 0($t0)
    lb $t3, 0($t7)
    beq $t3, 0x00, finish
    beq $t2, 0x00, GOingBACK
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    addi $t7, $t7, 1
    beq $t7, 0x00, finish
    j checkWinORNot
finish:     
    addi $v0, $zero, 4
    la $a0, winMessage
    syscall 
    j GOingBACK

GOingBACK: 
    jr $ra 