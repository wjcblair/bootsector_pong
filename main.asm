use16

org 7C00h

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
	mov cx, 80*25
	rep stosw
	;; stosw is equivalent to:
	;;						mov [es:di], ax
	;;						inc di
	
	;; Draw middle separating line
	mov ah, 0F0h
	mov di, 78		; Start at middle of 80 char row
	mov cx, 13		; 'Dashed' line - only draw every other row
	.draw_middle_line:
		stosw					; Store the contents of the AX register in DI, this autoincrements by sizeof str being stored
		add di, 320-2			; Move to next position (two rows down)
		loop .draw_middle_line	; Loop according to CX and decrement	

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
