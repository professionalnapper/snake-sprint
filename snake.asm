.model small
    .stack 100h

    .data
        buffer db 2000 dup(0)
        ; Original Snake title coordinates
        snakeTitle  dw 182, 181, 180, 179, 178, 177, 176, 175, 255, 335
                    dw 415, 495, 496, 497, 498, 499, 500, 501, 502, 582
                    dw 662, 742, 822, 821, 820, 819, 818, 817, 816, 815
                    dw 825, 745, 665, 585, 505, 425, 345, 265, 185, 266
                    dw 347, 427, 508, 509, 590, 670, 751, 832, 752, 672
                    dw 592, 512, 432, 352, 272, 192, 835, 755, 675, 595
                    dw 515, 435, 355, 275, 195, 196, 197, 198, 199, 200
                    dw 201, 202, 282, 362, 442, 522, 602, 682, 762, 842
                    dw 516, 517, 518, 519, 520, 521, 205, 285, 365, 445
                    dw 525, 605, 685, 765, 845, 212, 291, 370, 449, 448
                    dw 527, 526, 608, 609, 690, 771, 852, 222, 221, 220
                    dw 219, 218, 217, 216, 215, 295, 375, 455, 535, 615
                    dw 695, 775, 855, 856, 857, 858, 859, 860, 861, 862
                    dw 536, 537, 538, 539, 540, 541, 542




        ; Sprint title coordinates
        sprintTitle dw 1064, 1065, 1066, 1067, 1068, 1069
                    dw 1144
                    dw 1224, 1225, 1226, 1227, 1228
                    dw 1308
                    dw 1388, 1387, 1386, 1385, 1384
                    dw 1071, 1151, 1231, 1311, 1391
                    dw 1072, 1073, 1074
                    dw 1155, 1235
                    dw 1232, 1233, 1234
                    dw 1077, 1157, 1237, 1317, 1397
                    dw 1078, 1079, 1080
                    dw 1160, 1240
                    dw 1238, 1239
                    dw 1319, 1400
                    dw 1082, 1162, 1242, 1322, 1402
                    dw 1084, 1164, 1244, 1324, 1404
                    dw 1165, 1246, 1327, 1408
                    dw 1088, 1168, 1248, 1328, 1408
                    dw 1092, 1172, 1252, 1332, 1412
                    dw 1090, 1091, 1092, 1093, 1094


        text_1 db "DEVELOPED BY DEVOOPS! (C) 2024", 0
        text_3 db "PRESS ANY KEY TO START", 0
        text_4 db "                      ", 0
        text_5 db "ENTER YOUR NAME: ", 0
        text_6 db "WELCOME, ", 0
        name_buffer db 20 dup(0)
        instructions db 0AH,0DH,"DIRECTIONS:", 0AH,0DH,"> Use w, a, s, and d to control your snake",0AH,0DH,"> Press P to pause/unpause",0AH,0DH,"> Use q anytime to quit$"
        ready_text db 0AH,0DH,"PRESS ANY KEY WHEN YOU'RE READY $"
        game_screen_msg db "Game screen placeholder - Press Q to quit$"
        paused db 0                    ; Pause state flag
        pause_msg db "GAME PAUSED - Press 'p' to continue", 0
        
        
        ; Game-specific constants
        left equ 0
        top equ 2
        row equ 25
        col equ 80
        right equ left+col
        bottom equ top+row
        
        ; Game variables
        quitmsg db "Type 'snake' to play again or 'exit' to exit the app.",0
        gameovermsg db "Game Over! No more lives :P ", 0
        score_display db "Final Score:  ", 0
        player_display db "Player: ", 0

        scoremsg db "Score: ",0
        head db '^',10,10
        body db '*',10,11,07h, '*',10,12,07h, 4*48 DUP(0)    ; Two segments with white color (07h)
        segmentcount dw 2   ; Start with 2 segments
        fruitactive db 0
        fruitx db 40
        fruity db 12
    fruit_colors db 0Ch, 0Eh, 0Ah, 0Bh, 0Dh  ; Array of colors (red, yellow, green, cyan, magenta)
        fruit_color db 0Ch    ; Initial color (bright red)
        gameover db 0
        quit db 0   
        delaytime db 5
        
        ; Lives system variables - make sure these are correctly defined
        lives db 3                  ; Start with 3 lives
        lives_msg db "Lives: ", 0
        heart_symbol db 3, 0        ; ASCII heart symbol
        lost_life_msg db "Oops! Life lost! Press any key to continue...$", 0  ; Added $ terminator
        respawn_msg db "Respawning snake...$", 0  ; Added $ terminator
        
        current_score db 0    ; Variable to maintain score across lives
        
        ; Save initial snake position for respawning
        initial_head_x db 10
        initial_head_y db 10

    .code
    main proc                       ; Main procedure - program entry point
    mov ax, @data              ; Get address of data segment
    mov ds, ax                 ; Set DS register to point to our data segment

    mov ax, 0003h              ; AH=00h (set video mode), AL=03h (text mode 80x25 color)
    int 10h                    ; Call BIOS video interrupt

    mov ax, 0600h              ; AH=06h (scroll up/clear), AL=00h (clear entire window)
    mov bh, 07h                ; Text attribute: 07h = white text on black background
    mov cx, 0000h              ; Upper left corner: CH=row=00h, CL=column=00h
    mov dx, 184Fh              ; Lower right corner: DH=row=18h (24), DL=column=4Fh (79)
    int 10h                    ; Call BIOS video interrupt

    call hide_cursor           ; Hide the text cursor for cleaner display
    call show_title           ; Display the game's title screen
    call start_game           ; Start the main game loop

    mov ax, 4C00h             ; DOS function: Exit program (4Ch)
    int 21h                   ; Call DOS interrupt to terminate program
main endp                     ; End of main procedure

    start_game proc                 ; Procedure to initialize and start the game
    call clear_screen          ; First clear the display screen for a fresh start
                              ; This removes any leftover graphics/text from title screen

    call get_player_name      ; Prompt for and get the player's name
                              ; This will store name in name_buffer for later use

    call show_welcome         ; Display welcome screen with player's name
                              ; Also shows game instructions and controls

    ret                       ; Return to main procedure
start_game endp

    clear_screen proc              ; Procedure to clear the entire display screen
    ; Set video mode to text mode 80x25
    mov ax, 0003h             ; AH=00h (set video mode), AL=03h (text mode 80x25 color)
    int 10h                   ; Call BIOS video interrupt to change video mode

    ; Clear screen using scroll window up function
    mov ax, 0600h            ; AH=06h (scroll up), AL=00h (clear entire window)
    mov bh, 07h              ; Attribute for cleared lines: 07h = white text on black
    mov cx, 0000h            ; Upper left corner: CH=row=00h, CL=column=00h
    mov dx, 184Fh            ; Lower right corner: DH=row=18h (24), DL=column=4Fh (79)
    int 10h                  ; Call BIOS video interrupt to clear screen

    ; Clear and update screen buffer
    call buffer_clear        ; Clear the game's screen buffer
    call buffer_render       ; Redraw the screen with cleared buffer contents

    ret                      ; Return to calling procedure
