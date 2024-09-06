################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Frederick Meneses, 1006986781
# Student 2: Name, Student Number
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       4
# - Unit height in pixels:      4
# - Display width in pixels:    128
# - Display height in pixels:   128
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################

game_started: .word 0       

COLOURS:
    .word 0xc9ced1  # Greenish-Grey (Walls and Baal)
    .word 0x5e51ed  # Blue (Paddle)
    .word 0x000000	# Black (Erased)
    .word 0x10e0dd  # Cyan
    .word 0x921db5  # Purple
    .word 0xffa500  # Orange
    .word 0x0ecca3  # Prismarine
    .word 0xf5ec73  # Yellow (Unbreakable)


PADDLE_POS:
    .word 13 # x
    .word 28 # y

BALL_POS:
    # .word 15 # x
    # .word 27 # y
    .word 15
    .word 26
    
BALL_DIR:
    .word 1    # change in x direction of the ball: dx
    .word -1   # change in y direction of the ball: dy
    
BRICK_WIDTH: 3
BRICK_HEIGHT: 1

CURR_SCORE: 0
SLEEP_RATE: 200

    
##############################################################################
# Code
##############################################################################
	.text
	.globl main
    
	# Run the Brick Breaker game.
main:
    # Initialize the game
    jal draw_start
    b game_loop
    
Exit:
    li $v0, 10              # terminate the program gracefully
    syscall
    
game_loop:
    ###############
    # MILESTONE 2 #
    ###############

	# 1a. Check if key has been pressed
	li 		$v0, 32
    li 		$a0, 1
    syscall
    
	lw $t0, ADDR_KBRD                     # $t0 = base address for keyboard
    lw $t8, 0($t0)                        # Load first word from keyboard
    beq $t8, 1, keyboard_input            # If first word 1, key is pressed
    
    lw $t9, game_started
    # bne $t8, 0, update_ball_pos  # If keyboard input buffer is not empty, skip ball update
    beqz $t9, game_loop          # If game has not started yet, wait for spacebar press
    jal update_ball_pos          # Update ball position
    lw $t9, CURR_SCORE
    beq $t9, 20, Exit
    j continue_game_loop
    # 1b. Check which key has been pressed
    
    ###########
    # Settings
    ###########
    
    ##
    # Respond to spacebar. 
    # registers: s3
    ##
    respond_to_Space: # Start the game.
        li $t9, 1                  # Set game_started to true
        sw $t9, game_started
        j game_loop
    
    ##
    # respond_to_Q() -> void
    # Allow the player to quit the game.
    ##  
    respond_to_Q: # Quit the game.
    	b Exit
	    
    #######################
    # Keys to move the ball
    #######################
    respond_to_W: # Move ball up:
    
    respond_to_A: # Move ball left.
    
    respond_to_S: # Move ball down    
    
    respond_to_D: # Move ball right.
    
    
    # 2a. Check for collisions
    
    #
    # Check if square is a different colour.
    #
    
    # 2b. Update locations (paddle, ball)
    # lw $t0, BALL_POS + 8		# get the direction of current ball movement
    #########################
    # Keys to move the paddle
    #########################
    respond_to_left: # Move left.
        move $s0, $ra
        li $v0, 1
        syscall
        
        lw $t8, PADDLE_POS          # Load paddle position x into $t8.

        beq $t8, 1, end_move        # Boundary Check: PADDLE_POS[0] > 1
        addi $t8, $t8, -1           # Paddle moving Left

        jal erase_paddle            # Erase paddle.
        sw $t8, PADDLE_POS          # Store new paddle position in data.
        
        # Draw paddle at new location
        addi $sp, $sp, -4
        lw $t0, COLOURS + 4
        sw $t0, 0($sp)
        
        jal draw_paddle
        
        lw $t9, game_started
        beq $t9, 1, end_move
        
        lw $t7, BALL_POS
        addi $t7, $t7, -1           # Ball moving Left
        
        jal erase_ball
        sw $t7, BALL_POS
        
        # Draw ball at new location
        addi $sp, $sp, -4
        lw $t0, COLOURS
        sw $t0, 0($sp)
        
        jal draw_ball
        
        move $ra, $s0
        
        jr $ra
        
	respond_to_right: # Move right.
        move $s0, $ra
        li $v0, 1
        syscall
        
        lw $t8, PADDLE_POS          # Load paddle position x into $t8.
        beq $t8, 26, end_move       # Boundary Check: PADDLE_POS[0] < 27
        addi $t8, $t8, 1            # Paddle moving Right
        jal erase_paddle            # Erase paddle
        sw $t8, PADDLE_POS          # Store new paddle position in data.
        
        # Draw paddle at new location.
        addi $sp, $sp, -4
        lw $t0, COLOURS + 4
        sw $t0, 0($sp)
        
        jal draw_paddle
        
        # if game has not started
        lw $t9, game_started
        beq $t9, 1, end_move
        
        lw $t7, BALL_POS
        addi $t7, $t7, 1           # Ball moving Right
        
        jal erase_ball
        sw $t7, BALL_POS
        
        # Draw ball at new location
        addi $sp, $sp, -4
        lw $t0, COLOURS
        sw $t0, 0($sp)
        
        jal draw_ball
        
        move $ra, $s0
        
        # If ball hasn't started.
        jr $ra
    

	# 3. Draw the screen
	#
    # Re-paint the screen in a loop to visualize movement.
    #    


	# 4. Sleep
	continue_game_loop:

    #5. Go back to 1
        b game_loop

