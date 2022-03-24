	.data
outputArr: .space 40
tempArr: .space 40
fin: .asciiz "inputs.txt" #filename for input
sizeStr: .asciiz "--The size = "
buffer: .space 400
charzero: .ascii "0"
newLine: .ascii "\n"
comma: .ascii ","


	.text
main:
	#open a file for reading purpose
	li $v0, 13	# system call for open file
	la $a0, fin	# input file name
	li $a1, 0	# open for reading (flags are 0: read, 1: write)
	li $a2, 0	# mode is ignored
	syscall		# open a file (file descriptor returned in $v0)
	move $s6, $v0	# save the file descriptor
	
	# read entire content
	li $v0,14	# system call for read from file
	move $a0,$s6	# file descriptor
	la $a1,buffer	# address of buffer from which to read
	li $a2,100	# hardcoded maximum number of chars to read
	syscall		# read from file

	# close the file
	li $v0,16	# system call for close file
	move $a0,$s6	# file descriptor to close
	syscall		# close file
			
					
		
	and $s4,$s4,$zero # makes the array counter to 0
	lb $s7,comma	# load comma (',') to the $s7 register
	lb $s6,newLine	# load newLine ('\n') to the $s6 register
	lb $s5,charzero	# save '0' to the s5 register

	
	
	# converting the readed chars to corresponding integers
	li $t9,0			# index for buffer
	li $t4,0			# initialize digit counter(or reset)
readFileLoop:		
	
	lb $s1,buffer($t9)		# save the content of the buffer to the s1 register
	addi $t9,$t9,1			# increment the index of buffer by 1
	
	beq $s1,$s6,readFileExit 	# end loop when the newline('\n') found
	beq $s1,0,readFileExit 		# end loop when the null('\0') found

	beq $s1,$s7,commaFound 		# if( $s1 == ',') brach to the ifElse
	 
	addi $t4,$t4,1			# digit counter
	 
	sub $s1,$s1,$s5 		# convert char to int by substracting from '0'
	addi $sp,$sp,-4			# open space in the array
	sw $s1,0($sp)			# store the integer value to the array
	j readFileLoop
	
commaFound:		
	move $a0,$t4		# digit counter parameter for function
	jal calculateDigits	# perform the funciton call
	li $t4,0		# initialize digit counter(or reset)
	addi $s4,$s4,4 		# increase the array counter by 1 

	j readFileLoop		# jump to the loop

readFileExit:

	move $a0,$t4		# digit counter parameter for function
	li $t4,0		# initialize digit counter(or reset)
	jal calculateDigits	# perform the funciton call
	addi $s4,$s4,4 		# increase the array counter by 1 
	
	
	
	# calculating the address of the array
	add $t1,$s4,$sp		
	addi $t1,$t1,-4
	move $a0,$t1	# first function parameter -> array

	move $a1,$s4	# second function parameter -> size of array
	
	jal algorithmStart
	move $s7,$v0	# return value -> max length
	
	
	# printing the contents of the outputArr with comma between them
	li $t1,0
printStart:	
	beq $t1,$s7,printEnd
	lw $t2, outputArr($t1)
	
	li,$v0,1
	move $a0,$t2
	syscall
	li,$v0,4
	la $a0,comma
	syscall

	addi $t1,$t1,4
	j printStart
printEnd:
	
	# printing the sizeStr
	li $v0 4
	la $a0,sizeStr
	syscall
	
	div $s7,$s7,4	# divide max length to 4 in order to find correct size
	
	# printing the size
	li,$v0,1
	move $a0,$s7
	syscall
	
	add $sp,$s4,$sp		# reset the sp 

	li $v0,10		# system call for the exit from program
	syscall			# exit from program
	
	
###########################################

# This fucntion calculates digit the number which is in stack with the help given counter parameter

calculateDigits:

	li $t1,0	# loop counter
	li $t8,0	# the num will be calculated
findDigits:
	beq $t1,$a0,findDigitExit	# condition for ending loop
	addi $t1,$t1,1
	
	lw $t2,0($sp)
	addi $sp,$sp,4
	
	
	move $a1,$t1
	
	move $t5,$ra
	jal findPowOf10
	move $ra,$t5
	
	mul $t3,$v0,$t2
	add $t8,$t8,$t3
	
	j findDigits	
			
