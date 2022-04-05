##########################################################################
# Created by: Sandhu, Tanvir
# taksandh
# 22 May 2020
#
# Assignment: Lab 4: Sorting Integers
# CSE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Spring 2020
#
# Description: This program prints program arguments in hex, converts them to decimal, and sorts them.
#
# Notes: This program is intended to be run on the MARS application.
##########################################################################
#REGISTER USAGE:
#$t0: holds the amount of program arguments given
#$t1: counter for how may arguments have printed // counter for inner sorted loop
#$t2: stores the word from the address holding the arguments in the int function // holds left word in array
#$t3: stores the word from the address holding the arguments in the intcount function // holds right word in array
#$t4: holds the byte I am currently working with // counter for how many sorted values have printed
#$t5: base for what is being multiplied by 16 // counter for outer check loop
#$t6: counter for how many values have been processed by int function
#$t7: counter for how many arguments have been processed by the entire program
#$t8: holds the array where the sort is occurring
# -
#$s0: holds the address from which the first program argument is stored
#$s1: counter for how many terms (1-3) are in each program argument
##########################################################################
#PSEUDOCODE:
#I took this assignment in three parts: program arguments, hex to dec conversion, and then sorting
#For the program arguments, after watching Gia's lab demo video, it was easy to loop through the arguments by loading the
#word in the address and then adding four to move to the next argument, printing them each time.
#For the hex to dec conversion, I set up function intcount to count how many terms were in the argument, by loading byte
#until a 0 was encountered, and adding one to a counter until that happened. Then, I loaded the first byte with an offset of
#two (forget the 0x) to a register, subtracted 48 from it (.ascii value) and then checked if the value was larger than 9.
#If it was, I branched to another letter function that subtracted another 7 from it (55 total). Then, I took that value
#and implemented tutor code to make sure it would be multiplied to the correct power of 16 (looped for as many terms as 
#the program argument had). The values were then added together and then printed. This whole process was done for each
#program argument to convert from hex to dec.
#For the sorting, I implemented the idea beging Bubble Sort I found in the textbook on page 171. Basically, I created an
#array to hold the decimal conversions done in the previous step right before I print them. The sort function's outer loop
#resets the array to the first decimal each time and counts to make sure that the inner function runs an appropriate amount
#of times. The inner loop does the actual sorting. It loads the left word into one register and the right word into another.
#If the right word is smaller than the left word, it branches to a swap function that overwrited both with the other word.
#This runs the same amount of times as there are arguments, and after it's done, it goes to the outer loop, which makes
#the whole process run until the amount of arguments. At this point, it will jump to a print function that prints the 
#now sorted values of the array with a space in between but no extra space at the end. 

.data 
    yeet:    .align 2
             .space 32
    arg:     .asciiz "Program arguments:\n"
    newline: .asciiz "\n"
    intval:  .asciiz "Integer values:\n"
    sort:    .asciiz "Sorted values:\n"