end_move:
    j game_loop
    
draw_start:
    lw $t0, ADDR_DSPL     	         # $t0 stores the base address for display
    move $s0, $ra
    jal draw_walls
    
    # coordinate_address arguments        # DRAW CYAN BRICKS
    addi $sp, $sp, -4
    addi $t1, $zero, 3
    sw $t1, 0($sp)
    
    addi $sp, $sp, -4
    addi $t1, $zero, 8
    sw $t1, 0($sp)
    
    jal coordinate_address
    
    # draw_bricks arguments
    addi $sp, $sp, -4
    addi $t1, $v0, 0
    sw $t1, 0($sp)

    addi $sp, $sp, -4
    lw $t1, COLOURS + 12
    sw $t1, 0($sp)

    addi $sp, $sp, -4
    lw $t1, BRICK_WIDTH
    sw $t1, 0($sp)

    addi $sp, $sp, -4
    add $t1, $zero, 7
    sw $t1, 0($sp)
    
    jal draw_bricks
    
    # coordinate_address arguments         # DRAW PURPLE BRICKS
    addi $sp, $sp, -4
    addi $t1, $zero, 5
    sw $t1, 0($sp)
    
    addi $sp, $sp, -4
    addi $t1, $zero, 9
    sw $t1, 0($sp)
    
    jal coordinate_address
    
    # draw_bricks arguments
    addi $sp, $sp, -4
    addi $t1, $v0, 0
    sw $t1, 0($sp)

    addi $sp, $sp, -4
    lw $t1, COLOURS + 16
    sw $t1, 0($sp)

    addi $sp, $sp, -4
    lw $t1, BRICK_WIDTH
    sw $t1, 0($sp)

    addi $sp, $sp, -4
    add $t1, $zero, 6
    sw $t1, 0($sp)
    
    jal draw_bricks
    
    # coordinate_address arguments         # DRAW ORANGE BRICKS
    addi $sp, $sp, -4
    addi $t1, $zero, 3
    sw $t1, 0($sp)
    
    addi $sp, $sp, -4
    addi $t1, $zero, 10
    sw $t1, 0($sp)
    
    jal coordinate_address
    
    # draw_bricks arguments
    addi $sp, $sp, -4
    addi $t1, $v0, 0
    sw $t1, 0($sp)

    addi $sp, $sp, -4
    lw $t1, COLOURS + 20
    sw $t1, 0($sp)

    addi $sp, $sp, -4
    lw $t1, BRICK_WIDTH
    sw $t1, 0($sp)

    addi $sp, $sp, -4
    add $t1, $zero, 7
    sw $t1, 0($sp)
    
    jal draw_bricks
    addi $sp, $sp, -4
    lw $t1, COLOURS
    sw $t1, 0($sp)
    jal draw_ball
    
    addi $sp, $sp, -4
    lw $t1, COLOURS + 4
    sw $t1, 0($sp)
    jal draw_paddle
    
    move $ra, $s0
    jr $ra
    
###############
# MILESTONE 1 #
###############

