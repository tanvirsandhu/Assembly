##########################################################################
# Created by: Sandhu, Tanvir
# taksandh
# 9 June 2020
#
# Assignment: Lab 5: Functions and Graphics
# CSE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Spring 2020
#
# Description: This program clears the entire display to a color, displays a filled colored circle and displays an
# unfilled colored circle.
#
# Notes: This program is intended to be run on the MARS application.
##########################################################################
#REGISTER USAGE:
#$t0: holds a shifted version of the "%x" input
#$t1: holds the start address for the display
#$t2: holds the end address for the display
#$t3: holds the x-coordinate of the point
#$t4: holds the y-coordinate of the point
#$t5: holds the register at which the coordinates lead to.
#$t6: holds the xmin value in draw_solid_circle
#$t7: holds the xmax value in draw_solid_circle
#$t8: holds the ymin value in draw_solid_circle
#$t9: holds the ymax value in draw_solid_circle
#$s0: holds the (i-xc)^2 value in draw_solid_circle
#$s1: holds the (j-yc)^2 value in draw_solid_circle
#$s2: holds the radius squared for the comparison in draw_solid_circle
#$s3: holds the ymin after $t8 bc it was not working otherwise
#$s4: holds the address at $a1 since the value needs not to be manipulated in $a1
#$s5: holds the x-coordinate for draw_circle_pixels
#$s6: holds the y-coordinate for draw_circle_pixels
#$s7: holds the d-value from the Bresenham Algorithm


#Spring20 Lab5 Template File

# Macro that stores the value in %reg on the stack 
#  and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)

.end_macro 

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	

.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
.macro getCoordinates(%input %x %y)

	srl %x, %input, 16

	mul %y, %input, 0x00010000
	srl %y, %y, 16

.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
.macro formatCoordinates(%output %x %y)
	
	li $t0, 0
	sll $t0, %x, 16
	add %output, $t0, %y
	li $t0, 0

.end_macro 


.data
originAddress: .word 0xFFFF0000

.text
j done
    
    done: nop
    li $v0 10 
    syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#PSEUDOCODE:
#clear_bitmap iterates through the array, starting from 0xFFFF0000 up until the ending address, 0xFFFFFFFc, adding
#the specified color to each pixel, by the end, filling the whole 128x128 square with the color.
#*****************************************************
#Clear_bitmap: Given a color, will fill the bitmap display with that color.
#   Inputs:
#    $a0 = Color in format (0x00RRGGBB) 
#   Outputs:
#    No register outputs
#    Side-Effects: 
#    Colors the Bitmap display all the same color
#*****************************************************
clear_bitmap: nop
	li $t1, 0xFFFF0000					#$t1 has the beginning address
	li $t2, 0xFFFFFFFc					#$t2 has the ending address
	eachbit:	
		bge $t1, $t2, yeet				#runs until the current address reaches the end
		sw $a0, ($t1)					#puts the color in the array
		addi $t1, $t1, 4				#moves to the next array
		
		j eachbit
	yeet:
		jr $ra

#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1	
#PSEUDOCODE:
#draw_pixel gets the coordinates into two registers, multiplies the x by the number of bits per row, so we get to the 
#correct row, and multiplies y by 4 (the amount of bytes in each spot) to get us to the right column. It then will
#store the given color in the pixel.
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#*****************************************************
draw_pixel: nop

	getCoordinates($a0, $t3, $t4) 					#puts x into $t3 and y into $t4
	
	li $t1, 0xFFFF0000						#sets $t1 as starting address
	
	mul $t5, $t3, 512						#multiplies x by the number of bits in each row
	add $t5, $t5, $t1						#adds to starting address
	
	mul $t4, $t4, 4							#multiplies y by the amount of bits in each pixel
	add $t5, $t5, $t4						#adds to the starting address as well	
	
	sw $a1, ($t5)							#stores color in desired pixel
	
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#PSEUDOCODE:
#after getting the coordinates into two separate variables, get_pixel uses the exact same algorithm as draw_pixel to 
#find the correct pixel, but instead of putting something into the pixel, it copies what is in that pixel to $v0, so 
#can see what color is in that pixel.
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#   Outputs:
#    Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
get_pixel: nop
	getCoordinates($a0, $t3, $t4)					#stores x in $t3 and y in $t4
	 
	li $t1, 0xFFFF0000						#puts starting address in $t1
	
	mul $t5, $t4, 512						#multiplies x by the number of bits in each row
	add $t5, $t5, $t1						#adds it to starting address
	
	mul $t3, $t3, 4							#multiplies y by the amount of bits in each pixel
	add $t5, $t5, $t3						#adds it to starting address as well
	
	lw $v0, ($t5)							#loads the color into $v0
	
	jr $ra

