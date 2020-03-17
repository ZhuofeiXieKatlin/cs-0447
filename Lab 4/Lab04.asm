.data
	numString:	.asciiz	"How many strings do you have?: "
	enterString:	.asciiz	"Please enter a string: "
	theString1:	.asciiz	"The string at index "
	theString2:	.asciiz	" is \""
	theString3:	.asciiz "\"\n"
	result1:	.asciiz "The index of the string \""
	result2:	.asciiz "\" is "
	result3:	.asciiz	".\n"
	notFound1:	.asciiz	"Could not find the string \""
	notFound2:	.asciiz "\".\n"
	buffer:	.space	100
.text
	# Ask for the number of strings
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, numString		# Set the string to print to numString
	syscall				# Print "How many..."
	addi $v0, $zero, 5		# Syscall 5: Read integer
	syscall				# Read integer
	add  $s0, $zero, $v0		# $s0 is the number of strings
	# Allocate memory for an array of strings
	addi $v0, $zero, 9		# Syscall 9: Allocate memory
	sll  $a0, $s0, 2		# number of bytes = number of strings * 4
	syscall				# Allocate memeory
	add  $s1, $zero, $v0		# $s1 is the address of the array of strings
	# Loop n times reading strings
	add  $s2, $zero, $zero		# $s2 counter (0)
	add  $s3, $zero, $s1		# $s3 is the temporary address of the array of strings
readStringLoop:
	beq  $s2, $s0, readStringDone	# Check whether $s2 == number of strings
	add  $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, enterString		# Set the string to print to enterString
	syscall				# Print "Please enter..."
	jal  _readString		# Call _readString function
	sw   $v0, 0($s3)		# Store the address of a string into the array of strings
	addi $s3, $s3, 4		# Increase the address of the array of strings by 4 (next element)
	addi $s2, $s2, 1		# Increase the counter by 1
	j    readStringLoop		# Go back to readStringLoop
readStringDone:
	# Print all strings
	add  $s2, $zero, $zero		# $s2 - counter (0)
	add  $s3, $zero, $s1		# $s3 is the temporary address of the array of strings
printStringLoop:
	beq  $s2, $s0, printStringDone	# Check whether $s2 == number of strings
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, theString1		# Set the string to print to theString1
	syscall				# Print "The string..."
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s2		# Set the integer to print to counter (index)
	syscall				# Print the current index
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, theString2		# Set the address of the string to print to theString2
	syscall				# Print " is ""
	lw   $a0, 0($s3)		# Set the address by loading the address from the array of string
	syscall				# Print the string
	la   $a0, theString3		# Set the address of the string to print to theString3
	syscall				# Print ""\n"
	addi $s3, $s3, 4		# Increase the address of the array of string by 4 (next element)
	addi $s2, $s2, 1		# Increase the counter by 1
	j    printStringLoop		# Go back to printStringLoop
printStringDone:
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, enterString		# Set the address of the string to print to enterString
	syscall				# Print "Please enter..."
	jal  _readString			# Call the _readString function
	add  $s4, $zero, $v0		# $s4 is the address of a new string
	# Search for the index of a given string
	add  $s2 $zero, $zero		# $s2 - counter (0)
	add  $s3, $zero, $s1		# $s3 is the temporary address of the array of strings
	addi $s5, $zero, -1		# Set the initial result to -1
searchStringLoop:
	beq  $s2, $s0, searchStringDone	# Check whether $s2 == number of strings
	lw   $a0, 0($s3)		# $a0 is a string in the array of strings
	add  $a1, $zero, $s4		# $s1 is a string the a user just entered
	jal  _strCompare		# Call the _strCompare function
	beq  $v0, $zero, found		# Check whether the result is 0 (found)
	addi $s3, $s3, 4		# Increase the address by 4 (next element)
	addi $s2, $s2, 1		# Increase the counter by 1
	j    searchStringLoop		# Go back to searchStringLoop
found:
	add  $s5, $zero, $s2		# Set the result to counter
	# Print result
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, result1		# Set the address of the string to print to result1
	syscall				# Print "The index ..."
	add  $a0, $zero, $s4		# Set the address of the string to print to the string that a user jsut entered
	syscall				# Print the string that a user just entered
	la   $a0, result2		# Set the address of the string to print to result2
	syscall				# Print " is "
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s5		# Set the integer to print
	syscall				# Print index
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, result3		# Set the address of the string to print to result3
	syscall				# Print ".\n"
	j    terminate