clear_screen endp

    show_title proc                       ; Procedure to display animated title screen
    ; Initialize screen
    call buffer_clear                 ; Clear screen buffer
    call buffer_render                ; Display cleared buffer
    mov si, 18                        ; Set initial delay value
    call sleep                        ; Wait before starting animation
    mov si, 0                         ; Reset SI for animation loop

    ; Animate "SNAKE" title
title_next:                       ; Loop for drawing SNAKE title
    mov bx, word ptr snakeTitle[si]    ; Get screen position from title coordinates
    mov byte ptr [buffer + bx], 8      ; Place character '8' at position (for snake effect)
    push si                            ; Save current position
    call buffer_render                 ; Update screen with new character
    mov si, 1                          ; Set small delay
    call sleep                         ; Wait between characters
    pop si                             ; Restore position
    add si, 2                          ; Move to next coordinate (2 bytes per position)
    cmp si, 274                        ; Check if we've drawn all title characters
    jl title_next                      ; Continue if more characters to draw

    ; Prepare for "SPRINT" subtitle
    mov si, 0                         ; Reset SI for sprint animation
    call sleep                        ; Pause between title and subtitle

    ; Animate "SPRINT" subtitle
sprint_next:                      ; Loop for drawing SPRINT subtitle
    mov bx, word ptr sprintTitle[si]   ; Get screen position for subtitle
    mov byte ptr [buffer + bx], 219    ; Place character 219 (block) at position
    push si                            ; Save current position
    call buffer_render                 ; Update screen
    mov si, 1                          ; Set small delay
    call sleep                         ; Wait between characters
    pop si                             ; Restore position
    add si, 2                          ; Move to next coordinate
    cmp si, 180                        ; Check if subtitle is complete
    jl sprint_next                     ; Continue if more characters to draw

    call intro_sound                  ; Play the intro sound

    ; Display copyright text
    mov si, offset text_1             ; Point to copyright message
    mov di, 1864                      ; Position for copyright text
    call buffer_print_string          ; Print copyright message

    call buffer_print_string          ; Refresh display
    call clear_keyboard_buffer        ; Clear any pending keystrokes

    ; Wait for keypress with blinking prompt
wait_for_key:
    mov si, offset text_4         ; Load blank space text
    mov di, 1627                  ; Screen position for prompt
    call buffer_print_string      ; Clear prompt area
    call buffer_render            ; Update screen
    mov si, 5                     ; Set delay time
    call sleep                    ; Wait
    mov ah, 01h                   ; Check keyboard buffer
    int 16h                       ; BIOS keyboard service
    jnz continue_key              ; If key pressed, continue
    mov si, offset text_3         ; Load "PRESS ANY KEY" text
    mov di, 1627                  ; Screen position for prompt
    call buffer_print_string      ; Display prompt
    call buffer_render            ; Update screen
    mov si, 10                    ; Set delay time
    call sleep                    ; Wait
    mov ah, 01h                   ; Check keyboard again
    int 16h                       ; BIOS keyboard service
    jz wait_for_key               ; If no key, continue blinking

continue_key:
    mov ah, 00h                   ; Get keystroke
    int 16h                       ; Read key from buffer
    ret                          ; Return to caller
show_title endp

show_welcome proc            ; Start of welcome screen procedure
    call buffer_clear       ; Clear the entire screen buffer

    ; Print "WELCOME, " 
    mov si, offset text_6   ; SI points to "WELCOME, " text in memory
    mov di, 480            ; DI = screen position to print welcome
    call buffer_print_string ; Print "WELCOME, " to screen buffer

    ; Print player name right after welcome
    mov si, offset name_buffer ; SI points to player's name in memory
    mov di, 490            ; DI = position after welcome message
    call buffer_print_string ; Print player's name to screen buffer

    call buffer_render     ; Display the buffer contents on screen

    ; Move cursor for instructions - moved up 2 more rows
    mov ah, 02h           ; Function: Set cursor position
    mov bh, 0             ; Page number = 0 (default display page)
    mov dh, 8             ; Row 8 (moved up 2 rows from 12)
    mov dl, 0             ; Column 0
    int 10h               ; Call video BIOS interrupt

    ; Print instructions
    lea dx, instructions  ; DX points to game instructions text
    mov ah, 09H           ; Function: Print string
    int 21h              ; Call DOS interrupt to print

    ; Position for ready message - moved up 2 more rows
    mov ah, 02h           ; Function: Set cursor position
    mov bh, 0             ; Page number = 0
    mov dh, 14            ; Row 14 (moved up 2 rows from 17)
    mov dl, 0             ; Column 0
    int 10h               ; Call video BIOS interrupt

    ; Print space character
    mov ah, 09h           ; Function: Write character and attribute
    mov al, ' '           ; Character to write = space
    mov cx, 1             ; Number of times to write = 1
    mov bl, 10001111b     ; Attribute: White background, black text
    int 10h               ; Call video BIOS interrupt

    ; Print ready message
    lea dx, ready_text    ; DX points to "press any key" message
    mov ah, 09h           ; Function: Print string
    int 21h               ; Call DOS interrupt to print

    call clear_keyboard_buffer ; Clear any pending keystrokes
    mov ah, 01h           ; Function: Check for keystroke
    int 16h              ; Call keyboard BIOS interrupt
    jz $-2               ; If no key pressed, keep checking
    mov ah, 00h           ; Function: Get keystroke
    int 16h              ; Clear the key from buffer

    call show_game_screen ; Start the main game
    ret                  ; Return from procedure
show_welcome endp        ; End of welcome screen procedure

    show_game_screen proc        ; Start of game screen procedure
    mov ax, 0003h           ; AX = video mode 3 (80x25 text mode)
    int 10h                 ; Set video mode through BIOS
    
    mov ax, 0b800h          ; AX = video memory segment address
    mov es, ax              ; ES points to video memory for direct access
    
    ; Initialize the game with 3 lives and reset score only at start
    mov lives, 3                ; Set lives to 3
    mov current_score, 0        ; Reset score to 0 at game start
    
    call printbox
    
mainloop:               ; Main game loop label
    call delay         ; Add delay for game speed control
    
    ; Check pause state
    cmp paused, 1      ; Compare pause flag with 1
    je check_input     ; If game is paused, only check for input
    
    call shiftsnake    ; Move snake one position
    call display_lives ; Update lives display on screen
    
    cmp gameover, 1    ; Check if snake hit something
    je handle_death    ; If collision occurred, handle death
    
check_input:           ; Label for input checking section
    call keyboardfunctions ; Check for and handle any keyboard input
    cmp quit, 1       ; Check if player pressed quit key (q)
    jne continue_game    ; If not quitting, continue game
    jmp far ptr quitpressed_mainloop  ; Use far jump for long distance
    
continue_game:         ; Label for game continuation
    ; Only generate fruit and draw if not paused
    cmp paused, 1      ; Check if game is paused
    je skip_updates    ; If paused, skip fruit generation
    call fruitgeneration ; If not paused, try to generate new fruit
    
skip_updates:          ; Label for update skipping when paused
    call draw          ; Update screen with current game state
    jmp mainloop       ; Jump back to start of main game loop
    