#***********************************************
# draw_solid_circle:
#  Considering a square arround the circle to be drawn  
#  iterate through the square points and if the point 
#  lies inside the circle (x - xc)^2 + (y - yc)^2 = r^2
#  then plot it.
#-----------------------------------------------------
# draw_solid_circle(int xc, int yc, int r) 
#    xmin = xc-r
#    xmax = xc+r
#    ymin = yc-r
#    ymax = yc+r
#    for (i = xmin; i <= xmax; i++) 
#        for (j = ymin; j <= ymax; j++) 
#            a = (i - xc)*(i - xc) + (j - yc)*(j - yc)	 
#            if (a < r*r ) 
#                draw_pixel(x,y) 	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of circle center in format (0x00XX00YY)
#    $a1 = radius of the circle
#    $a2 = color in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_solid_circle: nop
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	
	la $s4, ($a1)
	
	getCoordinates($a0, $t3, $t4)
	sub $t6, $t3, $s4 					#$t6 holds the xmin
	add $t7, $t3, $s4					#$t7 holds the xmax
	sub $t8, $t4, $s4					#$t8 holds the ymin
	add $t9, $t4, $s4					#$t9 holds the ymax
	
	first:
		bgt $t6, $t7, yoit				#first for loop in the pseudocde
		addi $t6, $t6, 1				#counter for i
		
		sub $s3, $t8, 0					#puts $t8 contents into $s3
		second:
			bgt  $s3, $t9, first			#second for loop in the pseudocode
			addi $s3, $s3, 1
			
			sub $s0, $t6, $t3			#$s0 holds the first part of the math equation
			mul $s0, $s0, $s0			#doing math in pseudocode
			
			sub $s1, $s3, $t4
			mul $s1, $s1, $s1
			
			mul $s2, $s4, $s4
			add $s1, $s0, $s1			#$s1 holds the "a" value
			
			bge $s1, $s2, second
			
			push($t6)				#pushing required variables
			push($t1)
			push($t3)
			push($t4)
			push($t5)
			push($ra)
			push($a1)
			
			la $a1, 0($a2)				#puts the information in the right place for draw_pixel
			formatCoordinates($a0, $t6, $s3)
			jal draw_pixel
			
			pop($a1)				#pop the same variables that were pushed
			pop($ra)
			pop($t5)
			pop($t4)
			pop($t3)
			pop($t1)
			pop($t6)
			
			j second
			
	yoit:
		pop($s4)
		pop($s3)
		pop($s2)
		pop($s1)
		pop($s0)
		
		jr $ra
		
#***********************************************
# draw_circle:
#  Given the coordinates of the center of the circle
#  plot the circle using the Bresenham's circle 
#  drawing algorithm 	
#-----------------------------------------------------
# draw_circle(xc, yc, r) 
#    x = 0 
#    y = r 
#    d = 3 - 2 * r 
#    draw_circle_pixels(xc, yc, x, y) 
#    while (y >= x) 
#        x=x+1 
#        if (d > 0) 
#            y=y-1  
#            d = d + 4 * (x - y) + 10 
#        else
#            d = d + 4 * x + 6 
#        draw_circle_pixels(xc, yc, x, y) 	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of the circle center in format (0x00XX00YY)
#    $a1 = radius of the circle
#    $a2 = color of line in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_circle: nop
	push($s5)
	push($s6)
	push($s7)
	
	la $a3, ($a1)						#makes $a3 the new r for draw_circle_pixels
	la $a1, ($a2)						#makes $a1 hold the color for draw_circle_pixels
	li $a2, 0						#makes $a2 0, since $a2 is x and x=0
	
	mul $s7, $a3, -2					#$s7 is equivalent to "d" in the pseudocode
	add $s7, $s7, 3
	
	push($ra)
	jal draw_circle_pixels
	pop($ra)
	
	while:
		blt $a3, $a2, end				#the condition for the while loop to break
		
		addi $a2, $a2, 1				#counter
		bgtz $s7, if					#condition for if branch
		blez $s7, else					#condition for else branch
		if:
			subi $a3, $a3, 1			#carrying out if branch math in this loop
			
			sub $s5, $a2, $a3
			mul $s5, $s5, 4
			addi $s5, $s5, 10
			add $s7, $s7, $s5
			
			j jump
		else:
			mul $s6, $a2, 4				#carrying out else branch math in this loop
			addi $s6, $s6, 6
			add $s7, $s6, $s7
			
			j jump 
	
	jump:
		push($ra)					#jumps to draw_circle_pixels after math is done
		jal draw_circle_pixels
		pop($ra)
		
		j while
	
	end:
		pop($s7)
		pop($s6)
		pop($s5)
		
		jr $ra
	
