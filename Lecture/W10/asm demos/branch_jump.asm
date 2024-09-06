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
sw $t1, 0($t0) 		# paint the first (top-left) unit red.
sw $t2, 4($t0) 		# paint the second unit on the first row green. Why $t0+4?
sw $t3, 128($t0) 	# paint the first unit on the second row blue. Why +128?
add $t4, $t1, $t2	#  $t4 = $t1 + $t2  ($t4 = yellow)


#
# Example #1: Leap year calculator - Assume the current year is stored
#             in $a0, set $v0 to the number of days in the current year.
#

addi $a0, $zero, 2020		# set current year to 2022

addi $t9, $zero, 4		# divide current year by 4, 
div $a0, $t9	 		
mfhi $t8			# check if the remainder is zero.
bne $t8, $zero, not_leap_year	# branch to not_leap_year if remainder != 0

addi $v0, $zero, 366		# current year has 366 days
j end_leap_year			# jump to end of leap year calculator.

not_leap_year:
addi $v0, $zero, 365		# current year has 365 days

end_leap_year:

# 
# Example #2: Filling a row with 2x2 squares.
# 

# initialize the loop variables $t5, $t6
add $t5, $zero, $zero	# set $t5 to zero
addi $t6, $zero, 16	# set $t6 to 16

paint:
beq $t5, $t6, Exit	# Branch to Exit if $t5 == 16

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

Exit:
li $v0, 10 # terminate the program gracefully
syscall