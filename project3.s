
.data
    emptyInput: .asciiz "Input is empty." #message for string with an empty input
    longInput: .asciiz "Input it is too long." #prints out for string that has more than 4 characters
    invalidInput: .asciiz "Invalid base-32 number." #message for string that includes chars not in the range
    userInput: .space 1000


.text
    main:
        li $v0, 8 #syscall to read string
        la $a0, userInput #stores address of string
        li $a1, 9000 #allocate space for string input
        syscall
        add $t0, $0, 0 #initialize $t0 register
        add $t1, $0, 0 #initialize $t1 register

        la $t2, userInput
        lb $t0, 0($t2)
        beq $t0, 10, isEmpty #check for an empty string
        beq $t0, 0 isEmpty

        addi $s0, $0, 32 #store Base-32 number
        addi $t3, $0, 1 #iniialize new registers
        addi $t4, $0, 0
        addi $t5, $0, 0

        skipSpace:
            lb $t0, 0($t2) #load address in $t2 to $t0
            addi $t2, $t2, 1 #increase pointer
            addi $t1, $t1, 1 #increase counter
            beq $t0, 32, skipSpace #jump to skipSpace branch if equal
            beq $t0, 10, isEmpty #jump to isEmpty branch if equal
            beq $t0, $0, isEmpty #jump to isEmpty branch if equal

        viewChars:
            lb $t0, 0($t2)
            addi $t2, $t2, 1
            addi $t1, $t1, 1
            beq $t0, 10, goToBeg
            beq $t0, 0, goToBeg
            bne $t0, 32, viewChars

        leftover:
            lb $t0, 0($t2)
            addi $t2, $t2, 1
            addi $t1, $t1, 1
            beq $t0, 10, goToBeg
            beq $t0, 0, goToBeg
            bne $t0, 32, isInvalid #jump to isInvalid branch if not equal
            j leftover
        goToBeg:
            sub $t2, $t2, $t1 #goToBeg the pointer
            la $t1, 0 # counter restart
            
            continue:
            lb $t0, 0($t2)
            addi $t2, $t2, 1
            beq $t0, 32, continue
        addi $t2, $t2, -1
        
        
   recursion:
    sub $t2, $t2, $t1 #move ptr back to start of string
    addi $sp, $sp, -4 #allocating memory for stack
    sw $ra, 0($sp) #only return address
    move $a0, $t2
    li $a1, 4 # had to hard code this-- wont work for any other length unfortunately -- i tried
    li $a2, 1 #exponentiated base
    jal toDecimal #call to other recursive function
	j return 
    
   return: #print result
    move $a0, $v0
    li $v0, 1
    syscall
    
    lw $ra, 0($sp) 
    addi $sp, $sp, 4 #delete memory
    jr $ra

        end:
            move $a0, $t5 #move value to $a0
            li $v0, 1 #print value
            syscall
            li $v0, 10 #end program
            syscall

        isEmpty:
            la $a0, emptyInput #loads string/message
            li $v0, 4 #prints string
            syscall

            li $v0, 10 #end of program
            syscall

        isTooLong:
            la $a0, longInput #loads string/message
            li $v0, 4 #prints string
            syscall

            li $v0, 10 #end of program
            syscall

        isInvalid:
            la $a0, invalidInput #loads string/message
            li $v0, 4 #prints string
            syscall

            li $v0, 10 #end of program
            syscall

            jr $ra

  stringLength:
            lb $t0, ($t2)
            addi $t2, $t2, 1
            addi $t1, $t1, 1
            beq $t0, 10, recursion
            beq $t0, 0, recursion
            beq $t0, 32, recursion
            beq $t1, 5, isTooLong
            j stringLength
toDecimal:
    addi $sp, $sp, -8 #allocating memory for stack
    sw $ra, 0($sp) #storing return address
    sw $s3, 4($sp) #storing s register so it is not overwritten
    beq $a1, $0, return_zero #base case
    addi $a1, $a1, -1 #length - 1, so to start at end of string
    add $t0, $a0, $a1 #getting address of the last byte 
    lb $s3, 0($t0)  #loading the byte ^

    #asciiConversions:
            blt $s3, 48, isInvalid #if char is before 0 in ascii table, the input is invalid
            blt $s3, 58, number
            blt $s3, 65, isInvalid
            blt $s3, 87, upperCase
            blt $s3, 97, isInvalid
            blt $s3, 118, lowerCase
            blt $s3, 128, isInvalid

        upperCase:
            addi $s3, $s3, -55
            jal More

        lowerCase:
            addi $s3, $s3, -87
            jal More

        number:
            addi $s3, $s3, -48
            jal More
    #mul $s3, $s3, $a2 #multiplying the byte x the exponentiated base
    #mul $a2, $a2, 35 #multiplying the exoonentiated base by 35 to get next power
    More:
        mul $s3, $s3, $a2 #multiplying the byte x the exponentiated base 
        mul $a2, $a2, 32 #multiplying the exponentiated base by 32 to get next power 
        jal toDecimal
    # a0=str addr, a1=strlen, a2=exponentiated base
    
    #jal toDecimal #call function again (loop)
        add $v0, $s3, $v0   #returning last byte plus decimal version of the rest of number
        lw $ra, 0($sp)      
        lw $s3, 4($sp)
        addi $sp, $sp, 8
        jr $ra
return_zero:
    li $v0, 0
    lw $ra, 0($sp)
    lw $s3, 4($sp)
    addi $sp, $sp, 8
    jr $ra
   li $v0, 10
    syscall
