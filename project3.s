
.data
    emptyInput: .asciiz "Input is empty." #message for string with an empty input
    longInput: .asciiz "Input it is too long." #messgae for string that has more than 4 characters
    invalidInput: .asciiz "Invalid base-32 number." #message for string that includes one or more characters not in set
    userInput: .space 1000


.text
    main:
        li $v0, 8 #syscall to read string
        la $a0, userInput #stores address of string
        li $a1, 9000 #create ample space for string input
        syscall
        add $t0, $0, 0 #initialize $t0 register
        add $t1, $0, 0 #initialize $t1 register

        la $t2, userInput #load string addr into $t2 register
        lb $t0, 0($t2)
        beq $t0, 10, isEmpty #check for an empty string
        beq $t0, 0 isEmpty

        addi $s0, $0, 32 #store Base-N number
        addi $t3, $0, 1 #iniialize new registers
        addi $t4, $0, 0
        addi $t5, $0, 0

        skipSpace:
            lb $t0, 0($t2) #load address in $t2 to $t0
            addi $t2, $t2, 1 #increment pointer
            addi $t1, $t1, 1 #increment counter
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
    #mul $s3, $s3, $a2 #multiplying the byte x the exponentiated base (starts at 1(35^0 = 1))
    #mul $a2, $a2, 35 #multiplying the exoonentiated base by 35 to get next power (35^1 ...)
    More:
        mul $s3, $s3, $a2 #multiplying the byte x the exponentiated base (starts at 1(35^0 = 1))
        mul $a2, $a2, 32 #multiplying the exponentiated base by 35 to get next power (35^1 ...)
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