handle_death:          ; Label for handling snake death
    ; Clear screen for death message
    mov ax, 0003h      ; Set video mode 3 (text mode 80x25)
    int 10h            ; Clear screen using BIOS

    ; Decrease lives and check
    dec lives          ; Subtract one life
    mov al, lives      ; Move lives count to AL
    cmp al, 0          ; Compare remaining lives with 0
    jle game_really_over ; If no lives left, game over

    ; Calculate message length
    lea si, lost_life_msg   ; Load address of life lost message
    xor cx, cx             ; Initialize the counter to 0
msg_len_loop:
    lodsb           ; Load the character at [si] into al
    cmp al, '$'     ; Check if the character is the terminator ('$')
    je msg_len_done ; If so, jump to msg_len_done
    inc cx          ; Increment the counter
    jmp msg_len_loop ; Loop to the next character

msg_len_done:

    ; Calculate center position
    mov ax, 80      ; Screen width
    sub ax, cx      ; Subtract message length
    shr ax, 1       ; Divide by 2 for center X position
    
    ; Position cursor at vertical center (row 12) and horizontal center
    mov dh, 0Ch     ; Row 12 for vertical center
    mov dl, al      ; Calculated column in DL
    mov bh, 0       ; Page number
    mov ah, 02h     ; Set cursor position
    int 10h
    
    ; Show remaining lives message
    ; Show remaining lives message
    lea dx, lost_life_msg   ; Load address of life lost message
    mov ah, 09h             ; DOS function: print string
    int 21h                 ; Display the message

    ; Wait for key press
    mov ah, 0               ; Function: wait for key
    int 16h                 ; Wait for any key press

    ; Reset the snake but keep the current score
    call reset_snake        ; Reset the snake to the starting position
    mov gameover, 0         ; Clear the game over flag
    mov fruitactive, 0      ; Remove any existing fruit

    ; Clear the screen and redraw the game boundary
    mov ax, 0003h           ; Set video mode 3 (text mode 80x25)
    int 10h                 ; Clear the screen using BIOS
    mov ax, 0b800h          ; Set the video memory segment address
    mov es, ax              ; Set the extra segment to the video memory
    call printbox           ; Draw the game boundary

    ; Jump back to the main game loop
    jmp mainloop           ; Return to the main game loop
    
game_really_over:       ; Label for final game over
    ; Set the video mode to text mode 80x25
    mov ax, 0003h       ; Set text mode 80x25
    int 10h             ; Clear the screen

    ; Set a longer delay time for the end screen
    mov delaytime, 100  ; Set longer delay for end screen

    ; Play the game over sound
    call game_over_sound
    
    ; Display Game Over message
    mov dx, 0A1Ch       ; Row 10 (0Ah), Column 28 (1Ch)
    lea bx, gameovermsg
    call writestringat
    
    ; Display player name label
    mov dx, 0C21h       ; Row 12 (0Ch), Column 33 (21h)
    lea bx, player_display
    call writestringat
    
    ; Display actual name
    mov dx, 0C29h       ; Row 12 (0Ch), Column 41 (29h)
    lea bx, name_buffer
    call writestringat
    
    ; Display final score label
    mov dx, 0E1Fh       ; Row 14 (0Eh), Column 31 (1Fh)
    lea bx, score_display
    call writestringat
    
    ; Position cursor for score number - added extra space
    mov dx, 0E2Ch       ; Row 14 (0Eh), Column 44 (2Ch) - increased by 1 for extra space
    mov ah, 02h
    mov bh, 0
    int 10h
    
    ; Display score
    xor ah, ah
    mov al, current_score
    call dispnum
    
    ; Wait for key press
    mov ah, 0
    int 16h
    
    jmp quit_mainloop
    
quitpressed_mainloop:    ; Label for handling quit command
    mov ax, 0003h        ; Set the video mode to text mode 80x25
    int 10h              ; Call BIOS to set video mode
    mov delaytime, 100   ; Set a longer delay time for the quit screen
    mov dx, 0000h        ; Position the cursor at the top-left corner
    lea bx, quitmsg      ; Load the "quit" message address into BX
    call writestringat   ; Display the quit message on the screen
    call delay           ; Add a short delay
    jmp quit_mainloop    ; Jump to the final quit routine

quit_mainloop:
    mov ax, 0003h           ; Set the video mode to text mode 80x25
    int 10h                 ; Call BIOS to set the video mode
    
    ; Display quit message centered at top
    mov dx, 001Ch           ; Position the cursor at row 0, column 28 (centered)
    lea bx, quitmsg         ; Load the address of the "quit" message
    call writestringat      ; Display the quit message on the screen
    ret                     ; Return from the procedure
    
show_game_screen endp

display_lives proc      ; Procedure to show remaining lives
    push ax            ; Save registers to stack
    push bx            ; These will be restored
    push cx            ; before returning from
    push dx            ; the procedure

    ; Display "Lives: " text at position (1, 70)
    mov dx, 0146h         ; Position the cursor at row 1, column 70
    lea bx, lives_msg     ; Load the address of the "Lives: " message
    call writestringat    ; Display the message at the specified position
    
    ; Start from rightmost position and move left
    mov dl, 78           ; Start from rightmost position
    mov dh, 1            ; Row 1
    mov ch, 3            ; Counter for total positions
    mov cl, lives        ; Get current lives count
    mov bl, 3            ; Heart symbol
    mov bh, 04h          ; Red color
    
display_heart_loop:     ; Loop to draw hearts for each life
    cmp ch, 0          ; Check if we have drawn all hearts
    je display_lives_done ; If no more hearts, jump to display_lives_done

    push ax            ; Save the AX register
    mov ax, dx         ; Move the current position to AX

    ; Compare position with lives count
    push cx            ; Save the CX register
    mov cl, lives      ; Get the current lives count
    cmp ch, cl         ; Compare the current position with the lives count
    pop cx             ; Restore the CX register
    jg empty_heart     ; If the position is greater than the lives count, jump to empty_heart

    call writecoloredchar ; Draw the heart symbol at the current position
    jmp next_heart     ; Jump to the next heart
    
empty_heart:
    mov bl, ' '         ; Set the character to a space
    call writecoloredchar ; Draw the empty heart symbol
    mov bl, 3           ; Set the character to the heart symbol

next_heart:
    pop ax              ; Restore the AX register
    dec dl              ; Move the position one column to the left
    dec ch              ; Decrease the heart counter
    jmp display_heart_loop ; Jump back to the start of the loop

display_lives_done:
    pop dx              ; Restore the original DX register
    pop cx              ; Restore the original CX register
    pop bx              ; Restore the original BX register
    pop ax              ; Restore the original AX register
    ret                 ; Return from the procedure
display_lives endp



    reset_snake proc       ; Procedure to reset snake after death
    push ax           ; Save registers we'll use
    push bx           ; to be restored at
    push cx           ; the end of the
    push dx           ; procedure
   
   ; Clear all snake segments
   lea si, head
   mov cx, 200         ; Increased to match new maximum (4*50)
clear_snake_loop:     ; Loop to clear all snake segments from screen
    mov bl, ds:[si]   ; Get the character of the current segment
    mov dx, ds:[si+1] ; Get the position of the current segment
    mov bl, ' '       ; Set the character to a space
    call writecharat  ; Clear the current segment from the screen
    add si, 4         ; Move to the next segment (4 bytes per segment)
    loop clear_snake_loop ; Repeat the loop until all segments are cleared
   
