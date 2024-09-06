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

.text
lw $t0, displayAddress 	# $t0 stores the base address for display
li $t1, 0xff0000 	# $t1 stores the red colour code
li $t2, 0x00ff00 	# $t2 stores the green colour code
li $t3, 0x0000ff 	# $t3 stores the blue colour code
# sw $t1, 0($t0) 		# paint the first (top-left) unit red.
# sw $t2, 4($t0) 		# paint the second unit on the first row green. Why $t0+4?
# sw $t3, 128($t0) 	# paint the first unit on the second row blue. Why +128?
add $t4, $t1, $t2	#  $t4 = $t1 + $t2  ($t4 = yellow)


#
# Example #1: Leap year calculator - Assume the current year is stored
#             in $a0, set $v0 to the number of days in the current year.
#

addi $a0, $zero, 2000		# set the current year

addi $t9, $zero, 4		# Set $t9 = 4
div $a0, $t9			# Divide $a0 by 4
mfhi $t8			# $t8 stores the remainder of this division
beq $t8, $zero, handle_100	# If $a0 is divisible by 4, skip the following steps.
addi $v0, $zero, 365		#   -> set $v0 = 365
j end_leap_year			#   -> jump to the end

handle_100:
# If $a0 is divisible by 4, check if it's also divisible by 100.
addi $t9, $zero, 100		# Set $t9 = 100
div $a0, $t9			# Divide $a0 by 100
mfhi $t8			# $t8 stores the remainder of this division
beq $t8, $zero, handle_400	# If $a0 is divisible by 100, skip the following steps.
addi $v0, $zero, 366		#   -> set $v0 = 366
j end_leap_year			#   -> jump to the end

handle_400:
# If $a0 is divisible by 100, check if it's also divisible by 400.
addi $t9, $zero, 400		# Set $t9 = 400
div $a0, $t9			# Divide $a0 by 400
mfhi $t8			# $t8 stores the remainder of this division
beq $t8, $zero, final_case	# If $a0 is not divisible by 400, the value in $a0 is not a leap year
addi $v0, $zero, 365		#   -> set $v0 to 365
j end_leap_year			#   -> jump to the end

final_case:
# If $a0 is divisible by 400, the value in $a0 is a leap year
addi $v0, $zero, 366		#   -> set $v0 = 366
# j end_leap_year			#   -> jump to the end

end_leap_year:


# 
# Example #2: Filling a row with 2x2 squares.
# 

# initialize the loop variables $t5, $t6
add $t5, $zero, $zero	# set $t5 to zero
addi $t6, $zero, 16	# set $t6 to 16

paint:
beq $t5, $t6, end_loop	# Branch to Exit if $t5 == 16

sw $t1, 0($t0) 		# paint the first (top-left) unit red.
addi $t0, $t0, 4   	# move to the next pixel over in the bitmap
sw $t2, 0($t0) 		# paint the second unit on the first row green. Why $t0+4?
addi $t0, $t0, 124   	# move to the next pixel over in the bitmap
sw $t3, 0($t0) 		# paint the first unit on the second row blue. Why $t0+124?
addi $t0, $t0, 4   	# move to the next pixel over in the bitmap
sw $t4, 0($t0) 		# paint the second unit on the second row yellow.
addi $t0, $t0, -124	# move up to the previous row, beside the green pixel	

addi $t5, $t5, 1	# increment $t5 by 1
j paint			# jump to the beginning of the loop

end_loop:


#
# Example #3: Drawing a rectangle
#

lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 512	# start drawing 4 lines down.

# Assume that the height and width of the rectangle are in $a0 and $a1
addi $a0, $zero, 6	# set height = 6
addi $a1, $zero, 10	# set width = 10

# Draw a rectangle:
add $t6, $zero, $zero	# Set index value ($t6) to zero
draw_rect_loop:
beq $t6, $a0, Exit  	# If $t6 == height ($a0), jump to end

# Draw a line:
add $t5, $zero, $zero	# Set index value ($t5) to zero
draw_line_loop:
beq $t5, $a1, end_draw_line  # If $t5 == width ($a1), jump to end
sw $t4, 0($t0)		#   - Draw a pixel at memory location $t0
addi $t0, $t0, 4	#   - Increment $t0 by 4
addi $t5, $t5, 1	#   - Increment $t5 by 1
j draw_line_loop	#   - Jump to start of line drawing loop
end_draw_line:

addi $t0, $t0, 88	# Set $t0 to the first pixel of the next line.
			# Note: This value really should be calculated.
addi $t6, $t6, 1	#   - Increment $t6 by 1
j draw_rect_loop	#   - Jump to start of rectangle drawing loop


Exit:
li $v0, 10 # terminate the program gracefully
syscall