searchStringDone:
	# Not found
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, notFound1		# Set the address of the string to print to notFound1
	syscall				# Print "Could not..."
	add  $a0, $zero, $s4		# Set the address of the string to print to a new string
	syscall				# Print the new string
	la   $a0, notFound2		# Set the address of the string to print to notFound2
	syscall
terminate:
	addi $v0, $zero, 10		# Syscall 10: Terminate Program
	syscall				# Terminate Program

# _readString
#
# Read a string from keyboard input using syscall # 8 where '\n' at
# the end will be eliminated. The input string will be stored in
# heap where a small region of memory has been allocated. The address
# of that memory is returned.
#
# Argument:
#   - None
# Return Value
#   - $v0: An address (in heap) of an input string
_readString:
    addi $sp, $sp, -24
    sw $s4, 20($sp)
    sw $s0, 16($sp)  # the address of the input string
    sw $s1, 12($sp)  # the count vatriable (remove linefeed)
    sw $s2, 8($sp)   # the byte of the input string 
    sw $s3, 4($sp)   # the length of the string  
    sw $ra, 0($sp)
    
    addi $v0, $zero, 8
    la $a0, buffer  
    add $s4, $zero, $a0 # s4 = the address of the buffer 
    li $a1, 100     # (1) read a string from the keyboard input using the system call number 8 
    syscall 
    add $s0, $zero, $a0 # s4 = the address of the buffer 
    add $s1, $zero, $zero # the counter     
    #(2) get fid of the line feed character at the end
linefeed: 
    lb $s2, 0($s0) # load byte of the input string 
    beq $s2, 10, change 
    addi $s0, $s0, 1
    j linefeed  
    
change: 
    sb $zero, 0($s0)
    add $s3, $zero, $zero
    jal _strLength 
    add $s3, $zero, $v0 # add the length of the string to $s3
    # (3) allocate a region in heap for storing this input string
    addi $v0, $zero, 9 
    add $a0, $s3, $zero 
    syscall 
    add $a0, $zero, $v0 # the memory address of the input string ----> destination 
    add $a1, $zero, $s4 # the temporary address of the string ----> source
    jal _strCopy
    add $v0, $a0, $zero #return the address 
    
    lw $s4, 20($sp)
    lw $s0, 16($sp)
    lw $s1, 12($sp)
    lw $s2, 8($sp)
    lw $s3, 4($sp)
    lw $ra, 0($sp)
    addi $sp, $sp, 24
    jr $ra
    
    
    
    
    
   
# _strCompare
#
# Compare two null-terminated strings. If both strings are idendical,
# 0 will be returned. Otherwise, -1 will be returned.
#
# Arguments:
#   - $a0: an address of the first null-terminated string
#   - $a1: an address of the second null-terminated string
# Return Value
#   - $v0: 0 if both string are identical. Otherwise, -1
_strCompare:
    add $t2, $a0, $zero #destination adress
    add $t3, $a1, $zero #source address 
loop: 
    lb $t0, 0($t2) 
    lb $t1, 0($t3)
    addi $t2, $t2, 1
    addi $t3, $t3, 1 # increment the address 
    bne $t0, $t1, finish
    beq $t0, $zero, done
    j loop

done: 
    add $v0, $zero, $zero
    jr $ra
finish: 
    subi $v0, $zero, 1
    jr   $ra

# _strCopy
#
# Copy from a source string to a destination.
#
# Arguments:
#   - $a0: An address of a destination
#   - $a1: An address of a source
# Return Value:
#   None
_strCopy:
    # WE CANNOT CHANGE THE a1 a2 VALUES IN THIS PART
    add $t7, $zero, $a1
    add $t8, $zero, $a0
loop2: 
    lb $t0, 0($t7) # load byte from the source code 
    sb $t0, 0($t8) #store byte from the source to the destination code 
    addi $t7, $t7, 1
    addi $t8, $t8, 1 # increase both size 
    bne $t0, $zero, loop2
    jr $ra 
	

# _strLength
#
# Measure the length of a null-terminated input string (number of characters).
#
# Argument:
#   - $a0: An address of a null-terminated string
# Return Value:
#   - $v0: An integer represents the length of the given string
_strLength:
    add $t0, $zero, $a0  # add the address of the string to the $t0
    addi $t1, $zero, 0     # t1 indicates the length of the string 
loop3: 
    lb $t2, 0($t0)
    beqz $t2, finish2 
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j loop3 
finish2: 
    add $v0, $zero, $t1
    jr $ra