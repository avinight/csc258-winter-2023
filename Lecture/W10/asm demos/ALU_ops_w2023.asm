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

#
# Previous code is from project handout.
# Following code is from in-class ALU operations demo.
#
add $t4, $t1, $t3	# Combine red and blue (magenta)
sw $t4, 124($t0) 	# paint the last unit on the first line
add $t5, $t2, $t3	# Combine green and blue (cyan)
sw $t5, 120($t0) 	# paint the second-last unit on the first line
add $t6, $t1, $t2	# Combine red and green (yellow)
sw $t6, 116($t0) 	# paint the third-last unit on the first line
add $t7, $t1, $t5	# Combine red and cyan (white)
sw $t7, 112($t0) 	# paint the fourth-last unit on the first line

addi $t8, $zero, 16	# load the value 16 into $t8
addi $t9, $zero, 128	# load the value 128 into $t9
mult $t8, $t9		# multiply 
mflo $t8		# $t8 now stores the offset of the 16th row.

add $t9, $t8, $t0	# add the offset ($t8) to the top left corner ($t0)
sw $t7, 0($t9) 		# paint the first unit on the 16th line
sw $t7, 64($t9) 	# paint the 16th unit on the 16th line


