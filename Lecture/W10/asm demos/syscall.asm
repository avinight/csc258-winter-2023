#
#  Demonstration code for syscall (and a few other things)
#

.data
str1:	 	.asciiz  "Hello "
str2:		.asciiz  "World"

.text
# print "Hello World"
la $a0, str1
li $v0, 4
syscall
la $a0, str2
li $v0, 4
syscall

# Get random number
li $v0, 42
li $a0, 0
li $a1, 100
syscall

# Go to sleep for 10 seconds
li $v0, 32
li $a0, 10000
syscall


Exit:
li $v0, 10 # terminate the program gracefully
syscall




