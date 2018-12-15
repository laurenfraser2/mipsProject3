
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
            beq $t0, 10, callconversionfunc
            beq $t0, 0, callconversionfunc
            beq $t0, 32, callconversionfunc
            beq $t1, 5, isTooLong
            j stringLength
