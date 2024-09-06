#
# Demo code for recursive factorial
#
# factorial(n) = factorial(n-1) * n
# factorial(0) = 1
#

.data

.text
#
# $t0 = input value to the factorial function (x)
# $t1 = x-1 (before recursive call)
# $t1 = factorial(x-1)  (after recursive call)
#
main:
		addi $t0, $zero, 10	# first call: factorial(10)
		addi $sp, $sp, -4	# move the stack pointer
		sw $t0, 0($sp)		# push $t0 onto the stack
factorial:
		lw $t0, 0($sp)		# fetch input parameter x from stack
		addi $sp, $sp, 4		# put x into $t0
		bne $t0, $zero, recursive_case	# Check the base case (x==0)
base_case:	addi $t0, $zero, 1	# store return value in $t0
		addi $sp, $sp, -4	# move the stack pointer
		sw $t0, 0($sp)		# push $t0 onto the stack
		jr $ra			# return to the calling program
recursive_case:
		addi $t1, $t0, -1	# otherwise, calculate x-1
		addi $sp, $sp, -4	# save $ra onto the stack
		sw $ra, 0($sp)
		addi $sp, $sp, -4	# save $t0 onto the stack
		sw $t0, 0($sp)
		addi $sp, $sp, -4	# push (x-1) onto stack (input parameter)
		sw $t1, 0($sp)
		jal factorial		# call factorial(x-1)
		lw $t1, 0($sp)		# pop factorial(x-1) from stack (output parameter)
		addi $sp, $sp, 4		# move the stack pointer
		lw $t0, 0($sp)		# restore $t0
		addi $sp, $sp, 4		# move the stack pointer
		lw $ra, 0($sp)		# restore $ra
		addi $sp, $sp, 4		# move the stack pointer
		mult $t1, $t0		# multiply factorial(x-1) by x
		mflo $t2			# fetch result from LO register
		addi $sp, $sp, -4	# push return value onto stack
		sw $t2, 0($sp)
		jr $ra			# return factorial(x)