findDigitExit:
	
	addi $sp,$sp, -4
	sw $t8,0($sp)
	
	jr $ra	# return from funciton
#############################################
	
#############################################
# function that calculates digit number 
# returns 1 if the given parameter is 1
# returns 10 if the given parameter is 2
# returns 100 if the given paramters is 3 and keeps goes like this 
findPowOf10: 
	li $t7,1	# counter for loop
	li $t6,1	# temp variable for returning value
powof10:
	beq $t7,$a1,findPowOf10Exit	# if the counter equals given parameter end loop 
	mul $t6,$t6,10			# multiple number with 10 
	addi $t7,$t7,1			# increment counter by 1
	j powof10
	
findPowOf10Exit:
	move $v0, $t6	# return value
	jr $ra		# return from function 
#############################################


# fucntion for performs the desired algorithm
# paramters of function ---- a0 -> address of array a1- > size of array
# return statement ------ v0 -> size of maximum legth

# c form of function ----> int algorithm(int arr[], int size)
algorithmStart:

	addi $sp,$sp, -12	# make room on stack for 5 registers
	sw $ra,8($sp)		# save $ra on stack
	sw $s1,4($sp)		# save $s1 on stack
	sw $s0,0($sp)		# save $s2 on stack

	move $s0,$a0
	move $s1,$a1

	li $t0,0  # loop counter == i
	li $t1,0  # loop counter == j
	li $t2,0  # loop counter == k
	li $t3,0  # tempArr counter
	li $t4,0  # temp variable for accessing the array elements
	li $t5,0  # temp variable for accessing the array elements
	li $t6,0  # temp variable for maximum length


firstLoop:
	# for(i=0;i<size;i++)
	bge $t0,$s1,firstLoopEnd		# if (i < size)
	li $t3,0  				# tempArry counter
	sub $t4,$s0,$t0				# calculating index
	lw $t4,0($t4)				# arr[i]
	sw $t4,tempArr($t3)			# tempArr[tempArrCounter] = arr[i]
	addi $t3,$t3,4				# tempArrCounter = 1;
	
	
middleLoop:
	# for(j=i+1;j<size;j++)
	addi $t1,$t0,4	
middleLoopCondition:
	bge $t1,$s1,middleLoopEnd		# if (j < size)
					
innerLoop:
	# for(k=j+1;k<size;k++)
	addi $t2,$t1,4		
innerLoopCondition:	
	bge $t2,$s1,innerLoopEnd		# if (k < size)
	
	sub $t4,$s0,$t2				# calculating index
	lw $t4,0($t4)				# arr[k]
	
	addi $t9,$t3,-4  			# tempArry counter - 1
	lw $t5,tempArr($t9)			# tempArr[tempArrCounter] = arr[i]
	
	
	bge $t5,$t4,else			# if( tempArr[tempArrCounter-1] < arr[k]
	sw $t4,tempArr($t3)			# tempArr[tempArrCounter] = arr[i]
	addi $t3,$t3,4 				# increment tempArry counter
	
else:
	addi $t2,$t2,4				# increment k
	j innerLoopCondition
innerLoopEnd:
	
	li $t7,0				# temp counter for copy process
	# if( max < tempArr counter)
	bge $t6,$t3,notMaximum			
	move $t6,$t3				# save the max length
	
copyStart:
	# copy from tempArr to outputArr
	bge $t7,$t3,copyEnd
	lw $t4,tempArr($t7)
	sw $t4,outputArr($t7)
	addi $t7,$t7,4
	j copyStart
copyEnd:
			
notMaximum:
	

	addi $t1,$t1,4				# increment j
	j middleLoopCondition
middleLoopEnd:
	addi $t0,$t0,4				# increment i
	j firstLoop
firstLoopEnd:

	lw $s0,0($sp)		#restore $s0 from stack
	lw $s1,4($sp)		#restore $s1 from stack
	lw $ra,8($sp)		#restore $ra from stack
	addi $sp,$sp, 12	# restore the stack pointer
	

	move $v0,$t6		# return the lenght of the array
	jr $ra			# return from function



	