clear_snake_done:     ; Reset snake to initial state
    ; Reset snake position
    mov dh, initial_head_y ; Get the starting Y position for the head
    mov dl, initial_head_x ; Get the starting X position for the head
    mov word ptr head+1, dx ; Set the new head position

    ; Reset snake state
    mov segmentcount, 2    ; Always start with 2 segments
    mov head, '>'         ; Set the head to point right
    mov fruitactive, 0     ; Remove any active fruit

    ; Clear snake body array
    lea di, body         ; Get the address of the body array
    mov cx, 200          ; Set the counter to clear 200 bytes (4*50)
    mov al, 0            ; Set the value to clear the array to 0
clear_body_array:
    mov [di], al       ; Set the current byte in the body array to 0
    inc di            ; Move to the next byte in the array
    loop clear_body_array ; Repeat the loop until the entire array is cleared

    ; Initialize first body segment
    mov byte ptr body, '*'  ; Set the character for the first segment
    mov dh, initial_head_y ; Get the Y position from the saved initial head position
    mov dl, initial_head_x ; Get the X position from the saved initial head position
    add dl, 1           ; Place the first segment one position after the head
    mov word ptr body+1, dx ; Set the position for the first segment
    mov byte ptr body+3, 07h ; Set the color for the first segment to white

    ; Initialize second body segment
    mov byte ptr body+4, '*'  ; Set the character for the second segment
    mov dh, initial_head_y   ; Get the Y position from the saved initial head position
    mov dl, initial_head_x   ; Get the X position from the saved initial head position
    add dl, 2           ; Place the second segment two positions after the head
    mov word ptr body+5, dx  ; Set the position for the second segment
    mov byte ptr body+7, 07h ; Set the color for the second segment to white

    ; Show respawn message
    lea dx, respawn_msg ; Load the address of the respawn message
    mov ah, 09h        ; DOS function: Print string
    int 21h           ; Display the respawn message

    ; Delay for message visibility
    mov cx, 0FFFFh     ; Set the maximum delay count
snake_delay_loop:
    loop snake_delay_loop ; Repeat the loop until CX reaches 0

    pop dx              ; Restore the original DX register
    pop cx              ; Restore the original CX register
    pop bx              ; Restore the original BX register
    pop ax              ; Restore the original AX register
    ret                 ; Return from the procedure
reset_snake endp

    delay proc           ; Controls game speed through timing
    mov ah, 00       ; BIOS get system time function
    int 1ah          ; Get the initial time (CX:DX = tick count)
    mov bx, dx       ; Save the initial time in BX

jmp_delay:           ; Start of the delay loop
    int 1ah          ; Get the current time
    sub dx, bx       ; Calculate the time elapsed
    cmp dl, delaytime ; Compare the elapsed time with the desired delay
    jl jmp_delay     ; If less time has passed, keep looping
    ret              ; Return from the procedure when the desired delay has been reached
delay endp

    
fruitgeneration proc     ; Procedure to create new fruit
    ; Only generate new fruit if there isn't one active
    cmp fruitactive, 1   ; Check if fruit is currently active
    je fruit_exit        ; If fruit is active, jump to fruit_exit

    ; Get system time for random seed
    mov ah, 00h          ; BIOS get system time function
    int 1Ah              ; Get the time in CX:DX for randomization

    ; Generate random X position
    mov ax, dx           ; Move the time value to AX
    xor dx, dx           ; Clear DX for division
    mov bx, col          ; BX = screen width (80)
    sub bx, 4            ; Keep the fruit away from the borders
    div bx               ; Divide AX by BX to get a random X coordinate
    add dl, 2            ; Add an offset from the left border
    and dl, 0FEh         ; Make the X coordinate even (very important!)
    mov fruitx, dl       ; Store the generated X coordinate

    ; Generate random Y position
    mov ax, dx           ; Move the time value to AX
    xor dx, dx           ; Clear DX for division
    mov bx, row          ; BX = screen height (25)
    sub bx, 4            ; Keep the fruit away from the borders
    div bx               ; Divide AX by BX to get a random Y coordinate
    add dl, 3            ; Add an offset from the top border
    mov fruity, dl       ; Store the generated Y coordinate

    mov fruitactive, 1   ; Mark the fruit as active

fruit_exit:
    ret                 ; Return from the procedure
fruitgeneration endp

    dispdigit proc          ; Procedure to display a single digit
    add dl, '0'         ; Convert the digit in DL to its ASCII representation
    mov ah, 02H         ; DOS function: Display character
    int 21H             ; Display the digit
    ret                 ; Return from the procedure
dispdigit endp   
   
dispnum proc           ; Procedure to display a multi-digit number
    test ax,ax         ; Check if the number in AX is zero
    jz retz            ; If it is, jump to the retz label
    xor dx, dx         ; Clear DX for the division
    mov bx,10          ; Prepare to divide by 10
    div bx             ; Divide AX by BX, quotient in AX, remainder in DX
    push dx            ; Save the remainder (current digit)
    call dispnum       ; Recursively call dispnum to handle the remaining digits
    pop dx             ; Restore the current digit
    call dispdigit     ; Display the current digit
    ret                ; Return from the procedure
retz:                  ; Label for the zero case
    mov ah, 02         ; Set the function to display a character
    ret                ; Return from the procedure
dispnum endp   

setcursorpos proc       ; Procedure to position the text cursor
    mov ah, 02H         ; BIOS function: Set cursor position
    push bx             ; Save the BX register
    mov bh, 0           ; Page number 0 (default display page)
    int 10h             ; Call the BIOS video service
    pop bx              ; Restore the BX register
    ret                 ; Return from the procedure
setcursorpos endp

    draw proc              ; Procedure to draw game elements
    push ax            ; Save registers to stack
    push bx            ; These will be restored
    push cx            ; when procedure
    push dx            ; ends

    ; First do regular drawing (score, snake, fruit)
    ; Draw score at position (1, 2) - left side
    lea bx, scoremsg    ; BX points to "Score: " text
    mov dx, 0102h       ; Position DH=1 (row), DL=2 (column)
    call writestringat  ; Display score text

    add dx, 7           ; Move cursor after "Score: "
    call setcursorpos   ; Set cursor position

    ; Display only current_score (no need to add segmentcount)
    xor ah, ah          ; Clear AH for score display
    mov al, current_score ; AL = current score value
    call dispnum        ; Display the number

    ; Draw snake
    lea si, head        ; SI points to snake head data
    ; Draw head (white color)
    mov bl, ds:[si]     ; Get head character
    test bl, bl         ; Test if head exists
    jz draw_fruit       ; If no head, skip to fruit
    mov dx, ds:[si+1]   ; Get head position
    push ax             ; Save AX
    mov ax, dx          ; Move position to AX
    mov bl, ds:[si]     ; Get head character again
    mov bh, 07h         ; Set white color for head
    call writecoloredchar ; Draw head with color
    pop ax              ; Restore AX
    add si, 3           ; Point to next segment