##
# Draw the three walls.
# registers: t1, s1
##
draw_walls:
    lw $t1, COLOURS                 # $t1 stores the greenish-grey colour code
    
    # Draw the top wall.
    move $s1, $ra                   # Save instructions.
    
    # Pass input arguments of draw_horizontal_line onto the stack.
    addi $sp, $sp, -4
    lw $t0, ADDR_DSPL               # Set start address
    sw $t0, 0($sp)
    
    addi $sp, $sp, -4
    sw $t1, 0($sp)                  # Set colour = $t1
    
    addi $sp, $sp, -4
    addi $t0, $zero, 32 	        # Set width = 32 
    sw $t0, 0($sp)
    
    jal draw_horizontal_line
    move $ra, $s1
    
    # Draw the side walls.
    move $s1, $ra
    addi $a1, $t1, 0
    addi $a2, $zero, 30	            # Set height = 30
    li $a3, 1 	                    # Set width = 1
    jal draw_sides
    move $ra, $s1
    
    jr $ra

##
# draw_sides(start, colour, height, width) -> void
# Draw the side walls.
# registers: t1, t5, t6
##
draw_sides:
    # Grab the colour.
    lw $t1, COLOURS
    
    # Draw the side walls.
    add $t5, $zero, $zero	        # Set index value ($t5) to zero
    add $t6, $zero, $zero	        # Set index value ($t6) to zero
    j draw_sides_loop
    
    draw_sides_loop:
    beq $t6, $a2, end_sides_loop  	# If $t6 == height ($a0), jump to end
    
    # Draw two dots:
    add $t5, $zero, $zero	        # Set index value ($t5) to zero
    sw $t1, 0($a0)	            	#   - Draw a pixel at memory location $t0
    addi $a0, $a0, 124              #   - Move $t0 to the last pixel of the line.
    sw $t1, 0($a0)	            	#   - Draw a pixel at memory location $t0
    addi $a0, $a0, 4                #   - Set $t0 to the first pixel of the next line.
    addi $t6, $t6, 1                #   - Increment $t6 by 1
    j draw_sides_loop

    end_sides_loop:
        jr $ra

##
# draw_bricks(start, colour_address, length_bricks, num_bricks) -> void
# Draw all the bricks. There should be at least three rows of bricks and at least three different 
# coloured bricks (and a non-trivial number of bricks in each row).
# registers: t0, t1, t5, t6
##
draw_bricks:
    # Retrieve function arguments
    lw $a3, 0($sp)
    addi $sp, $sp, 4
    
    lw $a2, 0($sp)
    addi $sp, $sp, 4
    
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    
    add $t6, $zero, $zero	         # Set index value ($t6) to zero
    draw_bricks_loop:
    slt $t4, $t6, $a3                # if i < num_bricks
    beq $t4, $zero, end_draw_bricks     # else return
    
    # Store arguments in different registers
    addi $t0, $a0, 0
    addi $t1, $a1, 0
    addi $t2, $a2, 0
    
    # Prepare inner function call.
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # draw_horizontal_line arguments
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    jal draw_horizontal_line
    
    # Teardown
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    addi $a0, $a0, 4              # Brick spacing
    
    add $t6, $t6, 1               # Increment counter ($t6)
    b draw_bricks_loop
    
    end_draw_bricks:
        jr $ra
    
##
# draw_ball(colour) -> 
# Draw the ball (at some initial location)
# registers: 
# - $a0: Colour address.
# - $t0: Ball position.
# - $v0: update.
##
draw_ball:
    lw $a0, 0($sp)               # Pop colour address from stack and load into $a0.
    addi $sp, $sp, 4             # Move stack pointer to top element.
    
    addi $t2, $a0, 0             # $t2 stores colour.
    
    # Prepare inner function call.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $ra, 0($sp)               # Store call instruction on stack.
    
    # Pass input arguments of coordinate_address onto the stack.
    la $t0, BALL_POS             # Store the ball position in $t0.
    
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    lw $t1, 0($t0)               # Load $t0: x-position into $t1.
    sw $t1, 0($sp)               # Load $t1 onto the stack.
    
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    lw $t1, 4($t0)               # Load $t0: y-position into $t1.
    sw $t1, 0($sp)               # Load $t1 onto the stack.
    
    jal coordinate_address       # Get the memory address in $v0.
    
    lw $ra, 0($sp)               # Pop off call instruction from stack.
    addi $sp, $sp, 4             # Move stack pointer to top element.
    
    sw $t2, 0($v0)	             # Draw a pixel at memory location $v0.
    
    end_draw_ball:
        jr $ra                   # Function return.
    
