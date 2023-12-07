use16

org 7C00h

xor ax, ax
mov ds, ax
mov es, ax

jmp setup

;; CONSTANTS ----
VGA_WIDTH		equ 80
VGA_HEIGHT		equ 25
PADDLE_HEIGHT	equ 5
ROW_BLEN		equ VGA_WIDTH*2	; width in bytes: 1 byte for color (4 bits fg, 4 bits bg), 1 byte for char
PADDLE_INIT_Y	equ 10
PLAYER_X		equ 4
CPU_INIT_X		equ ROW_BLEN-3
W_KEY			equ 11h
S_KEY			equ 1Fh
BALL_INIT_X		equ VGA_WIDTH-10
BALL_INIT_Y		equ 12
BALL_INIT_VEL_X equ -2
BALL_INIT_VEL_Y equ -1

;; VARIABLES ----
player_y: dw PADDLE_INIT_Y
drawColor: dw 0F020h
ball_x: dw BALL_INIT_X
ball_y: dw BALL_INIT_Y
ball_vel_x: db BALL_INIT_VEL_X
ball_vel_y: db BALL_INIT_VEL_Y

setup:
	;; Set up video mode
	mov ah, 00h		; set BIOS video mode 
	mov al, 03h		; set text mode, 80x25, 16 color VGA
	int 10h			

	;; Set up video memory
	mov ax, 0B800h
	mov es, ax	; ES:DI <- B800:0000

;; Game loop
game_loop:
	;; Clear screen to black every cycle
	xor ax, ax
	xor di, di
	mov cx,	VGA_WIDTH*VGA_HEIGHT 
	rep stosw
	;; stosw is equivalent to:
	;;						mov [es:di], ax
	;;						inc di
	
	;; Draw middle separating line
	mov ax, [drawColor]
	mov di, 78		; Start at middle of 80 char row
	mov cx, 13		; 'Dashed' line - only draw every other row
	.draw_middle_line:
		stosw					; Store the contents of the AX register in DI, this autoincrements by sizeof str being stored
		add di, 320-2			; Move to next position (two rows down)
		loop .draw_middle_line	; Loop according to CX and decrement	
	



	;; Draw player 
	imul di, [player_y], ROW_BLEN	; realY = y * rowlen 
	mov cl, PADDLE_HEIGHT			; Set count to paddle height
	.draw_player:
		mov [es:di+PLAYER_X], ax		; Draw current pixel
		add di, ROW_BLEN			; Go to the next row
		loop .draw_player			; Loop til count is zero		

	;; Draw ball
	imul di, [ball_y], ROW_BLEN
	add di,	[ball_x]
	mov word [es:di], 0D020h

	;; Move ball
	mov bl, [ball_vel_x]
	add [ball_x], bl 
	mov bl, [ball_vel_y]
	add [ball_y], bl 


	;; Move player
	get_player_input:
		mov ah, 01h		; Check keyboard buffer state
		int 16h			; Call keyboard service interrupt
		jz move_cpu		; Move on if no input
		
		mov ah, 0h		; Read key press
		int 16h

		cmp ah, W_KEY
		je w_pressed
		cmp ah, S_KEY
		je s_pressed
		
		jmp move_cpu	

	w_pressed:
		dec word [player_y]
		cmp word [player_y], 0
		jge move_cpu
		inc word [player_y]
		jmp move_cpu

	s_pressed:
		inc word [player_y]
		cmp word [player_y], VGA_HEIGHT-PADDLE_HEIGHT
		jle move_cpu
		dec word [player_y]
		jmp move_cpu

		

	move_cpu:

;; Draw stuff to the screen
	
;; Player input

;; CPU input

	;; Delay timer (because CPU draws too fast)
	mov bx, [046Ch] ; (from BIOS Data Area (BDA)) Move # of IRQ0 timer ticks since boot into bx
	inc bx
	inc bx	; Could do add instead but two incs saves space
	.delay:	; Compare the number current number of ticks with bx, if difference < 2, delay again
		cmp [046Ch], bx
		jl .delay

jmp game_loop

;; Bootsector padding
times 510-($-$$) db 0
dw 0AA55h ; Write the MAGIC Bootsector # in last 2 bytes