draw_body:              ; Label for body segment drawing loop
    mov bl, ds:[si]     ; Get segment character
    test bl, bl         ; Check if segment exists
    jz draw_fruit       ; If no segment, done with snake
    mov dx, ds:[si+1]   ; Get segment position
    push ax             ; Save AX
    mov ax, dx          ; Position to AX for drawing
    mov bl, ds:[si]     ; Get character again
    mov bh, ds:[si+3]   ; Get this segment's color
    call writecoloredchar ; Draw colored segment
    pop ax              ; Restore AX
    add si, 4           ; Move to next segment (4 bytes now)
    jmp draw_body       ; Continue with next segment

draw_fruit:             ; Label for fruit drawing section
    ; Only draw fruit if active
    cmp fruitactive, 1  ; Check if fruit exists
    jne check_pause     ; If no fruit, skip to pause check

    ; Write fruit with color
    mov dh, fruity      ; Get fruit Y position
    mov dl, fruitx      ; Get fruit X position
    push dx             ; Save position
    mov ax, dx          ; Copy position to AX
    and ax, 0FF00h      ; Isolate Y coordinate
    mov cl, 8           ; Prepare to shift 8 bits
    shr ax, cl          ; Shift Y to lower byte
    mov bl, 160         ; 160 bytes per row
    mul bl              ; Calculate row offset
    pop dx              ; Restore position
    mov bl, dl          ; Get X position
    xor bh, bh          ; Clear high byte
    shl bx, 1           ; Multiply X by 2 (char + attr)
    add ax, bx          ; Add X offset to row offset
    mov di, ax          ; DI = final video memory offset
    mov al, 'F'         ; Fruit character
    mov ah, fruit_color ; Get current fruit color
    mov word ptr es:[di], ax ; Write fruit and color
    
check_pause:
    ; Check if game is paused and display message if it is
    cmp paused, 1
    jne draw_exit
    
    ; Display pause message in the middle of screen
    mov dx, 0C28h       ; Row 12, Column 40 (center)
    lea bx, pause_msg
    call writestringat
    
draw_exit:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
draw endp

    readchar proc          ; Procedure to check and read keyboard
    mov ah, 01H        ; BIOS function: Check keyboard status
    int 16H            ; Call BIOS keyboard interrupt
    jnz keybdpressed   ; If a key is pressed, jump to keybdpressed
    xor dl, dl         ; No key was pressed, clear DL
    ret                ; Return from the procedure

keybdpressed:          ; Handle a pressed key
    mov ah, 00H        ; BIOS function: Get key
    int 16H            ; Call BIOS keyboard interrupt
    mov dl, al         ; Move the ASCII value of the key to DL
    ret                ; Return from the procedure
readchar endp

keyboardfunctions proc  ; Procedure to handle keyboard input
    call readchar      ; Check for and read any keyboard input
    cmp dl, 0          ; Check if a key was pressed
    je next_14         ; If no key was pressed, jump to next_14
    
    ; Add pause check first
    cmp dl, 'p'
    jne check_movement    ; Skip to regular movement if not 'p'
    xor al, al           ; Clear AL
    mov al, paused       ; Get current pause state
    xor al, 1            ; Toggle it (0->1 or 1->0)
    mov paused, al       ; Store new state
    
    ; If we're unpausing (paused is now 0), clear the pause message
    cmp al, 0
    jne skip_clear_pause
    
    ; Clear the pause message line
    push ax
    push bx
    push cx
    push dx
    
    mov dx, 0C28h       ; Same position as pause message (Row 12, Column 40)
    mov cx, 35          ; Length of pause message (or more to ensure full clear)
    mov bl, ' '         ; Space character to clear
clear_pause_loop:
    call writecharat
    inc dl
    loop clear_pause_loop
    
    pop dx
    pop cx
    pop bx
    pop ax
    
skip_clear_pause:
    ret
    
check_movement:        ; Handle movement keys
    ; Only process movement if not paused
    cmp paused, 1      ; Check if the game is paused
    je next_14         ; If paused, skip the movement logic

    ; Check for UP ('w' key)
    cmp dl, 'w'        ; Is the key 'w'?
    jne next_11        ; If not, check the next key
    cmp head, 'v'      ; Is the snake currently moving down?
    je next_14         ; If so, can't go up, so skip to next_14
    mov head, '^'      ; Set the snake's direction to up
    ret                ; Return from the procedure

next_11:
    ; Check for DOWN ('s' key)
    cmp dl, 's'        ; Is the key 's'?
    jne next_12        ; If not, check the next key
    cmp head, '^'      ; Is the snake currently moving up?
    je next_14         ; If so, can't go down, so skip to next_14
    mov head, 'v'      ; Set the snake's direction to down
    ret                ; Return from the procedure

next_12:
    ; Check for LEFT ('a' key)
    cmp dl, 'a'        ; Is the key 'a'?
    jne next_13        ; If not, check the next key
    cmp head, '>'      ; Is the snake currently moving right?
    je next_14         ; If so, can't go left, so skip to next_14
    mov head, '<'      ; Set the snake's direction to left
    ret                ; Return from the procedure

next_13:
    ; Check for RIGHT ('d' key)
    cmp dl, 'd'        ; Is the key 'd'?
    jne next_14        ; If not, check for the quit key
    cmp head, '<'      ; Is the snake currently moving left?
    je next_14         ; If so, can't go right, so skip to next_14
    mov head,'>'       ; Set the snake's direction to right

next_14:    
    ; Check for QUIT ('q' key)
    cmp dl, 'q'        ; Is the key 'q'?
    jne exit_keyboard  ; If not, exit the procedure
    mov quit, 1        ; Set the quit flag
exit_keyboard:
    ret                ; Return from the procedure
keyboardfunctions endp

shiftsnake proc
    mov bx, offset head
    lea si, body
    
    ; Save head direction and position
    mov al, [bx]          ; Get direction
    push ax               ; Save direction for later
    inc bx
    mov ax, [bx]          ; Get head position
    inc bx
    inc bx
    
    ; Track segments - use segmentcount as strict limit
    xor cx, cx            ; Clear counter
    
shift_body:
    cmp cx, segmentcount   ; Check against current segment count
    jae calculate_new_pos  ; If we've moved all segments, we're done
    
    ; Shift segment
    mov dx, [si+1]        ; Get position
    mov [si+1], ax        ; Update with previous position
    mov ax, dx            ; Save this position for next segment
    
    ; Move to next segment
    add si, 4             ; Each segment is 4 bytes
    inc cx                ; Count this segment
    jmp shift_body
    
calculate_new_pos:
    pop ax               ; Get direction back
    push dx              ; Save last position
    
    lea bx, head
    inc bx
    mov dx, [bx]         ; Get head position
    
    ; Calculate new head position based on direction
    cmp al, '<'
    jne try_right
    dec dl
    dec dl               ; Move left
    jmp pos_calculated
try_right:
    cmp al, '>'
    jne try_up
    inc dl
    inc dl               ; Move right
    jmp pos_calculated
try_up:
    cmp al, '^'
    jne move_down
    dec dh               ; Move up
    jmp pos_calculated
move_down:
    inc dh               ; Move down
    