##
# HELPER: erase_ball() -> void
# Erase the ball.
# registers: t0
##
erase_ball:
    lw $t0, COLOURS + 8          # Store the colour black in $t0.
    
    # Prepare inner function call.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $ra, 0($sp)               # Store call instruction on stack.
    
    # Pass input arguments of draw_ball onto the stack.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $t0, 0($sp)               # Load $t0: colour black into $t1.
    jal draw_ball                # Erase the ball.
    
    lw $ra, 0($sp)               # Pop off call instruction from stack.
    addi $sp, $sp, 4             # Move stack pointer to top element.
    
    end_erase_ball:
        jr $ra                   # Function return.
    
##
# draw_paddle(colour) -> void
# Draw the paddle.
# registers:
# - $t0: Colour
# - $t1: Paddle Position
# - $v0: coordinate address
##
draw_paddle:
    lw $a0, 0($sp)               # Pop colour address from stack and load into $a0.
    addi $sp, $sp, 4             # Move stack pointer to top element.
    
    addi $t0, $a0, 0             # Store $a0 in a different register $t0. 
    # Prepare inner function call.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $ra, 0($sp)               # Store call instruction on stack.
    
    # Pass input arguments of draw_ball onto the stack.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    lw $t1, PADDLE_POS           # Load the paddle position into $t1.
    sw $t1, 0($sp)               # Load $t1 onto the stack.
    
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    lw $t1, PADDLE_POS + 4       # Load the paddle position into $t1.
    sw $t1, 0($sp)               # Load $t1 onto the stack.
    
    jal coordinate_address
    
    # Teardown
    lw $ra, 0($sp)               # Pop off call instruction from stack.
    addi $sp, $sp, 4             # Move stack pointer to top element.
    
    # Prepare inner function call.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $ra, 0($sp)               # Store call instruction on stack.
    
    # Pass input arguments of draw_horizontal_line onto the stack.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $v0, 0($sp)

    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $t0, 0($sp)
    
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    addi $t2, $zero, 5           # set width = 5
    sw $t2, 0($sp)
    
    jal draw_horizontal_line
    
    # Teardown
    lw $ra, 0($sp)               # Pop off call instruction from stack.
    addi $sp, $sp, 4             # Move stack pointer to top element.
    
    end_draw_paddle:
        jr $ra
##
# HELPER: erase_paddle() -> void:
# Erase the paddle.
# registers: t9
##
erase_paddle:
    # Prepare inner function call.
    move $s2, $ra
    
    # draw_paddle arguments
    addi $sp, $sp, -4
    lw $t9, COLOURS + 8
    sw $t9, 0($sp)
    
    jal draw_paddle
    
    # Teardown
    move $ra, $s2
    
    jr $ra        # Function return.

##
# HELPER: erase_brick(x, y) -> void:
#
#
##
erase_brick:    
    lw $a0, 0($sp)               # Pop off argument 0: x
    addi $sp, $sp, 4             # Move stack pointer to top element.
    
    # Prepare inner function call.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $ra, 0($sp)               # Store call instruction on stack.

    # Store $a0 onto the stack to use later
    addi $sp, $sp, -4            
    sw $a0, 0($sp)
    
    # if brick is orange, then make t5 purple
    lw $t5, COLOURS + 20
    lw $s0, 0($a0)
    beq $s0, $t5, make_purple
    # if brick is purple, then make t5 cyan
    lw $t5, COLOURS + 16
    beq $s0, $t5, make_cyan
    # else make t5 black
    b make_black
    
    make_purple:
    lw $t5, COLOURS + 16
    b continue_erase_brick
    make_cyan:
    lw $t5, COLOURS + 12
    b continue_erase_brick
    make_black:
    b add_score
        continue_black:
        add $t5, $zero, $zero
    
    continue_erase_brick:
    lw $a0, 0($sp)               # Pop off argument 0: x
    addi $sp, $sp, 4             # Move stack pointer to top element.
    
    # Pass input arguments of draw_horizontal_line onto the stack.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $a0, 0($sp)               # Load $a0 onto the stack.
    
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $t5, 0($sp)               # Load $t1 onto the stack.
    
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    addi $t5, $zero, 3
    sw $t5, 0($sp)               # Load $t1 onto the stack.
    
    jal draw_horizontal_line
    
    b return             # Function return.