#*****************************************************
# draw_circle_pixels:
#  Function to draw the circle pixels 
#  using the octans' symmetry
#-----------------------------------------------------
# draw_circle_pixels(xc, yc, x, y)  
#    draw_pixel(xc+x, yc+y) 
#    draw_pixel(xc-x, yc+y)
#    draw_pixel(xc+x, yc-y)
#    draw_pixel(xc-x, yc-y)
#    draw_pixel(xc+y, yc+x)
#    draw_pixel(xc-y, yc+x)
#    draw_pixel(xc+y, yc-x)
#    draw_pixel(xc-y, yc-x)
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of circle center in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#    $a2 = current x value from the Bresenham's circle algorithm
#    $a3 = current y value from the Bresenham's circle algorithm
#   Outputs:
#    No register outputs	
#*****************************************************
draw_circle_pixels: nop
	push($s5)
	push($s6)
	
	getCoordinates($a0, $s5, $s6)				#puts x into $s5 and y into $s6
	push($a0)
	add $s5, $s5, $a2					#carrying out first coordinate math (xc+x, yc+y)
	add $s6, $s6, $a3
	
	push($ra)
	formatCoordinates($a0, $s5, $s6)			#format the coordinates for draw_pixel
	jal draw_pixel
	pop($ra)
	
	sub $s5, $s5, $a2					#set xc back to original
	sub $s5, $s5, $a2					#sub x from xc
	
	push($ra)
	#push($a0)
	formatCoordinates($a0, $s5, $s6)			#format the coordinates for draw_pixel
	jal draw_pixel
	#pop($a0)
	pop($ra)
	
	add $s5, $s5, $a2					#carrying out math for third coordinate
	add $s5, $s5, $a2
	sub $s6, $s6, $a3
	sub $s6, $s6, $a3
	
	push($ra)
	#push($a0)
	formatCoordinates($a0, $s5, $s6)			#format the coordinates for draw_pixel
	jal draw_pixel
	#pop($a0)
	pop($ra)
	
	sub $s5, $s5, $a2					#carrying out math for fourth coordinate
	sub $s5, $s5, $a2
	
	push($ra)
	#push($a0)
	formatCoordinates($a0, $s5, $s6)			#format the coordinates for draw_pixel
	jal draw_pixel
	#pop($a0)
	pop($ra)
	
	add $s5, $s5, $a2					#sets xc back to original
	add $s6, $s6, $a3					#adds y to xc
	add $s5, $s5, $a3					#sets yc back to original
	add $s6, $s6, $a2					#adds x to yc
	
	push($ra)
	#push($a0)
	formatCoordinates($a0, $s5, $s6)			#format the coordinates for draw_pixel
	jal draw_pixel
	#pop($a0)
	pop($ra)
	
	sub $s5, $s5, $a3					#carrying out math for sixth coordinate
	sub $s5, $s5, $a3		

	push($ra)
	#push($a0)
	formatCoordinates($a0, $s5, $s6)			#format the coordinates for draw_pixel
	jal draw_pixel
	#pop($a0)
	pop($ra)
	
	add $s5, $s5, $a3					#carrying out math for seventh coordinate
	add $s5, $s5, $a3
	sub $s6, $s6, $a2
	sub $s6, $s6, $a2

	push($ra)
	#push($a0)
	formatCoordinates($a0, $s5, $s6)			#format the coordinates for draw_pixel
	jal draw_pixel
	#pop($a0)
	pop($ra)
	
	sub $s5, $s5, $a3					#carrying out math for last coordinate
	sub $s5, $s5, $a3
	
	push($ra)
	#push($a0)
	formatCoordinates($a0, $s5, $s6)			#format the coordinates for draw_pixel
	jal draw_pixel
	#pop($a0)
	pop($ra)		
	
	pop($a0)						#pop all used and pushed registers
	pop($s5)
	pop($s6)
	
	jr $ra