pos_calculated:
    mov [bx], dx         ; Update head position
    
    ; Check collisions
    cmp dh, top
    je hit_wall
    cmp dh, bottom
    je hit_wall
    cmp dl, left
    je hit_wall
    cmp dl, right
    je hit_wall
    
    ; Check for self collision
    call readcharat
    cmp bl, '*'
    je hit_wall
    
    ; Check for fruit
    mov ah, fruity
    mov al, fruitx
    cmp dh, ah
    jne no_fruit
    cmp dl, al
    je eat_fruit
    
no_fruit:
    ; No collision - clear tail position
    mov cx, dx          ; Save new head position
    pop dx              ; Get tail position
    mov bl, ' '         ; Clear character
    call writecharat
    mov dx, cx          ; Restore head position
    ret
    
hit_wall:
    inc gameover
    pop dx              ; Balance stack
    ret
    
eat_fruit:
    call make_sound
    ; Check maximum length
    mov ax, segmentcount   ; Load full word into AX instead of byte into AL
    cmp ax, 50            ; Compare word with immediate value
    jge skip_growth

    ; Calculate position for new segment
    mov bl, 4             ; Each segment is 4 bytes
    mul bl                ; AX = segmentcount * 4
    lea bx, body        
    add bx, ax           ; Point to new segment position
    
    ; Add new segment
    pop dx              ; Get tail position
    mov byte ptr [bx], '*'      ; Character
    mov word ptr [bx+1], dx     ; Position
    mov al, fruit_color
    mov [bx+3], al              ; Color
    inc segmentcount
    
    ; Clear old fruit and update score
    mov fruitactive, 0
    push dx
    mov dh, fruity
    mov dl, fruitx
    mov bl, ' '
    call writecharat
    pop dx
    
    ; Update score and generate new fruit
    inc current_score
    
    ; Update fruit color
    mov si, offset fruit_colors
    xor bh, bh
    mov bl, fruit_color
    sub bl, 0Ch
    inc bl
    cmp bl, 5
    jl store_next_color
    xor bl, bl
    
store_next_color:
    mov al, [si + bx]
    mov fruit_color, al
    call fruitgeneration
    ret
    
skip_growth:
    pop dx
    ret
shiftsnake endp

make_sound proc
   push ax                ; Save registers on the stack
   push bx
   push cx
   push dx
   
   ; High pitched "ding"
   mov al, 182            ; Prepare to set up the speaker
   out 43h, al            ; Send command byte to the timer chip
   mov ax, 880            ; Set frequency for high-pitched sound
   out 42h, al            ; Send lower byte of frequency
   mov al, ah             
   out 42h, al            ; Send upper byte of frequency
   in al, 61h             ; Read the current state of port 61h
   or al, 00000011b       ; Set bits to enable speaker
   out 61h, al            ; Write back to turn on the speaker
   
   mov cx, 2              ; Set loop counter for duration
eat_sound1:
   mov bx, 65535          ; Set inner loop counter
eat_pause1:
   dec bx                 ; Decrement inner counter
   jnz eat_pause1         ; Loop until inner counter is zero
   loop eat_sound1        ; Repeat outer loop
   
   ; Quick lower follow-up tone
   mov ax, 1320           ; Set frequency for lower tone
   out 42h, al            ; Send lower byte of frequency
   mov al, ah
   out 42h, al            ; Send upper byte of frequency
   
   mov cx, 1              ; Set shorter duration for second tone
eat_sound2:
   mov bx, 65535          ; Set inner loop counter
eat_pause2:
   dec bx                 ; Decrement inner counter
   jnz eat_pause2         ; Loop until inner counter is zero
   loop eat_sound2        ; Repeat outer loop
   
   in al, 61h             ; Read the current state of port 61h
   and al, 11111100b      ; Clear bits to disable speaker
   out 61h, al            ; Write back to turn off the speaker
   
   pop dx                 ; Restore registers from stack
   pop cx
   pop bx
   pop ax
   ret                    ; Return from procedure
make_sound endp

intro_sound proc
   push ax                ; Save registers on the stack
   push bx
   push cx
   push dx
   
   mov al, 182            ; Prepare to set up the speaker
   out 43h, al            ; Send command byte to the timer chip
   
   ; First note (higher)
   mov ax, 1000           ; Set frequency for first note
   out 42h, al            ; Send lower byte of frequency
   mov al, ah
   out 42h, al            ; Send upper byte of frequency
   in al, 61h             ; Read the current state of port 61h
   or al, 00000011b       ; Set bits to enable speaker
   out 61h, al            ; Write back to turn on the speaker
   
   mov cx, 6              ; Set duration for first note
intro_tone1:
   mov bx, 65535          ; Set inner loop counter
intro_pause1:
   dec bx                 ; Decrement inner counter
   jnz intro_pause1       ; Loop until inner counter is zero
   loop intro_tone1       ; Repeat outer loop
   
   ; Second note (lower)
   mov ax, 2000           ; Set frequency for second note
   out 42h, al            ; Send lower byte of frequency
   mov al, ah
   out 42h, al            ; Send upper byte of frequency
   
   mov cx, 6              ; Set duration for second note
intro_tone2:
   mov bx, 65535          ; Set inner loop counter
intro_pause2:
   dec bx                 ; Decrement inner counter
   jnz intro_pause2       ; Loop until inner counter is zero
   loop intro_tone2       ; Repeat outer loop
   
   in al, 61h             ; Read the current state of port 61h
   and al, 11111100b      ; Clear bits to disable speaker
   out 61h, al            ; Write back to turn off the speaker
   
   pop dx                 ; Restore registers from stack
   pop cx
   pop bx
   pop ax
   ret                    ; Return from procedure
intro_sound endp

game_over_sound proc
   push ax                ; Save registers on the stack
   push bx
   push cx
   push dx
   
   ; Descending tones to indicate game over
   mov al, 182            ; Prepare to set up the speaker
   out 43h, al            ; Send command byte to the timer chip
   
   ; First tone (high)
   mov ax, 800            ; Set frequency for first (highest) tone
   out 42h, al            ; Send lower byte of frequency
   mov al, ah
   out 42h, al            ; Send upper byte of frequency
   in al, 61h             ; Read the current state of port 61h
   or al, 00000011b       ; Set bits to enable speaker
   out 61h, al            ; Write back to turn on the speaker
   
   mov cx, 10             ; Set duration for first tone
sound1:
   mov bx, 65535          ; Set inner loop counter
pause1:
   dec bx                 ; Decrement inner counter
   jnz pause1             ; Loop until inner counter is zero
   loop sound1            ; Repeat outer loop
   
   ; Second tone (lower)
   mov ax, 1200           ; Set frequency for second (middle) tone
   out 42h, al            ; Send lower byte of frequency
   mov al, ah
   out 42h, al            ; Send upper byte of frequency
   
   mov cx, 12             ; Set duration for second tone
sound2:
   mov bx, 65535          ; Set inner loop counter
pause2:
   dec bx                 ; Decrement inner counter
   jnz pause2             ; Loop until inner counter is zero
   loop sound2            ; Repeat outer loop
   
   ; Final tone (lowest)
   mov ax, 2000           ; Set frequency for third (lowest) tone
   out 42h, al            ; Send lower byte of frequency
   mov al, ah
   out 42h, al            ; Send upper byte of frequency
   
   mov cx, 15             ; Set duration for final tone