##
# HELPER: add_score
##
add_score:
    # Pass input arguments of coordinate_address onto the stack.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    addi $s4, $s4, 1         # Load the paddle position into $t1.
    sw $s4, 0($sp)               # Load $t1 onto the stack.
    
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    addi $s4, $zero, 31     # Load the paddle position into $t1.
    sw $s4, 0($sp)               # Load $t1 onto the stack.
    
    jal coordinate_address
    
    # update score
    lw $s5, CURR_SCORE
    addi $s5, $s5, 1
    sw $s5, CURR_SCORE
    
    # if value at v0 is not 0 loop at add 4 to v0
    lw $s5, COLOURS + 24
    add_one_loop:
        lw $s4, 0($v0)
        beq $s4, 0, score_continue
        addi $s5, $s5, 100
        addi $v0, $v0, 4
        b add_one_loop
    
    score_continue:
    # Pass input arguments of draw_horizontal_line onto the stack.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    addi $a0, $v0, 0
    sw $a0, 0($sp)               # Load $a0 onto the stack.
    
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    addi $t5, $s5, 0
    sw $t5, 0($sp)               # Load $t1 onto the stack.
    
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    addi $t5, $zero, 1
    sw $t5, 0($sp)               # Load $t1 onto the stack.
    
    jal draw_horizontal_line
    
    j continue_black
    
##
# HELPER: erase_unit(x, y) -> void.
##
erase_unit:
    lw $t0, COLOURS + 8          # Store the colour black in $t0.
    
    # Grab arguments.
    addi $sp, $sp, 4             # Move stack pointer to top element.
    lw $a1, 0($sp)               # Pop off argument 1: y
    
    addi $sp, $sp, 4             # Move stack pointer to top element.
    lw $a0, 0($sp)               # Pop off argument 0: x
    
    # Prepare inner function call.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $ra, 0($sp)               # Store call instruction on stack.
    
    # Pass input arguments of coordinate_address onto the stack.
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $a0, 0($sp)               # Load $t1 onto the stack.
    
    addi $sp, $sp, -4            # Move stack pointer to next empty location.
    sw $a1, 0($sp)               # Load $t1 onto the stack.
    
    jal coordinate_address
    
    lw $ra, 0($sp)               # Pop off call instruction from stack.
    addi $sp, $sp, 4             # Move stack pointer to top element.
    end_erase_unit:
        jr $ra                   # Function return.
    
##
# HELPER: draw_horizontal_line(address start, colour, int width) -> void
# Draw a horizontal line. 
# registers: t0, t1
##
draw_horizontal_line:
    # Retrieve function arguments.
    lw $a2, 0($sp)
    addi $sp, $sp, 4
    
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    
    add $t1, $zero, $zero            # index ($t1) = 0
    draw_horizontal_line_loop:
    beq $t1, $a2, end_horizontal_line
    sw $a1, 0($a0)	    	         #   - Draw a pixel at memory location $t0
    addi $a0, $a0, 4	             #   - next unit
    addi $t1, $t1, 1	             #   - index ($t1) += 1
    j draw_horizontal_line_loop
    
    end_horizontal_line:
        jr $ra

##
# HELPER: coordinate_address(int x, int y) -> address;
# Grab memory address of location.
#     param: $a0 = x
#     param: $a1 = y
#     return: $v0 address
# registers: none
##
coordinate_address:
    # Arguments
    lw $a1, 0($sp)
    addi $sp, $sp, 4             # Move stack pointer to top element.
    
    lw $a0, 0($sp)
    addi $sp, $sp, 4             # Move stack pointer to top element.
    
    # Logic
	sll $a0, $a0, 2		      	 # a0 = a0 * 4 * 1 (a0 = x * 4)
	sll $a1, $a1, 7			     # a1 = a1 * 4 * 64 (a1 = y * 128)

	lw $v0, ADDR_DSPL		     # v0 = ADDR_DSPL
	add $v0, $v0, $a0		     # v0 += a0 
	add $v0, $v0, $a1		     # v0 += a1 (v0 is now ADDR_DSPL[0] + (x*4) + (y*4*64))
    
    jr $ra                       # Function return.

