##########################################################################
# Created by: Sandhu, Tanvir
# taksandh
# 12 May 2020
#
# Assignment: Lab 3: ASCII-risks
# CSE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Spring 2020
#
# Description: This program prints a pyramid with the height that the user inputs.
#
# Notes: This program is intended to be run on the MARS application.
##########################################################################

#REGISTER USAGE
#$t0: holds the user input throughout the whole program
#$t1: counter for how many lines are being printed.
#$t2: counter for how many numbers to print before the stars
#$t3: counter for how many stars to print
#$t4: counter for how many stars have printed
#$t5: the number that needs to be printed on the positive pyramid
#$t6: counter for how many numbers need to be printed (positive pyramid)
#$t7: the number that needs to be printed on the negative pyramid
#$t8: counter for how many numbers need to be printed (negative pyramid)

#PSEUDOCODE:
#For this program, I wrote it in the order of prompt, stars, numbers, then reverse numbers. To ensure that the invalid
#entry message would print, I used the ble command (branch if less than OR EQUAL) so it included 0. 
#For the stars function,
#I created two variables, one that counted how many stars needed to be printed and one that counted how many stars had
#already been printed. That way, when they were equal, it would jump to the next function. For these variables, one was
#counting how many times the print function was executed (number of stars printed) and the other was a set value based
#on the (user input*2)-1 (number of stars needed). once each line was printed, I would jump back to the head function
#countstars, where the second variable would have another two subtracted from it and it would run again with a newline.
#For the numbers function,
#I created another three variables. The first counted how many numbers needed to be printed, so 1 was added to it every
#cycle, as each succeeding line had one more number than the previous. The second counts how many numbers have been 
#printed by adding one each time the print statement goes through. The third variable is the number that I am printing,
#so that also has one added to it each time the print statement goes through, to ensure ascending order of numbers.
#Before making a reverse version of the numbers, I had to create a small function that would give the value of the last
#number in the pyramid to another function so I could manipulate it. I also created a new variable to count the amount
#of numbers need to printed. It then jumps to the reverse function.
#For the reverse function,
#it was exactly the same as the numbers function, except instead of adding one to the number to be printed, I subtracted
#one since it is going backwards. Also, to ensure that there is no extra tab at the end, I created a line that if the
#amount of numbers printed was not equal to the amount of numbers needed, it would jump to a new function whose soul 
#purpose is to add a tab. That way, the last number in each line would not have a tab.
#After that's done, it jumps back to countstars and runs until it hits the user input, then it ends.
.data  
	Prompt: .asciiz "\nEnter the height of the pattern (must be greater than 0):	"
	message: .asciiz "Invalid Entry!"
	star: .asciiz "*	"
	newline: .asciiz "\n"
	tab: .asciiz "	"
	
.text	
    main: 	
	li   $v0, 4					#prompts user, gets user input and stores it in $t0
	la   $a0, Prompt 
	syscall 
	li   $v0, 5
	syscall 
	move $t0, $v0
	
	ble  $t0, $0, print				#checks if user input is <=0. if it is, jumps to print	
	nop
	
	add  $t3, $t0, $t0				#multiples input by two, then subtracts one to get the 
	sub  $t3, $t3, 1				#	number of stars that needs to be printed for the 1st row
	
	sub  $t0, $t0, 1				#Because it runs from 0 to the user input, i needed to subtract
							#	one from the input to ensure correct output.
	countstars:
	    li   $v0, 4					#prints a newline before pyramid begins
	    la   $a0, newline
	    syscall 
	    
	    blt  $t0, $t1, end				#if the number of lines printed equals user input, program
	    nop						#	terminates
	    						
	    li   $t4, 0					#resets variable to 0
	    
	    addi $t1, $t1, 1				#counter for number of lines
	    sub  $t3, $t3, 2				#each time stars print, we need to subtract two for the next line
	    
	    addi $t2, $t2, 1				#add one to the number counter everytime we return to this function.
	    
	    li   $t6, 0					#reset number counter to 0
	    j number
	stars:
	    blt  $t3, $t4, yeet				#if number of stars printed equals number of stars needed, jump
	    nop						#	to next
	    						
	    li   $v0, 4					#prints a star
	    la   $a0, star 
	    syscall 
	    
	    addi $t4, $t4, 1				#adds one to the counter
	    
	    j stars
	    
	number:
	    beq  $t6, $t2, stars			#if the right amount of numbers have printed, jump to next
	    nop
	    
	    addi $t6, $t6, 1				#each line, one more number needs to be printed, so i add one.
	    addi $t5, $t5, 1				#each number is one more than the previous number, so add one.
	    
	    li   $v0, 1					#print the right number in ascending order.
	    move $a0, $t5
	    syscall
	    
	    li   $v0, 4					#prints tab after the value.
	    la   $a0, tab 
	    syscall
	    
	    j number

	yeet:
	    li   $t8, 0					#resets number counter to 0
	    addi $t7, $t5, 0				#moves last number held by $t5 to $t7
	    addi $t7, $t7, 1				#add 1 to the number so it can print
	    
	    j reverse 

	reverse:
	    beq  $t8, $t2, countstars			#if the right amount of numbers have printed, jump to countstars. 
	    nop
	    
	    addi $t8, $t8, 1				# add 1 to number counter
	    subi $t7, $t7, 1				# subtract one from number printed since we are going backwards
	    
	    li   $v0, 1					#prints said number
	    move $a0, $t7
	    syscall
	    
	    blt  $t8, $t2, extratab			#if tab is required, jumps to function that puts tab
	    nop						#	to ensure no tab at the end
	    
	    j reverse
	    
    print:
	li $v0, 4					#prints the message "invalid entry!" if input is <= 0. 
	la $a0, message 
	syscall 
	j main     
       
   extratab:
        li $v0, 4					#puts a tab after an entry if called on
	la $a0, tab 
	syscall
	
	j reverse

    end: 
	li $v0, 10					#system end call 
	syscall 
				
	
	
	

	
	
	