sound3:
   mov bx, 65535          ; Set inner loop counter
pause3:
   dec bx                 ; Decrement inner counter
   jnz pause3             ; Loop until inner counter is zero
   loop sound3            ; Repeat outer loop
   
   in al, 61h             ; Read the current state of port 61h
   and al, 11111100b      ; Clear bits to disable speaker
   out 61h, al            ; Write back to turn off the speaker
   
   pop dx                 ; Restore registers from stack
   pop cx
   pop bx
   pop ax
   ret                    ; Return from procedure
game_over_sound endp

    printbox proc
    ; Draw top border
    mov dh, 0          ; Set row to 0 (top of screen)
    mov dl, 0          ; Set column to 0 (left edge of screen)
    mov cx, 80         ; Set counter to 80 (full screen width)
    mov bl, '*'        ; Set character to asterisk for border
draw_top:                 
    push dx            ; Save current position
    call writecharat   ; Write asterisk at current position
    pop dx             ; Restore position
    inc dl             ; Move one column to the right
    loop draw_top      ; Repeat until counter (cx) reaches 0
    
    ; Draw right side
    mov dh, 0          ; Set row to 0 (top of screen)
    mov dl, 79         ; Set column to 79 (right edge of screen)
    mov cx, 25         ; Set counter to 25 (full screen height)
draw_right:
    push dx            ; Save current position
    call writecharat   ; Write asterisk at current position
    pop dx             ; Restore position
    inc dh             ; Move one row down
    loop draw_right    ; Repeat until counter (cx) reaches 0
    
    ; Draw bottom border
    mov dh, 24         ; Set row to 24 (bottom row of screen)
    mov dl, 79         ; Set column to 79 (right edge of screen)
    mov cx, 80         ; Set counter to 80 (full screen width)
draw_bottom:
    push dx            ; Save current position
    call writecharat   ; Write asterisk at current position
    pop dx             ; Restore position
    dec dl             ; Move one column to the left
    loop draw_bottom   ; Repeat until counter (cx) reaches 0
    
    ; Draw left side
    mov dh, 24         ; Set row to 24 (bottom of screen)
    mov dl, 0          ; Set column to 0 (left edge of screen)
    mov cx, 25         ; Set counter to 25 (full screen height)
draw_left:
    push dx            ; Save current position
    call writecharat   ; Write asterisk at current position
    pop dx             ; Restore position
    dec dh             ; Move one row up
    loop draw_left     ; Repeat until counter (cx) reaches 0
    
    ret                ; Return from procedure
printbox endp


    writecharat proc
    push dx             ; Save DX register
    mov ax, dx          ; Copy DX to AX
    and ax, 0FF00H      ; Isolate the high byte (row)
    shr ax, 1           ; Shift right 8 times to
    shr ax, 1           ; move row to low byte
    shr ax, 1           ; (equivalent to dividing by 256)
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr ax, 1
    
    push bx             ; Save BX register
    mov bh, 160         ; 160 bytes per row (80 columns * 2 bytes per character)
    mul bh              ; Multiply row by 160 to get row offset
    pop bx              ; Restore BX register
    and dx, 0FFH        ; Isolate the low byte (column)
    shl dx, 1           ; Multiply column by 2 (2 bytes per character)
    add ax, dx          ; Add column offset to row offset
    mov di, ax          ; Move result to DI (destination index)
    mov es:[di], bl     ; Write character to video memory
    pop dx              ; Restore DX register
    ret                 ; Return from procedure
writecharat endp

readcharat proc
    push dx             ; Save DX register
    mov ax, dx          ; Copy DX to AX
    and ax, 0FF00H      ; Isolate the high byte (row)
    shr ax, 1           ; Shift right 8 times to
    shr ax, 1           ; move row to low byte
    shr ax, 1           ; (equivalent to dividing by 256)
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr ax, 1    
    push bx             ; Save BX register
    mov bh, 160         ; 160 bytes per row
    mul bh              ; Multiply row by 160 to get row offset
    pop bx              ; Restore BX register
    and dx, 0FFH        ; Isolate the low byte (column)
    shl dx, 1           ; Multiply column by 2
    add ax, dx          ; Add column offset to row offset
    mov di, ax          ; Move result to DI
    mov bl, es:[di]     ; Read character from video memory
    pop dx              ; Restore DX register
    ret                 ; Return from procedure
readcharat endp

writestringat proc
    push dx             ; Save DX register
    mov ax, dx          ; Copy DX to AX
    and ax, 0FF00H      ; Isolate the high byte (row)
    shr ax, 1           ; Shift right 8 times to
    shr ax, 1           ; move row to low byte
    shr ax, 1           ; (equivalent to dividing by 256)
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr ax, 1
    shr ax, 1
    
    push bx             ; Save BX register
    mov bh, 160         ; 160 bytes per row
    mul bh              ; Multiply row by 160 to get row offset
    
    pop bx              ; Restore BX register
    and dx, 0FFH        ; Isolate the low byte (column)
    shl dx, 1           ; Multiply column by 2
    add ax, dx          ; Add column offset to row offset
    mov di, ax          ; Move result to DI

loop_writestringat:
    mov al, [bx]        ; Get character from string
    test al, al         ; Check if it's null terminator
    jz exit_writestringat ; If null, exit loop
    mov es:[di], al     ; Write character to video memory
    inc di              ; Move to next character position
    inc di              ; (2 bytes per character)
    inc bx              ; Move to next character in string
    jmp loop_writestringat ; Continue loop

exit_writestringat:
    pop dx              ; Restore DX register
    ret                 ; Return from procedure
writestringat endp

    get_player_name proc
    call clear_screen       ; Clear the screen before getting player name

    mov ah, 00h             ; Set video mode function
    mov al, 03h             ; Text mode 80x25, 16 colors
    int 10h                 ; BIOS video interrupt

    mov si, offset text_5   ; Load address of prompt text
    mov cx, 0               ; Initialize counter for string length

count_loop:
    lodsb                   ; Load byte from SI into AL and increment SI
    or al, al               ; Check if character is null (end of string)
    jz count_done           ; If null, counting is done
    inc cx                  ; Increment counter
    jmp count_loop          ; Continue counting

count_done:
    mov ax, cx              ; Move string length to AX
    shr ax, 1               ; Divide by 2 (for centering)
    mov dx, 40              ; Middle of screen (80 columns / 2)
    sub dx, ax              ; Calculate starting position for centered text

    push dx                 ; Save calculated position

    mov ah, 02h             ; Set cursor position function
    mov bh, 00h             ; Page number
    mov dh, 12              ; Row 12
    mov dl, dl              ; Column (from calculated position)
    int 10h                 ; BIOS video interrupt

    mov si, offset text_5   ; Reset SI to start of prompt text

print_loop:
    lodsb                   ; Load byte from SI into AL and increment SI
    or al, al               ; Check if character is null
    jz print_done           ; If null, printing is done
    mov ah, 0Eh             ; Teletype output function
    int 10h                 ; BIOS video interrupt
    jmp print_loop          ; Continue printing