##
# keyboard_input() -> void.
# Move paddle using keyboard input.
##
keyboard_input: # A key is pressed
    lw $a0, 4($t0)                    # Load second word from keyboard
    lw $t8, 4($t0)
    beq $a0, 0x71, respond_to_Q       # Check if the key Q was pressed
    beq $a0, 0x61, respond_to_A       # Check if the key A was pressed
    beq $a0, 0x64, respond_to_D       # Check if the key D was pressed
    beq $a0, 0x20, respond_to_Space   # Check if the key Space was pressed
    beq $a0, 0x68, respond_to_left    # Check if the key H was pressed
    beq $a0, 0x6C, respond_to_right   # Check if the key L was pressed

    li $v0, 1                         # ask system to print $a0
    syscall
    jr $ra

#
# Move the ball in any direction (no collisions yet).
#
#################
# Ball Locations.
#################
# Update ball position based on its direction
# Arguments: none
update_ball_pos:
    addi $sp, $sp, -4   # Reserve space for the return address
    sw $ra, 0($sp)      # Save the return address
    
    # Load ball position and direction and save them to the stack.
    addi $sp, $sp, -4
    lw $t0, BALL_POS
    sw $t0, 0($sp)
    
    addi $sp, $sp, -4
    lw $t1, BALL_POS + 4
    sw $t1, 0($sp)
    
    addi $sp, $sp, -4
    lw $t2, BALL_DIR
    sw $t2, 0($sp)
    
    addi $sp, $sp, -4
    lw $t3, BALL_DIR + 4
    sw $t3, 0($sp)
    
    # Erase the old ball
    jal erase_ball
    
    # Restore temp variables
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    addi $s6, $t0, 0
    addi $s7, $t1, 0
    
    jal collision_left
    jal collision_right
    jal collision_bottom
    jal collision_top
    
    continue_update:
    # Update ball position based on direction
    add $t0, $s6, $t2  # Update x position
    add $t1, $s7, $t3  # Update y position
    
    sw $t0, BALL_POS
    sw $t1, BALL_POS + 4
    
    # Load ball position and direction and save them to the stack.   
    addi $sp, $sp, -4
    lw $t2, BALL_DIR
    sw $t2, 0($sp)
    
    addi $sp, $sp, -4
    lw $t3, BALL_DIR + 4
    sw $t3, 0($sp)
    
    # Check for collision with paddle
    lw $t4, PADDLE_POS                          # Load paddle x-position
    lw $t5, PADDLE_POS + 4                      # Load paddle y-position
    addi $t5, $t5, 1                            # Adjust paddle y position by 1 for collision detection
    
    bgt $t1, $t5, skip_paddle_collision         # Ball is below the paddle
    blt $t0, $t4, skip_paddle_collision         # Ball is left of the paddle
    bgt $t0, $t4, skip_paddle_collision         # Ball is right of the paddle
    
    # Ball has collided with the paddle, reflect up
    addi $t1, $t5, -1                           # Move the ball above the paddle
    # j reflect_x                                  # Reflect up
    
skip_paddle_collision:
    # Draw ball arguments
    addi $sp, $sp, -4
    lw $a0, COLOURS
    sw $a0, 0($sp)
    
    jal draw_ball
    
    # Restore temp variables
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    
    # Update ball direction
    sw $t2, BALL_DIR
    sw $t3, BALL_DIR + 4
    
    # Restore the return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
	
	# Sleep
    li $v0, 32
    lw $a0, SLEEP_RATE
    syscall
    
    jr $ra

reflect_x:
    lw $t2, BALL_DIR
    neg $t2, $t2     # Flip the x component of the direction vector
    sw $t2, BALL_DIR
    jr $ra
    
reflect_y:
    lw $t3, BALL_DIR + 4
    neg $t3, $t3     # Flip the y component of the direction vector
    sw $t3, BALL_DIR + 4
    jr $ra

reflect_y_far:
    lw $t3, BALL_DIR + 4
    neg $t3, $t3     # Flip the y component of the direction vector
    sw $t3, BALL_DIR + 4
    jr $ra

