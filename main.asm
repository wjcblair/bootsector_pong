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

;; VARIABLES ----
player_y: dw PADDLE_INIT_Y
drawColor: dw 0F020h

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
