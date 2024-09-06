#
#  Recursive Fibonacci calculator
# 
#  fibonacci(n) = fibonacci(n-1) + fibonacci(n-2)
#  fibonacci(0) = fibonacci(1) = 1
#

.data
fib_calls:		.word	0

.text
addi $t9, $zero, 20		# Set n = 20
addi $sp, $sp, -4		# Set stack pointer to empty stack location
sw $t9, 0($sp)			# Push input value n onto stack
jal fibonacci			# Call fibonacci(n)
lw $t9, 0($sp)			# Get fib(n) from top of stack
addi $sp, $sp, 4		# Move stack pointer to top of stack.

Exit:
li $v0, 10 # terminate the program gracefully
syscall


# Declare the Fibonacci function
fibonacci:
# $t0 = input parameter n
# $t1 = fib(n-1)
# $t2 = fib(n-2)
# $t8 = # of fib calls
# $t9 = throwaway temporary register

la $t9, fib_calls		# Get the address of the fib_calls variable
lw $t8, 0($t9)			# Fetch the number of fibonacci calls so far.
addi $t8, $t8, 1		# Increment the number of fibonacci calls
sw $t8, 0($t9)			# Store the updated number of fibonacci calls.

lw $t0, 0($sp)			# Get the input value n from the stack
addi $sp, $sp, 4		# Move stack pointer to top element of the stack

add $t9, $zero, $zero		# Set $t9 = 0
beq $t0, $t9, base_case		# If n == 0, go to base case
addi $t9, $zero, 1		# Set $t9 = 1
beq $t0, $t9, base_case		# If n == 1, go to base case
j recursive_case		# Otherwise, go to recursive case

base_case:
# Base case:  fib(0) = 1  and  fib(1) = 1
addi $sp, $sp, -4		# Move the stack pointer to an empty location
addi $t9, $zero, 1		# Store return value 1 into $t9
sw $t9, 0($sp)			# Push return value of 1 onto the stack
jr $ra				# Return to calling program

recursive_case:
# Recursive case:  fib(n) = fib(n-1) + fib(n-2)
addi $sp, $sp, -4		# Move the stack pointer to an empty location
sw $t0, 0($sp)			# Save $t0 register onto stack
addi $sp, $sp, -4		# Move the stack pointer to an empty location
sw $ra, 0($sp)			# Save $ra register onto stack
addi $t9, $t0, -1		# Calculate n-1
addi $sp, $sp, -4		# Move the stack pointer to an empty location
sw $t9, 0($sp)			# Push n-1 onto stack
jal fibonacci			# Call fib(n-1)
lw $t1, 0($sp)			# Pop return value fib(n-1) off stack
addi $sp, $sp, 4		# Move stack pointer to top element of stack
# Restore saved registers from stack
lw $ra, 0($sp)			# Pop return address register from stack
addi $sp, $sp, 4		# Move stack pointer to top element of stack
lw $t0, 0($sp)			# Pop $t0 off stack
addi $sp, $sp, 4		# Move stack pointer to top element of stack

# Save registers onto stack
addi $sp, $sp, -4		# Move the stack pointer to an empty location
sw $t0, 0($sp)			# Save $t0 register onto stack
addi $sp, $sp, -4		# Move the stack pointer to an empty location
sw $t1, 0($sp)			# Save $t1 register onto stack
addi $sp, $sp, -4		# Move the stack pointer to an empty location
sw $ra, 0($sp)			# Save $ra register onto stack
addi $t9, $t0, -2		# Calculate n-2
addi $sp, $sp, -4		# Move the stack pointer to an empty location
sw $t9, 0($sp)			# Push n-2 onto stack
jal fibonacci			# Call fib(n-2)
lw $t2, 0($sp)			# Pop return value fib(n-2) off stack
addi $sp, $sp, 4		# Move stack pointer to top element of stack
# Restore saved registers from stack
lw $ra, 0($sp)			# Pop return address register from stack
addi $sp, $sp, 4		# Move stack pointer to top element of stack
lw $t1, 0($sp)			# Pop $t1 off stack
addi $sp, $sp, 4		# Move stack pointer to top element of stack
lw $t0, 0($sp)			# Pop $t0 off stack
addi $sp, $sp, 4		# Move stack pointer to top element of stack

add $t9, $t1, $t2		# Add fib(n-1) and fib(n-2)
addi $sp, $sp, -4		# Move the stack pointer to an empty location
sw $t9, 0($sp)			# Push return value fib(n) onto stack
jr $ra				# Return to calling program.
