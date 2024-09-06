# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
displayAddress: .word 0x10008000
colour_red:	.word 0xff0000
colour_green:	.word 0x00ff00
colour_blue:	.word 0x0000ff
gray_line:	.word 0x010101:32
road_row:	.space 512

.text
lw $t0, displayAddress 	# $t0 stores the base address for display
# li $t1, 0xff0000 	# $t1 stores the red colour code
# li $t2, 0x00ff00 	# $t2 stores the green colour code
# li $t3, 0x0000ff 	# $t3 stores the blue colour code
sw $t1, 0($t0) 		# paint the first (top-left) unit red.
sw $t2, 4($t0) 		# paint the second unit on the first row green. Why $t0+4?
sw $t3, 128($t0) 	# paint the first unit on the second row blue. Why +128?

# Fetching colour values from memory (or any memory values)
la $t9, colour_red	# Get the address of the colour_red variable
lw $t1, 0($t9)		# Store the colour red into $t1
la $t9, colour_green	# Get the address of the colour_green variable
lw $t2, 0($t9)		# Store the colour green into $t2
la $t9, colour_blue	# Get the address of the colour_blue variable
lw $t3, 0($t9)		# Store the colour blue into $t3
add $t4, $t1, $t2	# set $t4 = $t1 + $t2  ($t4 = yellow)

# Fetching and updating memory values
la $t9, gray_line	# Get the address of the gray line
lw $t8, 0($t9)		# Get the first pixel value in the gray line
sll $t8, $t8, 4		# Brighten the first gray pixel
sw $t8, 0($t9)		# Set the first pixel in the gray line to the lighter value

# Old approach: set up input arguments for draw_line function
# add $a0, $zero, $t0	# Get drawing position from $t0 above
# addi $a1, $zero, 8	# Make the width 8 pixels wide
# addi $a2, $zero, 8	# Make the height 8 pixels wide
# add $a3, $zero, $t4	# Make the line yellow

# Pass the input arguments to draw_rectangle through the stack instead.
addi $sp, $sp, -4	# Move the stack pointer to the next empty location.
sw $t0, 0($sp)		# Push the address of the top left pixel onto the stack.
addi $t9, $zero, 8	# Store the width of the rectangle into $t9
addi $sp, $sp, -4	# Move the stack pointer to the next empty location.
sw $t9, 0($sp)		# Push the width of the rectangle onto the stack.
addi $t9, $zero, 6	# Store the height of the rectangle into $t9
addi $sp, $sp, -4	# Move the stack pointer to the next empty location.
sw $t9, 0($sp)		# Push the height of the rectangle onto the stack.
addi $sp, $sp, -4	# Move the stack pointer to the next empty location.
sw $t4, 0($sp)		# Push the colour of the rectangle onto the stack.

jal draw_rectangle	# draw the rectangle
j Exit

#
#  Function for drawing a rectangle
#
draw_rectangle:
# $a0 stores the memory location for the top left pixel in this rectangle.
# $a1 stores the width of this rectangle.
# $a2 stores the height of this rectangle.
# $a3 stores the colour of the pixels in this rectangle.
# $t0 stores the index of the current row being drawn.
# $t1 stores the width of the rectangle in pixels
# $t2 stores the width of the rectangle

# Pop input arguments from top of stack
lw $a3, 0($sp)			# Pop the colour of the rectangle from the stack
addi $sp, $sp, 4		# Move $sp to the new top element of the stack.
lw $a2, 0($sp)			# Pop the height of the rectangle from the stack
addi $sp, $sp, 4		# Move $sp to the new top element of the stack.
lw $a1, 0($sp)			# Pop the width of the rectangle from the stack
addi $sp, $sp, 4		# Move $sp to the new top element of the stack.
lw $a0, 0($sp)			# Pop the location of the top left pixel from the stack
addi $sp, $sp, 4		# Move $sp to the new top element of the stack.


add $t0, $zero, $zero			# Set index $t0 to zero
add $t2, $zero, $a2			# Store $a2 in a different register
row_drawing_loop:
beq $t0, $t2, end_draw_rectangle	# If $t0 == $a2, break out of row-drawing loop.
add $a2, $zero, $a3			# Set up input arguments for draw_line function

addi $sp, $sp, -4			# Move stack pointer to empty location
sw $t0, 0($sp)				# Push $t0 onto the stack, to keep it safe
addi $sp, $sp, -4			# Move stack pointer to empty location
sw $ra, 0($sp)				# Push $ra onto the stack, to keep it safe
addi $sp, $sp, -4			# Move stack pointer to empty location
sw $t2, 0($sp)				# Push $t2 onto the stack, to keep it safe
jal draw_line				# Call the draw_line function
lw $t2, 0($sp)				# Pop $t2 off the stack
addi $sp, $sp, 4			# Move stack pointer to top element on stack
lw $ra, 0($sp)				# Pop $ra off the stack
addi $sp, $sp, 4			# Move stack pointer to top element on stack
lw $t0, 0($sp)				# Pop $t0 off the stack
addi $sp, $sp, 4			# Move stack pointer to top element on stack

addi $a0, $a0, 128			# Move $a0 down a row 
sll $t1, $a1, 2 			# Calculate rectangle width in pixels
sub $a0, $a0, $t1			# Move $a0 back to the first column
addi $t0, $t0, 1			# Increment index $t0
j row_drawing_loop			# jump to beginning of row-drawing loop.
end_draw_rectangle:
jr $ra					# Return to calling program

#
#  Function for drawing a line
#
draw_line:
# $a0 stores the memory location for the first pixel of this line.
# $a1 stores the length of this line.
# $a2 stores the colour of the pixels in this line.
# $t0 stores the index of the current pixel being drawn.

add $t0, $zero, $zero		# Set index $t0 to zero
draw_line_loop:
beq $t0, $a1, end_draw_line	# If $t0 == $a1 jump out of the loop.
sw $a2, 0($a0)			# Draw pixel at current position
addi $a0, $a0, 4		# Move current pixel position one pixel to the right
addi $t0, $t0, 1		# increment index variable $t0
j draw_line_loop		# Jump to beginning of loop

end_draw_line: 
jr $ra				# Return to calling program


Exit:
li $v0, 10 # terminate the program gracefully
syscall