# if get address from the left is a certain colour then flip the velocity
collision_left:
    # Prepare inner function call.
    addi $sp, $sp, -4            # Move stack pointer to top element.
    sw $ra, 0($sp)
    
    # coordinate_address arguments
    addi $sp, $sp, -4            # Move stack pointer to top element.
    addi $t8, $t0, -1
    sw $t8, 0($sp)
    
    addi $sp, $sp, -4            # Move stack pointer to top element.
    addi $t9, $t1, 0
    sw $t9, 0($sp)
    jal coordinate_address
    
    # Teardown
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    lw $t7, 0($v0)               # Get colour from address.
    
    # Compare colours
    lw $s0, COLOURS              # Setup wall colour in saved register $s0.
    lw $s1, COLOURS + 4          # Setup paddle colour in saved register $s1.
    lw $s2, COLOURS + 8          # Setup erase colour in saved register $s2.
    
    beq $t7, $s0, reflect_x
    beq $t7, $s1, reflect_x
    beq $t7, $s2, end_collision_left
    
    j collision_brick_left
    collision_brick_left:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        # get the address of the first brick loop
        first_brick_loop: 
        lw $s5, -4($v0)
        beq $s5, $s2, end_first_brick_loop
        addi $v0, $v0, -4
        b first_brick_loop
        
        addi $sp, $sp, -4
        addi $t7, $v0, 0
        sw $t7, 0($sp)
        
        jal erase_brick
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
        b reflect_x
        
    end_collision_left:
        jr $ra

    
collision_right:
    # Prepare inner function call.
    addi $sp, $sp, -4            # Move stack pointer to top element.
    sw $ra, 0($sp)
    
    # coordinate_address arguments
    addi $sp, $sp, -4            # Move stack pointer to top element.
    addi $t8, $t0, 1
    sw $t8, 0($sp)
    
    addi $sp, $sp, -4            # Move stack pointer to top element.
    addi $t9, $t1, 0
    sw $t9, 0($sp)
    jal coordinate_address
    
    # Teardown
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    lw $t7, 0($v0)               # Get colour from address.
    
    # Compare colours
    lw $s0, COLOURS              # Setup wall colour in saved register $s0.
    lw $s1, COLOURS + 4          # Setup paddle colour in saved register $s1.
    lw $s2, COLOURS + 8          # Setup erase colour in saved register $s2.
    
    beq $t7, $s0, reflect_x
    beq $t7, $s1, reflect_x
    beq $t7, $s2, end_collision_right
    
    j collision_brick_right
    collision_brick_right:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        addi $sp, $sp, -4
        addi $t7, $v0, 0
        sw $t7, 0($sp)
        
        jal erase_brick
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
        b reflect_x
        
    end_collision_right:
        jr $ra
    
collision_bottom:
    # Prepare inner function call.
    addi $sp, $sp, -4            # Move stack pointer to top element.
    sw $ra, 0($sp)
    
    # coordinate_address arguments
    addi $sp, $sp, -4            # Move stack pointer to top element.
    addi $t8, $t0, 0
    sw $t8, 0($sp)
    
    addi $sp, $sp, -4            # Move stack pointer to top element.
    addi $t9, $s7, 1
    sw $t9, 0($sp)
    jal coordinate_address
    
    # Teardown
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    lw $t7, 0($v0)               # Get colour from address.
    lw $t6, BALL_POS + 4         # Get ball y position.
    
    # Compare colours
    lw $s0, COLOURS              # Setup wall colour in saved register $s0.
    lw $s1, COLOURS + 4          # Setup paddle colour in saved register $s1.
    lw $s2, COLOURS + 8          # Setup erase colour in saved register $s2.
    addi $s3, $zero, 27            # Setup erase colour in saved register $s3.
    
    beq $t7, $s0, reflect_y
    beq $t7, $s1, collision_paddle_bottom
    bgt $t6, $s3, collision_end
    beq $t7, $s2, end_collision_bottom
    
    j collision_brick_bottom
    collision_brick_bottom:
        addi $sp, $sp, -4
        sw $ra, 0($sp)
        
        # get the address of the first brick loop
        first_brick_loop: 
        lw $s5, -4($v0)
        beq $s5, $s2, end_first_brick_loop
        addi $v0, $v0, -4
        b first_brick_loop
        
        addi $sp, $sp, -4
        addi $t7, $v0, 0
        sw $t7, 0($sp)
        
        jal erase_brick
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
        b reflect_y
    
    collision_paddle_bottom:

        lw $t5, PADDLE_POS 
        lw $t6, BALL_POS
        beq $t5, $t6, reflect_y_sharp_left
        addi $t5, $t5, 1
        beq $t5, $t6, reflect_y_normal_left
        addi $t5, $t5, 1
        beq $t5, $t6, reflect_y_up
        addi $t5, $t5, 1
        beq $t5, $t6, reflect_y_normal_right
        addi $t5, $t5, 1
        beq $t5, $t6, reflect_y_sharp_right
        
        # if ball is at x position then bounce straight up
        reflect_y_up:
        lw $t3, BALL_DIR
        addi $t3, $zero, 0     # Change x velocity to bounce straight up.
        sw $t3, BALL_DIR   
        
        lw $t3, BALL_DIR + 4
        addi $t3, $zero, -1     # Flip y component to bounce straight up.
        sw $t3, BALL_DIR + 4
        jr $ra
       
        # if ball is +1 paddle x position then change 
        reflect_y_normal_left:
        lw $t3, BALL_DIR
        beq $t3, 0, left_change
        b left_change_one
        left_change:
            addi $t3, $zero, -1     # Change x velocity to bounce straight up.
            sw $t3, BALL_DIR
            lw $t3, BALL_DIR + 4
            neg $t3, $t3
            sw $t3, BALL_DIR + 4
            b end_collision_bottom
        left_change_one:
        lw $t3, BALL_DIR + 4
        addi $t3, $zero, -2        # Flip y component to bounce straight up.
        sw $t3, BALL_DIR + 4
        jr $ra
        
        reflect_y_normal_right:
        lw $t3, BALL_DIR
        beq $t3, 0, right_change
        b right_change_one
        right_change:
            addi $t3, $zero, 1     # Change x velocity to bounce straight up.
            sw $t3, BALL_DIR
            lw $t3, BALL_DIR + 4
            neg $t3, $t3
            sw $t3, BALL_DIR + 4
            b end_collision_bottom
        right_change_one:
        lw $t3, BALL_DIR + 4
        addi $t3, $zero, -2        # Flip y component to bounce straight up.
        sw $t3, BALL_DIR + 4
        jr $ra
        

        # if ball is +2 paddle x position then change 
        reflect_y_sharp_left:
        lw $t3, BALL_DIR
        beq $t3, 0, left_change
        lw $t3, BALL_DIR + 4
        addi $t3, $zero, -1        # Flip y component to bounce straight up.
        sw $t3, BALL_DIR + 4
        jr $ra
        
        reflect_y_sharp_right:
        lw $t3, BALL_DIR
        beq $t3, 0, right_change
        lw $t3, BALL_DIR + 4
        addi $t3, $zero, -1        # Flip y component to bounce straight up.
        sw $t3, BALL_DIR + 4
        jr $ra
        
        b reflect_y
    end_collision_bottom:
        jr $ra
        
    collision_end:
        j Exit

