.data
    emptyInputMessage:	.asciiz "Input is empty."
    tooLongMessage: .asciiz "Input is too long."
    invalidBaseMessage:   .asciiz "Invalid base-34 number."
    userInput:		.space 90000
.text
 main:
	li $v0, 8       #Obtain user's input as text 
	la $a0, userInput
	li $a1, 90000
	syscall
	leadingSpaces:  #Remove leading spaces
	 li $t8, 32      #Save space character to t8
	 lb $t9, 0($a0)
	 beq $t8, $t9, deleteSpace
	 move $t9, $a0
	deleteSpace: #initialize label to get rid of beginning spaces
	 addi $a0, $a0, 1
	 j checkLength
	checkLength:   #find the length of the input
	 addi $t0, $t0, 0  #start count at zero
	 addi $t1, $t1, 10  #put character into t1
	 add $t4, $t4, $a0  #keep what was originally in a0
	lengthLoop:
	 lb $t2, 0($a0)   #Load the next character to t2
	 beqz $t2, endLoop   #End loop if null character is reached
	 beq $t2, $t1, endLoop   #End loop if end-of-line is detected
	 addi $a0, $a0, 1   #continue the string pointer
	 addi $t0, $t0, 1
	 j lengthLoop
	endLoop:
	 beqz $t0, emptyInput   #print empty input message if length is 0
	 slti $t3, $t0, 5      #check whether or not count is > 4
	 beqz $t3, tooLong #print out too long message if count > 4
	 move $a0, $t4
	 j isValid
	emptyInput:
	 li $v0, 4
	 la $a0, emptyInputMessage
	 syscall
	 j exit
	 tooLong:
	  li $v0, 4
	  la $a0, tooLongMessage
	  syscall
	  j exit
	 isValid:
	  lb $t5, 0($a0)
	  beqz $t5, setUp  #End loop if null character is reached
	  beq $t5, $t1, setUp  #End loop if end-of-line character is detected
	  slti $t6, $t5, 48    #Character is less than 0 (ascii value of 48)
	  bne $t6, $zero, invalidBase
	  slti $t6, $t5, 58    #Character is less than or = to 9 (ascii value of 57)
	  bne $t6, $zero, continue
	  slti $t6, $t5, 65    #Check if the character is less than A (ascii value of 65)
	  bne $t6, $zero, invalidBase
	  slti $t6, $t5, 87    #Check if the character is less than V(ascii value of 86)
	  bne $t6, $zero, continue
	  slti $t6, $t5, 97    #Check if the character is less than a(ascii value 97)
	  bne $t6, $zero, invalidBase
	  slti $t6, $t5, 118   #Check if the character is less than v(ascii value 118)
	  bne $t6, $zero, continue
	  bgt $t5, 118, invalidBase   #Check if the character is greater than x(ascii value 118)
	continue:
	  addi $a0, $a0, 1
	  j isValid
	invalidBase:
	  li $v0, 4
	  la $a0, invalidBaseMessage
	  syscall
	  j exit
	setUp:
	  move $a0, $t4
	  addi $t7, $t7, 0  #Initialize decimal sum to zero
	  add $s0, $s0, $t0
	  addi $s0, $s0, -1	
	  li $s3, 3 #position 3
	  li $s2, 2
	  li $s1, 1
	  li $s5, 0
	convertString:
	  lb $s4, 0($a0)
	  beqz $s4, displaySum
	  beq $s4, $t1, displaySum
	  slti $t6, $s4, 58
	  bne $t6, $zero, nums
	  slti $t6, $s4, 87
	  bne $t6, $zero, letters
	  slti $t6, $s4, 118
	  bne $t6, $zero, lowletters
	 nums:
	  addi $s4, $s4, -48
	  j nextStep
	 letters:
	  addi $s4, $s4, -55
	  j nextStep
	 lowletters:
	  addi $s4, $s4, -87
	 nextStep:
	  beq $s0, $s3, threePower
	  beq $s0, $s2, twoPower
	  beq $s0, $s1, onePower
	  beq $s0, $s5, zeroPower
	zeroPower:
	  li $s6, 1
	  mult $s4, $s6
	  mflo $s7
	  add $t7, $t7, $s7
	onePower:
	  li $s6, 32
	  mult $s4, $s6
	  mflo $s7
	  add $t7, $t7, $s7
	  addi $s0, $s0, -1
	  addi $a0, $a0, 1
	  j convertString
	twoPower:
	  li $s6, 1024
	  mult $s4, $s6
	  mflo $s7
	  add $t7, $t7, $s7
	  addi $s0, $s0, -1
	  addi $a0, $a0, 1
	  j convertString
	threePower:
	  li $s6, 32768 #32 to the 3rd power
	  mult $s4, $s6
	  mflo $s7
	  add $t7, $t7, $s7
	  addi $s0, $s0, -1
	  addi $a0, $a0, 1
	  j convertString
        displaySum:
	  li $v0, 1
	  move $a0, $t7
	  syscall
	exit:
	  li $v0, 10
	  syscall