print_done:
    pop dx                  ; Restore calculated position
    mov ah, 02h             ; Set cursor position function
    mov bh, 00h             ; Page number
    mov dh, 13              ; Row 13 (below prompt)
    mov dl, dl              ; Column (from calculated position)
    int 10h                 ; BIOS video interrupt

    mov di, 0               ; Initialize index for name buffer
    mov bl, 0               ; Initialize character counter
    push dx                 ; Save position

name_loop:
    mov ah, 01h             ; Check keyboard status function
    int 16h                 ; BIOS keyboard interrupt
    jz name_loop            ; If no key pressed, keep checking
    mov ah, 00h             ; Read character function
    int 16h                 ; BIOS keyboard interrupt

    cmp al, 0Dh             ; Compare with Enter key
    je name_done            ; If Enter, name input is done

    cmp al, 08h             ; Compare with Backspace key
    je handle_backspace     ; If Backspace, handle it

    cmp bl, 20              ; Check if name length is 20
    jge name_loop           ; If 20 or more, ignore input

    mov ah, 02h             ; Display character function
    mov dl, al              ; Character to display
    int 21h                 ; DOS interrupt

    mov [name_buffer + di], al  ; Store character in name buffer
    inc bl                  ; Increment character counter
    inc di                  ; Increment buffer index
    jmp name_loop           ; Continue input loop

handle_backspace:
    cmp bl, 0               ; Check if buffer is empty
    je name_loop            ; If empty, ignore backspace

    dec bl                  ; Decrement character counter
    dec di                  ; Decrement buffer index

    mov ah, 02h             ; Display character function
    mov bh, 00h             ; Page number
    mov dl, 08h             ; Backspace character
    int 21h                 ; DOS interrupt

    mov ah, 02h             ; Display character function
    mov dl, 20h             ; Space character (to erase)
    int 21h                 ; DOS interrupt

    mov ah, 02h             ; Display character function
    mov dl, 08h             ; Backspace character (to move cursor back)
    int 21h                 ; DOS interrupt

    jmp name_loop           ; Continue input loop

name_done:
    pop dx                  ; Restore position
    mov [name_buffer + di], 0  ; Null-terminate the name string
    mov ah, 00h             ; Set video mode function
    mov al, 03h             ; Text mode 80x25, 16 colors
    int 10h                 ; BIOS video interrupt
    ret                     ; Return from procedure
get_player_name endp

    sleep proc
    mov ah, 0        ; Function 0 - get system time
    int 1Ah          ; BIOS time services interrupt
    mov bx, dx       ; Store initial time in BX
wait_loop:
    mov ah, 0        ; Function 0 - get system time again
    int 1Ah          ; BIOS time services interrupt
    sub dx, bx       ; Calculate time difference
    cmp dx, si       ; Compare with desired delay (in SI)
    jl wait_loop     ; If less, continue waiting
    ret              ; Return from procedure
sleep endp

hide_cursor proc
    mov ah, 02h      ; Function 2 - set cursor position
    mov bh, 0        ; Page number
    mov dh, 25       ; Row 25 (off-screen)
    mov dl, 0        ; Column 0
    int 10h          ; BIOS video services interrupt

    mov ah, 1        ; Function 1 - set cursor type
    mov ch, 20h      ; Bit 5 set - disable cursor
    int 10h          ; BIOS video services interrupt
    ret              ; Return from procedure
hide_cursor endp

clear_keyboard_buffer proc
    mov ah, 01h      ; Function 1 - check for keystroke
    int 16h          ; BIOS keyboard services interrupt
    jz buffer_end    ; If zero flag set (no key), end
    mov ah, 00h      ; Function 0 - read keystroke
    int 16h          ; BIOS keyboard services interrupt
    jmp clear_keyboard_buffer  ; Repeat until buffer is empty
buffer_end:
    ret              ; Return from procedure
clear_keyboard_buffer endp

    buffer_clear proc
    mov bx, 0                      ; Initialize index to 0
clear_next:
    mov byte ptr [buffer + bx], ' ' ; Set buffer byte to space character
    inc bx                         ; Increment index
    cmp bx, 2000                   ; Compare index with buffer size (80x25=2000)
    jnz clear_next                 ; If not at end, continue clearing
    ret                            ; Return from procedure
buffer_clear endp

buffer_print_string proc
print_next:
    mov al, [si]                   ; Load character from source string
    cmp al, 0                      ; Check if it's null terminator
    jz print_end                   ; If null, end printing
    mov byte ptr [buffer + di], al ; Store character in buffer
    inc di                         ; Increment buffer index
    inc si                         ; Increment string index
    jmp print_next                 ; Continue to next character
print_end:
    ret                            ; Return from procedure
buffer_print_string endp

buffer_render proc
    push ds                        ; Save data segment
    mov ax, 0B800h                 ; Video memory segment
    mov es, ax                     ; Set extra segment to video memory
    mov di, offset buffer          ; Source: our buffer
    mov si, 0                      ; Destination: start of video memory
render_next:
    mov bl, [di]                   ; Get character from buffer
    cmp bl, 8                      ; Check if it's snake character (8)
    jz is_snake
    cmp bl, 4                      ; Check if it's snake character (4)
    jz is_snake
    cmp bl, 2                      ; Check if it's sprint character
    jz is_sprint
    cmp bl, 1                      ; Check if it's snake character (1)
    jz is_snake
    jmp write_char                 ; If none of above, write normal character
is_snake:
    mov bl, 219                    ; Set snake character (full block)
    mov cl, 0Ah                    ; Set snake color (light green)
    jmp do_write
is_sprint:
    mov bl, 176                    ; Set sprint character (light shade block)
    mov cl, 07h                    ; Set sprint color (light gray)
    jmp do_write
write_char:
    mov cl, 07h                    ; Set normal color (light gray)
do_write:
    mov byte ptr es:[si], bl       ; Write character to video memory
    mov byte ptr es:[si+1], cl     ; Write color attribute to video memory
    inc di                         ; Move to next buffer character
    add si, 2                      ; Move to next video memory position
    cmp si, 4000                   ; Check if reached end of screen (80x25x2=4000)
    jnz render_next                ; If not at end, continue rendering
    pop ds                         ; Restore data segment
    ret                            ; Return from procedure
buffer_render endp
    writecoloredchar proc
    push dx              ; Save original DX value
    mov dx, ax           ; Copy position to DX (AX had row in AH, column in AL)
    push ax              ; Save original AX value
    mov ax, dx           ; Copy position to AX
    and ax, 0FF00h       ; Isolate row value (high byte)
    mov cl, 8
    shr ax, cl           ; Shift right 8 bits to get row in AL
    mov cl, 160
    mul cl               ; Multiply row by 160 (80 columns * 2 bytes per char)
    pop dx               ; Restore original AX into DX (column value in DL)
    mov dl, dl           ; Copy column value to DL (redundant operation)
    xor dh, dh           ; Clear high byte of DX
    shl dx, 1            ; Multiply column by 2 (2 bytes per character)
    add ax, dx           ; Add column offset to row offset
    mov di, ax           ; Set DI to calculated video memory offset
    mov al, bl           ; Character to write
    mov ah, bh           ; Color attribute
    mov word ptr es:[di], ax  ; Write character and attribute to video memory
    pop dx               ; Restore original DX value
    ret                  ; Return from procedure
writecoloredchar endp

end main                 ; End of the program, main is the entry point