collision_top:
    # Prepare inner function call.
    addi $sp, $sp, -4            # Move stack pointer to top element.
    sw $ra, 0($sp)
    
    # coordinate_address arguments
    addi $sp, $sp, -4            # Move stack pointer to top element.
    addi $t8, $t0, 0
    sw $t8, 0($sp)
    
    addi $sp, $sp, -4            # Move stack pointer to top element.
    addi $t9, $t1, -1
    sw $t9, 0($sp)
    jal coordinate_address
    
    # Teardown
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    lw $t7, 0($v0)               # Get colour from address.
    
    # Compare colours
    lw $s0, COLOURS              # Setup wall colour in saved register $s0.
    lw $s1, COLOURS + 4          # Setup paddle colour in saved register $s1.
    lw $s2, COLOURS + 8          # Setup erase colour in saved register $s2.
    
    beq $t7, $s0, reflect_y
    beq $t7, $s1, reflect_y
    beq $t7, $s2, end_collision_top
     
    b collision_brick_top
    collision_brick_top:
        addi $sp, $sp, -4
        sw $ra, 0($sp)       
                
        # get the address of the first brick loop
        first_brick_loop: 
        lw $s5, -4($v0)
        beq $s5, $s2, end_first_brick_loop
        addi $v0, $v0, -4
        b first_brick_loop
        
        end_first_brick_loop:
        addi $sp, $sp, -4
        addi $t7, $v0, 0
        sw $t7, 0($sp)
        
        jal erase_brick
        
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
        b reflect_y
        
    end_collision_top:    
        jr $ra

corner_collision:
    # Prepare inner function call.
    addi $sp, $sp, -4            # Move stack pointer to top element.
    sw $ra, 0($sp)
    
    # coordinate_address arguments
    addi $sp, $sp, -4            # Move stack pointer to top element.
    addi $t8, $t0, 0
    sw $t8, 0($sp)
    
    addi $sp, $sp, -4            # Move stack pointer to top element.
    addi $t9, $t1, -1
    sw $t9, 0($sp)
    jal coordinate_address

return:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra