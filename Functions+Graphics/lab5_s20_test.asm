# Spring20 Lab5 Test File
#
#------------------------------------------------------------------------
# pop and push macros
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#------------------------------------------------------------------------
# print string

.macro print_str(%str)

    .data
    str_to_print: .asciiz %str

    .text
    push($a0)                        # push $a0 and $v0 to stack so
    push($v0)                         # values are not overwritten
    
    addiu $v0, $zero, 4
    la    $a0, str_to_print
    syscall

    pop($v0)                        # pop $a0 and $v0 off stack
    pop($a0)
.end_macro

.macro printSRegContents(%str)
	print_str(%str)
	push($a0)                        # push $a0 and $v0 to stack so
        push($v0)                         # values are not overwritten
        
        li $v0, 34
        move $a0, $s0
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        
        li $v0, 34
        move $a0, $s1
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        
        li $v0, 34
        move $a0, $s2
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        
        li $v0, 34
        move $a0, $s3
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        
        li $v0, 34
        move $a0, $s4
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        
        li $v0, 34
        move $a0, $s5
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        
        li $v0, 34
        move $a0, $s6
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        
        li $v0, 34
        move $a0, $s7
        syscall
        li $v0, 11
        li $a0, ' '
        syscall
        
        pop($v0)                        # pop $a0 and $v0 off stack
        pop($a0)
.end_macro
#------------------------------------------------------------------------
# data segment
.data
black: .word 0x00000000
white: .word 0x00FFFFFF
red: .word 0x00FF0000
green: .word 0x0000FF00
blue: .word 0x000000F
orange: .word 0x00FF0F00
yellow: .word 0x00FFFF00
cyan: .word 0x0000FFFF
midnightblue: .word 0x00191970
firebrick: .word 0x00B22222
slategray: .word 0x00708090
mediumseagreen: .word 0x003CB371
darkgreen: .word 0x00006400
indigo: .word 0x004B0082

.text
main: nop
#Fill up S registers to check for saved s registers
li $s0 0XFEEDBABE
li $s1 0XC0FFEEEE
li $s2 0XBABEDADE
li $s3 0XFEED0DAD
li $s4 0X00000000
li $s5 0XCAFECAFE
li $s6 0XBAD00DAD
li $s7 0XDAD00B0D

# 0. Clear_Bitmap test
    #print_str("-------------------------------\nClear_Bitmap Test:\n")
    #print_str("Paints entire bitmap a midnight blue color\n\n")
    #printSRegContents("S registers before: ")
    #lw $a0, midnightblue 	
    #jal clear_bitmap
    #printSRegContents("\nS registers after:  ")

# 1. Pixel tests
    #print_str("\n\n-------------------------------\nPixel Test:\n")
    #print_str("Draws single orange pixel at (1,1) and yellow pixel at (126,126)\n\n")
    #printSRegContents("S registers before: ")
    #jal pixelTest
    #printSRegContents("\nS registers after:  ")
    
# 2. Solid circle test
    print_str("\n\n-------------------------------\nSolid Circle Test:\n")
    print_str("Creates a pattern using 9 solid circles\n\n")
    printSRegContents("S registers before: ")    
    jal solidCircleTest
    printSRegContents("\nS registers after:  ")  
      
# 2. Bresenham's circle test
    print_str("\n\n-------------------------------\nBresenham's Circle Test:\n")
    print_str("Creates a pattern using 8 circunferences\n\n")
    printSRegContents("S registers before: ") 
    jal circleTest
    printSRegContents("\nS registers after:  ")
    
#Exit when done
li $v0 10 
syscall

#------------------------------------------------------------------------
pixelTest: nop 
	push($ra)
	
	# Check for Clear_Bitmap test color
	print_str("\nGet_pixel($a0 = 0x00400040) should return: 0x00191970\nYour get_pixel($a0 = 0x00400040) returns:  ")
    	li $a0, 0x00400040
    	jal get_pixel
    	move $a0, $v0
    	li $v0, 34
    	syscall
	
	# cyan point at  (1,1)
	li $a0, 0x00010001
    	lw $a1, cyan
    	jal draw_pixel
    	
    	# yellow point at  (126,126)
    	li $a0, 0x007E007E
    	lw $a1, yellow
    	jal draw_pixel
    	
    	print_str("\nGet_pixel($a0 = 0x00010001) should return: 0x0000ffff\nYour get_pixel($a0 = 0x00010001) returns:  ")
    	li $a0, 0x00010001
    	jal get_pixel
    	move $a0, $v0
    	li $v0, 34
    	syscall
    	
    	print_str("\nGet_pixel($a0 = 0x007e007e) should return: 0x00ffff00\nYour get_pixel($a0 = 0x007e007e) returns:  ")
    	li $a0, 0x007E007E
    	jal get_pixel
    	move $a0, $v0
    	li $v0, 34
    	syscall
    	
    	pop($ra)
    	jr $ra

#------------------------------------------------------------------------  
solidCircleTest: nop    
	push($ra)
	
	li $a0, 0x00400022
	li $a1, 30
 	lw $a2, firebrick
	jal draw_solid_circle
	
	li $a0, 0x005E0040
	li $a1, 30
 	lw $a2, firebrick
	jal draw_solid_circle
	
	li $a0, 0x0040005E
	li $a1, 30
 	lw $a2, firebrick
	jal draw_solid_circle
	
	li $a0, 0x00220040
	li $a1, 30
 	lw $a2, firebrick
	jal draw_solid_circle
	
	li $a0, 0x00400022
	li $a1, 25
 	lw $a2, slategray
	jal draw_solid_circle
	
	li $a0, 0x005E0040
	li $a1, 25
 	lw $a2, slategray
	jal draw_solid_circle
	
	li $a0, 0x0040005E
	li $a1, 25
 	lw $a2, slategray
	jal draw_solid_circle
	
	li $a0, 0x00220040
	li $a1, 25
 	lw $a2, slategray
	jal draw_solid_circle

	li $a0, 0x00400040
	li $a1, 35
 	lw $a2, mediumseagreen
	jal draw_solid_circle
	
    	print_str("\nGet_pixel($a0 = 0x00240024) should return: 0x00b22222\nYour get_pixel($a0 = 0x00240024) returns:  ")
    	li $a0, 0x00240024
    	jal get_pixel
    	move $a0, $v0
    	li $v0, 34
    	syscall	
    	
    	print_str("\nGet_pixel($a0 = 0x00400010) should return: 0x00708090\nYour get_pixel($a0 = 0x00400010) returns:  ")
    	li $a0, 0x00400010
    	jal get_pixel
    	move $a0, $v0
    	li $v0, 34
    	syscall
    	
    	print_str("\nGet_pixel($a0 = 0x00400040) should return: 0x003cb371\nYour get_pixel($a0 = 0x00400040) returns:  ")
    	li $a0, 0x00400040
    	jal get_pixel
    	move $a0, $v0
    	li $v0, 34
    	syscall
	
	pop($ra)
	jr $ra
	
#------------------------------------------------------------------------  
circleTest: nop    
	push($ra)
	
	li $a0, 0x004C0034
	li $a1, 17
 	lw $a2, darkgreen
	jal draw_circle
	
	li $a0, 0x0034004C
	li $a1, 17
 	lw $a2, darkgreen
	jal draw_circle
	
	li $a0, 0x004C004C
	li $a1, 17
 	lw $a2, darkgreen
	jal draw_circle
	
	li $a0, 0x00340034
	li $a1, 17
 	lw $a2, darkgreen
	jal draw_circle
	
	li $a0, 0x00510040
	li $a1, 17
 	lw $a2, indigo
	jal draw_circle
	
	li $a0, 0x00400051
	li $a1, 17
 	lw $a2, indigo
	jal draw_circle
	
	li $a0, 0x002F0040
	li $a1, 17
 	lw $a2, indigo
	jal draw_circle
	
	li $a0, 0x0040002F
	li $a1, 17
 	lw $a2, indigo
	jal draw_circle
	
    	print_str("\nGet_pixel($a0 = 0x00400057) should return: 0x00006400\nYour get_pixel($a0 = 0x00400057) returns:  ")
    	li $a0, 0x00400057
    	jal get_pixel
    	move $a0, $v0
    	li $v0, 34
    	syscall
    	
    	print_str("\nGet_pixel($a0 = 0x0040001E) should return: 0x004b0082\nYour get_pixel($a0 = 0x0040001E) returns:  ")
    	li $a0, 0x0040001E
    	jal get_pixel
    	move $a0, $v0
    	li $v0, 34
    	syscall
	
	pop($ra)
	jr $ra
#------------------------------------------------------------------------  
# Be sure to use the lab5_s20_template.asm and rename it to Lab5.asm so it
# is included here!
# 
.include "Lab5.asm"