.text 
    main: 
    	la $t0, ($a0)				#sets $t0 to the amount of program arguments there are
    	la $s0, ($a1)				
    	lw   $t3, ($s0)				#loads word from address to $t3
    	lw   $t2, ($s0)				#loads word from address to $t2
    	
    	li $v0, 4				#prints the "arg" in the .data section
    	la $a0, arg
    	syscall

    	
        argprint:
            li   $v0, 4				#prints the number in register $a1
            lw   $a0, ($a1)
            syscall
            
            addi $t1, $t1, 1			#adds one to the counter for everytime an argument is printed
            beq $t0, $t1, new			#avoids extra space at the end if amount of printed numbers is equal to
            					#	the amount given
            li   $a0, 32			#prints a space between program inputs
            li   $v0, 11
            syscall 
	    
	    addi $a1, $a1, 4			#adds four to $a1 because the next program arg is 4 bits later
	    
	    j argprint				#loops this function until the correct amount of items have been printed

    new:
        li $v0, 4				#prints two newlines after the program arguments have printed
        la $a0, newline
        syscall
        
        li $v0, 4
        la $a0, newline
        syscall
        
    
    intprompt:
        li $v0, 4				#prints the intval prompt from the .data section
        la $a0, intval
        syscall
        
        j intcount

    intcount:
   	lb   $t4, 0x02($t3)			#sets t4 to the byte of the argument at address $t3 (offset by 2)
   
	beq $t4, 0, int				#if the byte is 0, the current program argument has ended, jumps to int
	subi $t4, $t4, 48			#subtract because the ascii value of numbers is 48
	
	addi $t3, $t3, 1			#add 1 to the address so it moves to the next byte next time
	addi $s1, $s1, 1			#adds one to the counter that measures how many numbers there are in
						#	the current program argument
	j intcount

    int: 
    	lb   $t4, 0x02($t2)			#sets $t4 to the byte of the argument at address $t2 (offset by 2)
	
	addi $t6, $t6, 1			#adds one to the counter for how may values have been processed by int
	beq $t4, 0, print			#if the byte is 0, that argument has ended, and the product will be printed
	subi $t4, $t4 48			#subtract because the ascii value of numbers is 48 
	
	addi $t2, $t2, 1			#adds one to $t2 so it moves to the next byte next time
        
        j lettercheck

    	lettercheck:
            bgt $t4, 9, letter			#if $t4 is greater than 9, the byte was a letter
        
            j math				#if not, jump to math
        	
    	    letter:
    		subi $t4, $t4, 7		#if the byte is a letter, subtract 7 more from it, because ascii 
    						#	number for letters is 55 (48+7=55)
    		j math
    	math:
    	    mul $t5, $t5, 16			#$t5 starts with no value for the first byte in each argument, but the
  	    add $t5, $t5, $t4 			#	second time, it will be the value to multiply by 16
  	    
	    beq $s1, $t6, print			#if the amount the amount of terms in the program is equal to how 
	    					#	many terms have been processed, jump to print
	    j int
    print:
        addi $s0, $s0, 4			#adds 4 to the address so that we move on to the next argument
        addi $t7, $t7, 1			#adds 1 to the counter for how many arguments have been completely
	lw $t2, ($s0)				#	processed by the program
	lw $t3, ($s0)				#sets $t3 and $t2 to the new $s0 for the next argument
	
	sw $t5, yeet($t8)
	addi $t8, $t8, 4 
	
        li   $v0, 1				#prints the value in $t5
        move $a0, $t5
	syscall	
	
	beq $t0, $t7, new2			#avoids extra space at the end if the arguments processed is equal to the 
						#	amount provided
	li   $v0, 11				#prints a space between program inputs
	li   $a0, 32			
        syscall
	
	li $t4, 0				#resets $t4, $t5 and $s1 to zero	
	li $s1, 0
	li $t5, 0
	
	j intcount
	
    new2:
        li $v0, 4				#prints two newlines after the hexadecimals have printed
        la $a0, newline
        syscall
        
        li $v0, 4
        la $a0, newline
        syscall
        
        j sortprint
        
    sortprint:
    	li $v0, 4				#prints the intval prompt from the .data section
        la $a0, sort
        syscall
        
        li $t1, 0				#reset registers to 0 before sort step
        li $t2, 0
        li $t3, 0
        li $t4, 0
        li $t5 0
        
    	j check
    	
    check:
        li $t8, 0				#reset array location to 0 so the first value begins the sort
        bge  $t5, $t0, printsort		#if the number of times the sort has gone through is equal to the amount
        li $t1, 1				#	of arguments, print
        addi $t5, $t5, 1			#adds one to the counter of number of sorts
        
    	condition:
    	    bge  $t1, $t0, check		#checks how may terms have been sorted
    	
    	    sorted:
    	        lw $t2, yeet($t8)		#loads argument at current place in array to $t2
    	    	addi $t8, $t8, 4		#moves to next argument
    	    	lw $t3, yeet($t8)		#loads argument at next byte to $t3
    	    
    	    	addi $t1, $t1, 1		#adds one to the counter
    	    	bgt $t2, $t3, swap		#if the right number is greater than the left number, go to swap
    	    	j condition
    	    	
    	    swap:
    	    	addi $t8, $t8, -4		#go to the left position, overwrite it with the lesser number
    	    	sw $t3, yeet($t8)
    	    	
    	    	addi $t8, $t8, 4		#go to the right position, overwrite it with the greater number
    	        sw $t2, yeet($t8)
    		
    		j condition
    printsort:
        li   $v0, 1				#prints the value in the array
        lw   $a0, yeet($t8)
	syscall	
	
	addi $t4, $t4, 1			#adds one to the counter of how many sorted values have printed
	beq $t4, $t0, new3			#avoids the space if number of sorted values is equal to amount of 
						#	arguments printed.
        li   $a0, 32				#prints a space between sorted values
        li   $v0, 11
        syscall 
    	
    	addi $t8, $t8, 4			#moves to the next value in the array
    	
    	j printsort
    	
    new3:
        li $v0, 4				#prints newline after sorted integers
        la $a0, newline
        syscall
        
        j end
	
    end:
        li $v0, 10				#system end call 
	syscall 

        
		